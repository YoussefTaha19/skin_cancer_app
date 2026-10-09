# ==================================================
# test_api_final.py - الاختبار النهائي مع CSV
# ==================================================

import requests
import json
import os
import random
import pandas as pd
from datetime import datetime

# ---------------------------
# إعدادات
# ---------------------------
SERVER_URL = "http://127.0.0.1:5000/predict"
TEST_FOLDER = r"D:\Projects\skin_cancer_detector\assets\test_images\dataverse_files\ISIC2018_Task3_Test_Images"

CSV_PATH = r"D:\Projects\skin_cancer_detector\assets\test_images\dataverse_files\ISIC2018_Task3_Test_GroundTruth.csv"
CLASS_NAMES = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']

# ---------------------------
# تحميل التصنيفات الحقيقية
# ---------------------------
print("📊 جاري تحميل التصنيفات الحقيقية...")
df = pd.read_csv(CSV_PATH)
true_labels = dict(zip(df['image_id'], df['dx']))
print(f"✅ تم تحميل {len(true_labels)} تصنيف")

# ---------------------------
# اختيار 20 صورة عشوائية
# ---------------------------
all_images = [f for f in os.listdir(TEST_FOLDER) if f.endswith('.jpg')]
print(f"📸 إجمالي الصور: {len(all_images)}")

random.seed(datetime.now().timestamp())
test_images = random.sample(all_images, min(20, len(all_images)))
print(f"🔀 تم اختيار 20 صورة عشوائياً")
print("="*70)

# ---------------------------
# الاختبار
# ---------------------------
results = []
correct = 0

for i, img_file in enumerate(test_images, 1):
    img_path = os.path.join(TEST_FOLDER, img_file)
    img_id = img_file.replace('.jpg', '')
    
    # التصنيف الحقيقي من CSV
    true_class = true_labels.get(img_id, 'unknown')
    
    print(f"\n📷 [{i}/20] {img_file}")
    
    with open(img_path, 'rb') as f:
        files = {'image': f}
        response = requests.post(SERVER_URL, files=files)
        
        if response.status_code == 200:
            result = response.json()
            pred_class = result['class']
            confidence = result['confidence']
            
            is_correct = (pred_class == true_class)
            if is_correct:
                correct += 1
            
            mark = "✅" if is_correct else "❌"
            danger = "🔴" if pred_class in ['mel', 'akiec', 'bcc'] else "🟢"
            
            print(f"   {mark} {danger} توقع: {pred_class} ({confidence*100:.2f}%)")
            print(f"      ✅ حقيقي: {true_class}")
            
            results.append({
                'image': img_file,
                'true': true_class,
                'pred': pred_class,
                'conf': confidence,
                'correct': is_correct
            })
        else:
            print(f"   ❌ خطأ في السيرفر")

# ---------------------------
# النتائج النهائية
# ---------------------------
print("\n" + "="*70)
print("📊 النتائج النهائية (مع التصنيفات الحقيقية)")
print("="*70)

accuracy = (correct / 20) * 100
print(f"\n🎯 الدقة الحقيقية: {accuracy:.2f}% ({correct}/20)")

print("\n📈 تفاصيل كل صورة:")
print("-"*70)
for r in results:
    mark = "✅" if r['correct'] else "❌"
    print(f"{mark} {r['image'][:25]:25} → توقع: {r['pred']:6}, حقيقي: {r['true']:6}, ثقة: {r['conf']*100:6.2f}%")

# دقة كل فئة
print("\n📊 دقة كل فئة:")
print("-"*40)
for cls in CLASS_NAMES:
    cls_results = [r for r in results if r['true'] == cls]
    if cls_results:
        cls_correct = sum(1 for r in cls_results if r['correct'])
        cls_acc = (cls_correct / len(cls_results)) * 100
        print(f"{cls}: {cls_acc:5.2f}% ({cls_correct}/{len(cls_results)})")