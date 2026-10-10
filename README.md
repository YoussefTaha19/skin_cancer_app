# Skin Cancer Detection AI

An AI-powered skin lesion classification application built with **Flutter, TensorFlow, EfficientNetB0, and Flask**. The system analyzes an uploaded skin lesion image and predicts one of seven skin lesion categories.

> **Medical Disclaimer:** This project is for educational and research purposes only. It is not a medical diagnostic tool and must not replace professional medical advice, examination, or diagnosis.

## Overview

The application combines a Flutter user interface with a Python Flask backend and a deep learning image classification model.

Users can select a skin lesion image, submit it for analysis, and receive the model's predicted category and confidence score.

## Features

- Skin lesion image classification across seven categories.
- Deep learning model based on EfficientNetB0.
- Flutter application interface for Android and web.
- Flask REST API for model inference.
- Image preprocessing and prediction response handling.

## Technology Stack

| Component | Technology |
|---|---|
| Mobile and web UI | Flutter, Dart |
| Deep learning | TensorFlow, Keras |
| Model architecture | EfficientNetB0 |
| Backend API | Python, Flask, Flask-CORS |
| Image processing | Pillow |

| Training dataset | HAM10000 |

## Model Information

The model was trained on the HAM10000 skin lesion dataset and configured to classify images into seven categories.

| Label | Category |
|---|---|
| `akiec` | Actinic keratoses and intraepithelial carcinoma |
| `bcc` | Basal cell carcinoma |
| `bkl` | Benign keratosis-like lesions |
| `df` | Dermatofibroma |
| `mel` | Melanoma |
| `nv` | Melanocytic nevi |
| `vasc` | Vascular lesions |

The model uses a 224 × 224 RGB image input and produces scores for the seven classes.

**Reported evaluation result:** 71.21% accuracy on ISIC 2018. This figure should be interpreted in the context of the specific evaluation setup and dataset; it does not establish clinical reliability.

## Project Structure

```text
skin_cancer_app/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── custom_splash_screen.dart
│   │   └── home_screen.dart
│   ├── services/
│   │   └── api_service.dart
│   └── utils/
│       └── disease_data.dart
├── backend/
│   ├── server.py
│   ├── test_api.py
│   ├── requirements.txt
│   └── backups/
│       └── skin_ai_model_final.keras
├── notebooks/
│   └── Skin_AI.ipynb
├── test/
├── pubspec.yaml
├── pubspec.lock
├── .gitignore
└── README.md
```

The trained model file is excluded from Git because of its size. The local `backend/backups/` directory is not included in the repository.

## Requirements

- Flutter SDK and Dart.
- Python 3.9 or a compatible Python environment.
- The dependencies listed in `backend/requirements.txt`.
- The trained model file at `backend/backups/skin_ai_model_final.keras`.

TensorFlow installation compatibility depends on the operating system, Python version, and available hardware.

## Run the Backend

From the project root, create and activate a Python virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

Install backend dependencies:

```powershell
python -m pip install -r backend/requirements.txt
```

Ensure the trained model exists at:

```text
backend/backups/skin_ai_model_final.keras
```

Start the API:

```powershell
python backend/server.py
```

The local API uses port `5000` by default.

### API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| `GET` | `/health` | Check backend and model status |
| `POST` | `/predict` | Submit an image for classification |

The prediction endpoint accepts a multipart form upload using the field name `image`.

## Run the Flutter Application

Install Flutter dependencies:

```powershell
flutter pub get
```

Run the application:

```powershell
flutter run
```

The API base URL is configured in `lib/services/api_service.dart`. Update it to the correct backend address for your environment.

For Android devices, the backend must be reachable from the device. The address `127.0.0.1` refers to the device itself, not your computer, unless you configure an appropriate emulator or network mapping.

## Model Deployment

The trained `.keras` model is intentionally excluded from the Git repository. Before deploying the backend, provide the model through a suitable secure artifact or model-storage solution and configure the backend to load it from the deployment environment.

Do not commit large model files, credentials, or environment-specific configuration unnecessarily.

## Limitations

- Performance depends on the training data, evaluation methodology, image quality, and distribution of real-world images.
- A predicted class and confidence score are not equivalent to a medical diagnosis.
- The model may perform differently on images from populations, devices, or settings not represented in its training and evaluation data.
- Clinical use would require appropriate validation, governance, and regulatory review.

## Future Improvements

- Improve evaluation using class-wise precision, recall, F1-score, and a confusion matrix.
- Expand testing on independent datasets.
- Improve API deployment and configuration management.
- Add automated tests and continuous integration.
- Improve accessibility, usability, and error handling in the application.

## License

Add a license before distributing or reusing this project. Until a license is specified, do not assume that the repository grants permission to reuse its contents.
