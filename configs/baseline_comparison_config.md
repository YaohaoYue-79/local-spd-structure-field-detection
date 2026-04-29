# Baseline Comparison Configuration

## Purpose

This experiment compares the proposed detector with representative global, template-based, and structure-field baselines under the main structured-locality detection scene.

## Methods

| Method label | Public name | Description |
|---|---|---|
| proposed | Proposed detector | Local SPD structure field, AIRM comparison, discriminative weighting, and block-wise robust pooling |
| euclidean_structure_field | Euclidean structure-field baseline | Local structure-field comparison using a Euclidean/Frobenius-style distance |
| fro_structure_field | Frobenius structure-field baseline | Frobenius structure-field baseline; numerically identical to the Euclidean structure-field baseline in the current implementation |
| template_correlation | Template-correlation baseline | Template similarity baseline |
| pooled_covariance | Pooled-covariance baseline | Single pooled covariance statistic |
| global_energy | Global-energy baseline | Global energy statistic |

## Data Splits

All methods use the same independent training, calibration, testing, and audit sets.

## Fixed-\(P_{\mathrm{fa}}\) Protocol

Each method uses its own independent \(H_0\) calibration scores to determine the threshold at the target fixed-\(P_{\mathrm{fa}}\) operating points.

## Reported Metrics

- AUC
- \(P_d\) at \(P_{\mathrm{fa}}=10^{-2}\)
- achieved \(P_{\mathrm{fa}}\) at \(10^{-2}\)
- \(P_d\) at \(P_{\mathrm{fa}}=10^{-3}\)
- achieved \(P_{\mathrm{fa}}\) at \(10^{-3}\)

## Notes

The comparison focuses on the choice of detection object and sample-level statistic. It is not intended to compare different threshold implementations.
