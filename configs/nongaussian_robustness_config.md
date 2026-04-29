# Non-Gaussian Robustness Configuration

## Purpose

This experiment evaluates the robustness of the proposed detector under moderate field-level non-Gaussian background perturbations.

## Perturbation Location

Perturbations are applied at the SPD-field object layer.

## Noise Conditions

| Condition | Noise scale | Description |
|---|---:|---|
| Gaussian | 0.010 | Standard normal log-domain perturbation |
| Laplace-distributed | 0.010 | Laplace-distributed log-domain perturbation |
| Impulsive | 0.012 | Gaussian perturbation with impulsive amplification |
| Heavy-tailed | 0.012 | Student-\(t\) perturbation with \(\nu=3\) and variance normalization |

## Impulsive Perturbation

The perturbation magnitude is amplified by a factor of 4 with probability \(p_{\mathrm{imp}}=0.08\).

## Heavy-Tailed Perturbation

The heavy-tailed perturbation uses a Student-\(t\) distribution with \(\nu=3\), normalized by \(\sqrt{3}\).

## Training and Evaluation Protocol

Non-Gaussian perturbations are not applied to the training \(H_0/H_1\) sets. The class-conditional reference fields and discriminative weight map are estimated from the main-scene training data.

Non-Gaussian perturbations are applied to:

- calibration \(H_0\);
- test \(H_0\);
- test \(H_1\);
- audit \(H_0\).

For each noise condition, the fixed-\(P_{\mathrm{fa}}\) threshold is re-estimated using the corresponding perturbed independent \(H_0\) calibration set.

## Notes

The results indicate robustness to moderate field-level distributional perturbations under recalibrated fixed-\(P_{\mathrm{fa}}\) thresholds. They do not imply that a threshold calibrated under one noise condition can be directly transferred to another condition.
