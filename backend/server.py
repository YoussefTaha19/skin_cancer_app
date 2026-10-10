import io
import os
import logging
import threading

import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image, UnidentifiedImageError
from ai_edge_litert.interpreter import Interpreter

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "model", "skin_ai_model.tflite")
CLASS_NAMES = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']
MAX_IMAGE_SIZE = 5 * 1024 * 1024

logger.info("Loading TFLite model...")
interpreter = Interpreter(model_path=MODEL_PATH)
interpreter.allocate_tensors()
INPUT = interpreter.get_input_details()[0]
OUTPUT = interpreter.get_output_details()[0]
_lock = threading.Lock()  # the interpreter is not thread-safe
logger.info("Model ready.")

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = MAX_IMAGE_SIZE
CORS(app)


def run_model(x):
    with _lock:
        interpreter.set_tensor(INPUT['index'], x)
        interpreter.invoke()
        return interpreter.get_tensor(OUTPUT['index'])[0].copy()


@app.errorhandler(413)
def too_large(_e):
    return jsonify({'error': 'حجم الصورة كبير جداً (الحد الأقصى 5MB)'}), 413


@app.route('/predict', methods=['POST'])
def predict():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'لم يتم إرفاق صورة'}), 400

        img_bytes = request.files['image'].read()
        try:
            img = Image.open(io.BytesIO(img_bytes)).convert('RGB')
        except UnidentifiedImageError:
            return jsonify({'error': 'الملف المرفوع ليس صورة صالحة'}), 400

        img = img.resize((224, 224))
        x = np.expand_dims(np.array(img, dtype=np.float32), axis=0)

        predictions = run_model(x)
        idx = int(np.argmax(predictions))
        return jsonify({
            'class': CLASS_NAMES[idx],
            'confidence': float(predictions[idx]),
            'all_probabilities': {
                CLASS_NAMES[i]: float(predictions[i])
                for i in range(len(CLASS_NAMES))
            },
        })
    except Exception as e:
        logger.error(f"Error while processing request: {e}", exc_info=True)
        return jsonify({'error': 'حدث خطأ أثناء تحليل الصورة، حاول مرة أخرى'}), 500


@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'model_loaded': True})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)