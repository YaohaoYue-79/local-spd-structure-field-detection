# Pooling Sensitivity Configuration

## Purpose

This experiment evaluates the sensitivity of the proposed detector to block-wise pooling parameters.

## Parameters of Interest

| Parameter | Description |
|---|---|
| blockSize | Spatial size of each pooling block |
| blockStride | Stride between neighboring blocks |
| topFrac | Fraction of top-response blocks used in top-block pooling |
| aggAlpha | Aggregation coefficient between global mean and top-block mean |

## Default Values

| Parameter | Value |
|---|---:|
| blockSize | 8 |
| blockStride | 4 |
| topFrac | 0.2 |
| aggAlpha | 0.65 |

## Shared Protocol

All pooling-sensitivity experiments use the same fixed-\(P_{\mathrm{fa}}\) calibration protocol and mutually independent training, calibration, testing, and audit sets.

## Reported Metrics

- AUC
- \(P_d\) at fixed-\(P_{\mathrm{fa}}\) operating points
- achieved \(P_{\mathrm{fa}}\)

## Notes

This experiment is used to assess whether the proposed detector is overly sensitive to a particular pooling-parameter choice.
