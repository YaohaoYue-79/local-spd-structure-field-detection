# Experimental Setup Draft

## 6.1 Experimental setup

The experiments are no longer used to search for a favorable scene. Instead, they are organized around a fixed main scene and a small number of auxiliary perturbation scenes. The goals are fourfold: (i) to establish the main detection performance of the proposed detector, (ii) to isolate the contribution of discriminative weighting and robust local pooling through ablation, (iii) to evaluate sensitivity to sample size and pooling hyperparameters, and (iv) to identify the validity range of the method under local structural perturbations and non-Gaussian backgrounds.

The main scene is referred to as the **main structured-locality detection scene**. Its design follows three constraints. First, all local units remain inside the SPD space so that AIRM distances and Karcher reference estimation remain well defined. Second, simple global low-order cues are kept matched as much as possible, so the scene is not made separable by obvious global energy or pooled-covariance differences. Third, class differences mainly arise from the orientation organization and spatial layout of discriminative local structures. Therefore, the scene is aligned with the object layer of the proposed detector rather than with a single global statistic.

All fixed-Pfa results are obtained with an independent H0 calibration set. ROC curves are produced by threshold sweeping, while Pd@Pfa=10^-2 and Pd@Pfa=10^-3 are obtained from empirical quantiles estimated on the calibration set. Achieved false-alarm rates are always reported as a fairness audit. For non-Gaussian noise experiments, thresholds are recalibrated independently under the corresponding noise condition.

The compared methods are organized into three groups. The first group contains weakened detector variants, namely the uniform-weight and global-pooling variants, which isolate the roles of discriminative weighting and top-local pooling. The second group contains global low-order baselines such as global energy, template-correlation, and pooled-covariance baselines. The third group contains Euclidean and Frobenius structure-field baselines, which retain the same object representation but weaken the geometry used in local comparison.

## 6.2 Why the main scene reveals the advantage of the structural detector

The main scene is not constructed by introducing strong global energy differences, visually obvious mean-spectrum gaps, or a single dominant pooled-covariance cue. Instead, it is designed so that those simpler low-order cues remain broadly matched, while class differences are concentrated in the organization, stability, and spatial arrangement of discriminative local structures. As a result, the main challenge is not a global appearance mismatch, but the recovery of class-specific local structural relations.

This scene is therefore well matched to the detector proposed in this work. The detector does not rely on a single global statistic; it operates on local SPD structure fields, estimates class-conditional pointwise Karcher reference fields under AIRM, forms geometry-consistent local distance-difference evidence, and aggregates that evidence through discriminative weighting and robust block-wise pooling. When discriminative information mainly lives in local structural organization rather than in matched global low-order statistics, the advantage of the proposed structure-field detector becomes visible.

Auxiliary scenes are only used to verify non-accidental behavior and validity boundaries. They are not treated as a second round of scene search. Instead, they are local perturbations around the main scene or boundary scenes with weakened structural separation.
