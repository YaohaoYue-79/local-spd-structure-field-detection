# Experiment Execution Table

## A. Main detection performance
- multi-seed, multi-SNR
- ROC at representative SNRs
- AUC vs SNR
- Pd@1e-2 vs SNR
- Pd@1e-3 vs SNR
- achieved-Pfa audit
- paired gains over weakened variants

## B. Training-sample sensitivity
- trainH0=trainH1 in {10,20,40,80,160}
- fixed scene and fixed calibration/test sets
- AUC / Pd@1e-2 / Pd@1e-3 / paired gains vs training size

## C. Pooling-parameter sensitivity
- block size
- top-block fraction
- global-local pooling balance
- single-parameter scans only

## D. Baseline comparison
- weakened detector variants
- global low-order baselines
- Euclidean / Frobenius structure-field baselines

## E. Ablation
- without discriminative weighting
- without top-local emphasis
- double ablation

## F. Non-Gaussian robustness
- recalibrated thresholds under each noise condition
- achieved-Pfa audit mandatory

## G. Local-structure perturbation and boundary validation
- number of discriminative local structures
- shared distractor complexity
- structural stability perturbation
- weakened inter-class structural separation
