# Skin Lesion Classifier

[![Build Flutter APK](https://github.com/YoussefTaha19/skin_cancer_app/actions/workflows/build-apk.yml/badge.svg)](https://github.com/YoussefTaha19/skin_cancer_app/actions/workflows/build-apk.yml)

An Android app that classifies a photo of a skin lesion into one of seven categories, backed by a small Flask API running a TensorFlow Lite model (EfficientNetB0 fine-tuned on HAM10000).

> **Medical disclaimer.** This is a learning / portfolio project, **not a medical device**. It must not be used for diagnosis or to make treatment decisions. See [Limitations](#limitations) for measured error rates.

## How it works

```
Flutter app (Android)  --HTTPS, multipart image-->  Flask API (gunicorn)  -->  TFLite model
   image_picker                /predict, /health        Pillow + numpy        EfficientNetB0
```

- **App** (`lib/`): picks an image, uploads it to `/predict`, and shows the predicted class, its confidence and short information about the condition.
- **API** (`backend/server.py`): validates the upload (max 5 MB, must be a valid image), resizes to 224x224, runs the TFLite interpreter and returns class probabilities.
- **Model**: EfficientNetB0 trained on HAM10000 (see `notebooks/Skin_AI.ipynb`), converted to TFLite (float32, no quantization). The converted model matches the Keras model: max absolute difference 1.3e-5 and identical predicted class on 100/100 checked images (`backend/convert_to_tflite.py`).

### Classes

| Code | Meaning |
|---|---|
| `akiec` | Actinic keratoses / intraepithelial carcinoma |
| `bcc` | Basal cell carcinoma |
| `bkl` | Benign keratosis-like lesions |
| `df` | Dermatofibroma |
| `mel` | Melanoma |
| `nv` | Melanocytic nevi |
| `vasc` | Vascular lesions |

## Measured performance

Evaluated with `backend/evaluate.py` on the HAM10000 / ISIC 2018 Task 3 test set: **1,511 images** (one listed image file was missing). Full report: [`backend/evaluation_report.md`](backend/evaluation_report.md).

| Metric | Value |
|---|---|
| Accuracy | 70.0% |
| Balanced accuracy (mean recall) | 70.3% |
| Majority-class baseline (always `nv`) | 60.1% |
| Melanoma sensitivity / specificity (vs. rest) | 65.5% / 86.1% |

| Class | Support | Precision | Recall | F1 |
|---|---|---|---|---|
| akiec | 43 | 31.5% | 79.1% | 45.0% |
| bcc | 93 | 58.3% | 72.0% | 64.4% |
| bkl | 217 | 63.5% | 60.8% | 62.1% |
| df | 44 | 64.8% | 79.5% | 71.4% |
| mel | 171 | 37.6% | 65.5% | 47.8% |
| nv | 908 | 94.0% | 72.3% | 81.7% |
| vasc | 35 | 73.3% | 62.9% | 67.7% |

## Limitations

- **About one third of melanomas are missed** (59 of 171 test cases), mostly predicted as `nv`, `akiec` or `bkl`.
- **Many false alarms:** 140 of 908 benign nevi were predicted as melanoma, so melanoma precision is only 37.6%.
- Rare classes (`akiec`, `mel`) have recall higher than precision, i.e. the model over-predicts them.
- Trained and tested on dermoscopic images from one benchmark. Phone photos taken in everyday conditions are a different distribution, and no evaluation on such images has been done.
- No authentication or rate limiting on the API; it is intended for personal use.

## Repository layout

```
lib/                  Flutter app (screens, API client, condition info)
android/              Android project
backend/
  server.py           Flask API (TFLite inference)
  model/              skin_ai_model.tflite (deployed model)
  convert_to_tflite.py   Keras -> TFLite conversion + parity check
  evaluate.py         Full test-set evaluation -> evaluation_report.md
  test_api.py         Smoke test against a running server
  requirements.txt    Runtime dependencies
  requirements-train.txt  TensorFlow/Keras dependencies (conversion, notebook)
notebooks/Skin_AI.ipynb   Training notebook
```

The original Keras model (`backend/backups/*.keras`) and the datasets are **not** in the repository.

## Run the API locally

Python 3.11 is recommended (the `ai-edge-litert` wheel is not available for Python 3.9 on Windows).

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate    Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
python server.py                  # http://127.0.0.1:5000
```

```bash
curl http://127.0.0.1:5000/health
curl -F "image=@lesion.jpg" http://127.0.0.1:5000/predict
```

`/predict` returns:

```json
{
  "class": "nv",
  "confidence": 0.99,
  "all_probabilities": { "akiec": 0.0, "bcc": 0.0, "bkl": 0.0, "df": 0.0, "mel": 0.0, "nv": 0.99, "vasc": 0.0 }
}
```

For production use `gunicorn server:app --workers 1 --timeout 120 --bind 0.0.0.0:$PORT`. One worker is enough and keeps memory low (about 100 MB measured).

## Run the Android app

Requires Flutter (developed with 3.44.4) and an Android device or emulator.

1. Set the API address in `lib/services/api_service.dart` (`baseUrl`). For an emulator talking to a local server use `http://10.0.2.2:5000`.
2. Build and run:

```bash
flutter pub get
flutter run --release
```

## Deployment notes

The API is deployed on Render's free tier from the `backend/` directory (build: `pip install -r requirements.txt`, start: the gunicorn command above, env `PYTHON_VERSION=3.11.9`). The free tier sleeps after about 15 minutes of inactivity, so the first request afterwards can take around a minute. The public URL is intentionally not listed here.

TensorFlow was dropped from the runtime because it needed about 750 MB of RAM; TFLite via `ai-edge-litert` needs about 100 MB.

## Reproduce the evaluation

Download the HAM10000 test images and metadata CSV (`ISIC2018_Task3_Test_Images/` and `ISIC2018_Task3_Test_GroundTruth.csv`), then:

```bash
export ISIC_DATASET_DIR=/path/to/dataset     # PowerShell: $env:ISIC_DATASET_DIR="D:\Datasets\dataverse_files"
python backend/evaluate.py
```

## License and data

All rights reserved. This repository is shared for portfolio and review purposes; no permission is granted to copy, modify or redistribute the code or model without the author's consent.

**Data and model.** The model was trained on HAM10000 and evaluated on the ISIC 2018 Task 3 test set. These datasets are distributed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) (non-commercial, attribution required). The datasets are not included in this repository. The trained model is provided for educational and research use only, not for commercial or clinical use.

**Credits**
- Tschandl P., Rosendahl C., Kittler H. *The HAM10000 dataset, a large collection of multi-source dermatoscopic images of common pigmented skin lesions.* Sci. Data 5, 180161 (2018).
- Tschandl P. et al. *Human-computer collaboration for skin cancer recognition.* Nat. Med. 26, 1229-1234 (2020).
- Codella N. et al. *Skin Lesion Analysis Toward Melanoma Detection 2018: A Challenge Hosted by the International Skin Imaging Collaboration (ISIC).* arXiv:1902.03368 (2019).