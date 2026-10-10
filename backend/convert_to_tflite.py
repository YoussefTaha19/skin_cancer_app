import os
import glob
import numpy as np
import tensorflow as tf
from PIL import Image
from tensorflow.keras.applications.efficientnet import preprocess_input

BASE = os.path.dirname(os.path.abspath(__file__))
KERAS_PATH = os.path.join(BASE, "backups", "skin_ai_model_final.keras")
OUT_DIR = os.path.join(BASE, "model")
OUT_PATH = os.path.join(OUT_DIR, "skin_ai_model.tflite")
DATASET = os.environ.get("ISIC_DATASET_DIR", r"D:\Datasets\dataverse_files")
IMG_DIR = os.path.join(DATASET, "ISIC2018_Task3_Test_Images")

os.makedirs(OUT_DIR, exist_ok=True)

model = tf.keras.models.load_model(KERAS_PATH)
tflite_bytes = tf.lite.TFLiteConverter.from_keras_model(model).convert()
with open(OUT_PATH, "wb") as f:
    f.write(tflite_bytes)
print("TFLite size (MB):", round(len(tflite_bytes) / 1024 / 1024, 2))

interp = tf.lite.Interpreter(model_path=OUT_PATH)
interp.allocate_tensors()
inp = interp.get_input_details()[0]
out = interp.get_output_details()[0]
print("input:", inp["shape"], inp["dtype"], "| output:", out["shape"])

files = sorted(glob.glob(os.path.join(IMG_DIR, "*.jpg")))[:100]
max_diff, agree = 0.0, 0
for p in files:
    img = Image.open(p).convert("RGB").resize((224, 224))
    x = preprocess_input(np.array(img, dtype=np.float32)[None])
    a = model.predict(x, verbose=0)[0]
    interp.set_tensor(inp["index"], x)
    interp.invoke()
    b = interp.get_tensor(out["index"])[0]
    max_diff = max(max_diff, float(np.abs(a - b).max()))
    agree += int(a.argmax() == b.argmax())

print(f"images: {len(files)} | max abs diff: {max_diff:.6f} | same class: {agree}/{len(files)}")