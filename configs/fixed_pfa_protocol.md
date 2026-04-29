# Fixed-\(P_{\mathrm{fa}}\) Calibration Protocol

## Purpose

This file describes the fixed-\(P_{\mathrm{fa}}\) protocol used in all formal experiments.

## Target Operating Points

- \(P_{\mathrm{fa}}=10^{-2}\)
- \(P_{\mathrm{fa}}=10^{-3}\)

## Data Splits

For each experiment and each random seed, mutually independent data splits are used.

| Split | Purpose |
|---|---|
| trainH0 / trainH1 | Reference-field estimation and discriminative weight-map construction |
| calibH0_formal | Fixed-\(P_{\mathrm{fa}}\) threshold calibration |
| testH0 / testH1 | ROC/AUC and detection probability evaluation |
| auditH0_formal | Achieved \(P_{\mathrm{fa}}\) validation |

## Threshold Calibration

For a target false-alarm probability \(P_{\mathrm{fa}}\), the detection threshold is estimated from the empirical order statistic of the independent \(H_0\) calibration scores.

The threshold is not estimated from the test set.

## Achieved \(P_{\mathrm{fa}}\)

The achieved false-alarm probability is evaluated using an independent \(H_0\) audit set.

## Notes

This protocol is used to avoid calibration/test leakage and to ensure fair fixed-\(P_{\mathrm{fa}}\) comparisons among different detectors.
