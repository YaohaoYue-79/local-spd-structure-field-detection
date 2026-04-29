# Ablation Configuration

## Purpose

This experiment evaluates the contribution of discriminative weighting and block-wise robust pooling.

## Variants

| Variant | Description |
|---|---|
| Proposed detector | Uses local SPD structure fields, AIRM comparison, discriminative weighting, and block-wise robust pooling |
| Uniform-weight variant | Replaces the discriminative weight map with uniform weights |
| Global-pooling variant | Uses global aggregation without top-block emphasis |

## Shared Components

All variants share:

- local SPD structure-field representation;
- pointwise Karcher mean reference fields;
- AIRM distance-difference map;
- fixed-\(P_{\mathrm{fa}}\) calibration protocol;
- identical random seeds and data splits.

## Reported Metrics

- AUC
- \(P_d\) at \(P_{\mathrm{fa}}=10^{-2}\)
- \(P_d\) at \(P_{\mathrm{fa}}=10^{-3}\)
- achieved \(P_{\mathrm{fa}}\)
- paired performance differences

## Notes

This ablation is designed to isolate the effects of weighting and pooling. It does not change the local SPD structure-field representation itself.
