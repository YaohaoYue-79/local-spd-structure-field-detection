# Structural Perturbation Configuration

## Purpose

This experiment evaluates whether the performance ordering remains stable when the strength and stability of local discriminative structures are perturbed.

## Perturbation Type

Structural-strength perturbation around the main structured-locality detection scene.

## Compared Conditions

| Condition | Description |
|---|---|
| Slightly stronger | Local discriminative structures are slightly strengthened |
| Main | Main structured-locality detection scene |
| Slightly weaker | Local discriminative structures are slightly weakened |
| Boundary auxiliary | Boundary condition used to examine applicability limits |

## Compared Methods

- Proposed detector
- Uniform-weight variant
- Global-pooling variant

## Reported Metrics

- AUC
- \(P_d\) at fixed-\(P_{\mathrm{fa}}\) operating points
- paired differences where applicable

## Notes

This experiment is used to examine stability around the main scene. It is not intended to prove unconditional superiority under all possible local-structure configurations.
