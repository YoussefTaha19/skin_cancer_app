# ==================================================
# اختبار ملف TFLite الجديد على 20 صورة
# ==================================================

import tensorflow as tf
import numpy as np
from PIL import Image
import os
import random

# ---------------------------
# المسارات (عدلها حسب جهازك)
# ---------------------------

TFLITE_PATH = r"D:\Projects\skin_cancer_app\assets\models\skin_ai_model.tflite"
TEST_FOLDER = r"D:\Projects\skin_cancer_detector\assets\test_images\dataverse_files\ISIC2018_Task3_Test_Images"
CLASS_NAMES = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']

# ---------------------------
# تحميل ملف TFLite
# ---------------------------
print("📥 جاري تحميل ملف TFLite...")
interpreter = tf.lite.Interpreter(model_path=TFLITE_PATH)
interpreter.allocate_tensors()

# الحصول على تفاصيل الإدخال والإخراج
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
print(f"✅ تم التحميل، حجم الإدخال: {input_details[0]['shape']}")

# ---------------------------
# دالة التنبؤ باستخدام TFLite
# ---------------------------
def predict_tflite(image_path):
    # تجهيز الصورة
    img = Image.open(image_path).convert('RGB')
    img = img.resize((224, 224))
    img_array = np.array(img, dtype=np.float32)
    img_array = (img_array / 127.5) - 1  # نفس preprocess_input
    img_array = np.expand_dims(img_array, axis=0)
    
    # تشغيل النموذج
    interpreter.set_tensor(input_details[0]['index'], img_array)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    
    # النتيجة
    pred_class = CLASS_NAMES[np.argmax(output[0])]
    confidence = np.max(output[0])
    return pred_class, confidence

# ---------------------------
# اختبار على 20 صورة عشوائية
# ---------------------------
all_images = [f for f in os.listdir(TEST_FOLDER) if f.endswith('.jpg')]
test_images = random.sample(all_images, min(20, len(all_images)))

print(f"\n📸 اختبار على {len(test_images)} صورة عشوائية:")
print("="*70)

correct = 0
for i, img_file in enumerate(test_images, 1):
    img_path = os.path.join(TEST_FOLDER, img_file)
    pred_class, conf = predict_tflite(img_path)
    
    # استخراج التصنيف الحقيقي من اسم الصورة (تقريبي)
    true_class = img_file.split('_')[1] if '_' in img_file else 'unknown'
    
    is_correct = (pred_class == true_class)
    if is_correct:
        correct += 1
    
    danger = "🔴" if pred_class in ['mel', 'akiec', 'bcc'] else "🟢"
    mark = "✅" if is_correct else "❌"
    print(f"{mark} [{i:2d}] {img_file[:25]:25} → {danger} {pred_class} ({conf*100:6.2f}%)")

print("="*70)
print(f"📊 الدقة التقريبية: {correct}/{len(test_images)} = {correct/len(test_images)*100:.1f}%")
print("="*70)