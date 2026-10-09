from flask import Flask, request, jsonify
from flask_cors import CORS
from tensorflow.keras.models import load_model
from tensorflow.keras.applications.efficientnet import preprocess_input
from PIL import Image, UnidentifiedImageError
import numpy as np
import io
import os
import logging

# ---------------------------
# إعداد الـ logging (بدل print، وبيسجل الأخطاء الحقيقية سيرفر-سايد)
# ---------------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ---------------------------
# إعداد المسارات (بات نسبي، يشتغل على أي جهاز/سيرفر)
# ---------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "backups", "skin_ai_model_final.keras")
CLASS_NAMES = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']

# حد أقصى لحجم الصورة المرفوعة (5 ميجا)
MAX_IMAGE_SIZE = 5 * 1024 * 1024

# ---------------------------
# تحميل النموذج
# ---------------------------
logger.info("جاري تحميل النموذج...")
model = load_model(MODEL_PATH)
logger.info("النموذج جاهز!")

# ---------------------------
# إنشاء تطبيق Flask مع CORS
# ---------------------------
app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = MAX_IMAGE_SIZE
CORS(app)

@app.route('/predict', methods=['POST', 'OPTIONS'])
def predict():
    if request.method == 'OPTIONS':
        response = jsonify({'status': 'ok'})
        response.headers.add('Access-Control-Allow-Origin', '*')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type')
        response.headers.add('Access-Control-Allow-Methods', 'POST')
        return response

    try:
        if 'image' not in request.files:
            response = jsonify({'error': 'لم يتم إرفاق صورة'})
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response, 400

        file = request.files['image']
        img_bytes = file.read()

        try:
            img = Image.open(io.BytesIO(img_bytes)).convert('RGB')
        except UnidentifiedImageError:
            response = jsonify({'error': 'الملف المرفوع ليس صورة صالحة'})
            response.headers.add('Access-Control-Allow-Origin', '*')
            return response, 400

        img = img.resize((224, 224))

        img_array = np.array(img)
        img_array = preprocess_input(img_array)
        img_array = np.expand_dims(img_array, axis=0)

        predictions = model.predict(img_array, verbose=0)[0]
        predicted_class = CLASS_NAMES[np.argmax(predictions)]
        confidence = float(np.max(predictions))

        result = {
            'class': predicted_class,
            'confidence': confidence,
            'all_probabilities': {
                CLASS_NAMES[i]: float(predictions[i])
                for i in range(len(CLASS_NAMES))
            }
        }

        response = jsonify(result)
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response

    except Exception as e:
        # نسجل التفاصيل الحقيقية بالسيرفر فقط، ونرجع رسالة عامة للمستخدم
        logger.error(f"خطأ أثناء معالجة الطلب: {e}", exc_info=True)
        response = jsonify({'error': 'حدث خطأ أثناء تحليل الصورة، حاول مرة أخرى'})
        response.headers.add('Access-Control-Allow-Origin', '*')
        return response, 500

@app.route('/health', methods=['GET'])
def health():
    response = jsonify({'status': 'ok', 'model_loaded': True})
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)