Images evaluated: 1511 (missing files: 1)

- Accuracy: 70.02%
- Balanced accuracy (mean recall): 70.30%
- Majority-class baseline (nv only): 60.09%
- Melanoma sensitivity: 65.50% | specificity vs rest: 86.12%

| Class | Support | Precision | Recall | F1 |
|---|---|---|---|---|
| akiec | 43 | 31.48% | 79.07% | 45.03% |
| bcc | 93 | 58.26% | 72.04% | 64.42% |
| bkl | 217 | 63.46% | 60.83% | 62.12% |
| df | 44 | 64.81% | 79.55% | 71.43% |
| mel | 171 | 37.58% | 65.50% | 47.76% |
| nv | 908 | 93.98% | 72.25% | 81.69% |
| vasc | 35 | 73.33% | 62.86% | 67.69% |

Confusion matrix (rows = true, cols = predicted):

| true \ pred | akiec | bcc | bkl | df | mel | nv | vasc |
|---|---|---|---|---|---|---|---|
| akiec | 34 | 4 | 3 | 0 | 2 | 0 | 0 |
| bcc | 10 | 67 | 2 | 3 | 7 | 2 | 2 |
| bkl | 22 | 14 | 132 | 2 | 32 | 13 | 2 |
| df | 2 | 1 | 3 | 35 | 1 | 2 | 0 |
| mel | 16 | 2 | 12 | 4 | 112 | 23 | 2 |
| nv | 24 | 21 | 56 | 9 | 140 | 656 | 2 |
| vasc | 0 | 6 | 0 | 1 | 4 | 2 | 22 |
