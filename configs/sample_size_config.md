# Sample Size Sensitivity Configuration

## Purpose

This experiment evaluates the sensitivity of the detector to the number of training samples used for reference-field estimation and discriminative weight-map construction.

## Evaluated Component

The main focus is the effect of training sample size on:

- pointwise Karcher mean reference-field estimation;
- discriminative weight-map construction;
- fixed-\(P_{\mathrm{fa}}\) detection performance.

## Shared Protocol

For each sample-size setting, the detector is evaluated using the same fixed-\(P_{\mathrm{fa}}\) calibration protocol. The threshold is calibrated using an independent \(H_0\) calibration set and achieved \(P_{\mathrm{fa}}\) is validated using an independent \(H_0\) audit set.

## Reported Metrics

- AUC
- \(P_d\) at fixed-\(P_{\mathrm{fa}}\) operating points
- achieved \(P_{\mathrm{fa}}\)

## Notes

This experiment is used to examine the stability of reference-field estimation and discriminative weighting under different training-sample sizes.
