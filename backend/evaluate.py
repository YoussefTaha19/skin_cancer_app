import csv
import os
import numpy as np
from PIL import Image
from ai_edge_litert.interpreter import Interpreter

BASE = os.path.dirname(os.path.abspath(__file__))
MODEL = os.path.join(BASE, "model", "skin_ai_model.tflite")
DATASET = os.environ.get("ISIC_DATASET_DIR", r"D:\Datasets\dataverse_files")
IMG_DIR = os.path.join(DATASET, "ISIC2018_Task3_Test_Images")
CSV_PATH = os.path.join(DATASET, "ISIC2018_Task3_Test_GroundTruth.csv")
REPORT = os.path.join(BASE, "evaluation_report.md")
CLASSES = ['akiec', 'bcc', 'bkl', 'df', 'mel', 'nv', 'vasc']

interp = Interpreter(model_path=MODEL)
interp.allocate_tensors()
inp = interp.get_input_details()[0]
out = interp.get_output_details()[0]

with open(CSV_PATH, newline="", encoding="utf-8-sig") as f:
    rows = list(csv.DictReader(f))
assert rows and {'image_id', 'dx'} <= set(rows[0]), f"Unexpected CSV columns: {list(rows[0]) if rows else None}"

n = len(CLASSES)
cm = np.zeros((n, n), dtype=int)  # rows: true, cols: predicted
missing_files = 0
for k, row in enumerate(rows, 1):
    path = os.path.join(IMG_DIR, row['image_id'] + ".jpg")
    if not os.path.exists(path):
        missing_files += 1
        continue
    true_idx = CLASSES.index(row['dx'].strip().lower())
    img = Image.open(path).convert("RGB").resize((224, 224))
    x = np.expand_dims(np.array(img, dtype=np.float32), axis=0)
    interp.set_tensor(inp["index"], x)
    interp.invoke()
    pred_idx = int(np.argmax(interp.get_tensor(out["index"])[0]))
    cm[true_idx, pred_idx] += 1
    if k % 200 == 0:
        print(f"{k}/{len(rows)}")

total = int(cm.sum())
support = cm.sum(axis=1)
recall = np.divide(np.diag(cm), support, out=np.zeros(n), where=support > 0)
pred_count = cm.sum(axis=0)
precision = np.divide(np.diag(cm), pred_count, out=np.zeros(n), where=pred_count > 0)
f1 = np.divide(2 * precision * recall, precision + recall,
               out=np.zeros(n), where=(precision + recall) > 0)
accuracy = np.trace(cm) / total
balanced = recall[support > 0].mean()
baseline = support.max() / total
mel = CLASSES.index('mel')
non_mel = [i for i in range(n) if i != mel]
mel_sens = recall[mel]
mel_spec = cm[non_mel][:, [j for j in range(n) if j != mel]].sum() / cm[non_mel].sum()

lines = []
lines.append(f"Images evaluated: {total} (missing files: {missing_files})\n")
lines.append(f"- Accuracy: {accuracy:.2%}")
lines.append(f"- Balanced accuracy (mean recall): {balanced:.2%}")
lines.append(f"- Majority-class baseline ({CLASSES[int(support.argmax())]} only): {baseline:.2%}")
lines.append(f"- Melanoma sensitivity: {mel_sens:.2%} | specificity vs rest: {mel_spec:.2%}\n")
lines.append("| Class | Support | Precision | Recall | F1 |")
lines.append("|---|---|---|---|---|")
for i, c in enumerate(CLASSES):
    lines.append(f"| {c} | {support[i]} | {precision[i]:.2%} | {recall[i]:.2%} | {f1[i]:.2%} |")
lines.append("\nConfusion matrix (rows = true, cols = predicted):\n")
lines.append("| true \\ pred | " + " | ".join(CLASSES) + " |")
lines.append("|---|" + "---|" * n)
for i, c in enumerate(CLASSES):
    lines.append(f"| {c} | " + " | ".join(str(v) for v in cm[i]) + " |")

text = "\n".join(lines)
print(text)
with open(REPORT, "w", encoding="utf-8") as f:
    f.write(text + "\n")