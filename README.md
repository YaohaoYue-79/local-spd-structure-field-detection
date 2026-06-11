# Local SPD Structure-Field Detection

This repository contains the reproducibility package for the accepted manuscript:

**Information-Geometric Detection via Local SPD Structure Fields in the Time-Frequency Domain**

## Overview

This project implements an information-geometric detector based on local symmetric positive definite (SPD) structure fields. The method constructs local SPD structure fields, estimates class-conditional pointwise Karcher mean reference fields under the affine-invariant Riemannian metric (AIRM), computes local distance-difference evidence, and performs fixed-\(P_{\mathrm{fa}}\) threshold calibration using an independent \(H_0\) calibration set.

The experiments are conducted on procedurally generated controlled SPD-field samples. No external dataset is used in the main experiments. The complete experimental data can be regenerated from the released scene-generation scripts, configuration notes, and random seeds.

## Repository Structure

```text
code/core/          Core MATLAB functions for scene generation, detector evaluation, scoring, and calibration
code/plots/         MATLAB plotting scripts for manuscript figures
code/runners/       MATLAB scripts for formal and auxiliary experiments
configs/            Experiment configuration notes
docs/               Experimental notes and protocol documentation
environment/        Software environment information
figures/            Final manuscript figures
results_csv/        CSV files supporting the reported figures and tables
seeds/              Random seeds used in formal experiments
```

## Main Manuscript Experiments

The experiments reported in the main manuscript are:

1. **Main performance evaluation**
   - Nominal SNR/SCR-like index sweep under the main structured-locality detection scene.
   - Supports manuscript Figures 2 and 3.

2. **Baseline comparison**
   - Comparison with global-energy, pooled-covariance, template-correlation, and structure-field baselines.
   - Supports manuscript Figure 4 and Table 3.

3. **Ablation analysis and paired-difference analysis**
   - Comparison among the proposed detector, the uniform-weight variant, the global-pooling variant, and the double-ablation variant.
   - Supports manuscript Figure 5 and Table 4.

4. **Structural perturbation experiment**
   - Robustness evaluation under structural-strength perturbations around the main scene.
   - Supports manuscript Figure 6.

5. **Non-Gaussian robustness experiment**
   - Robustness evaluation under Gaussian, Laplace-distributed, impulsive, and heavy-tailed field-level perturbations.
   - Supports manuscript Figure 7.

## Supplementary and Auxiliary Experiments

The repository also includes additional experiments that are used as supplementary or auxiliary analyses:

- **Pooling sensitivity analysis**
  - Evaluates sensitivity to block-wise pooling parameters such as block size, block stride, top-block fraction, and aggregation coefficient.

- **Sample-size sensitivity analysis**
  - Evaluates sensitivity to the number of training samples used for reference-field estimation and discriminative weight-map construction.

These supplementary experiments are not the main focus of the manuscript but are included to support reproducibility and additional robustness checks.

## Main-Performance Merge Note

The final main-performance results use merged CSV files.

During the first run of the main experiment, the high nominal SNR/SCR-like index range from \(-8\) dB to \(0\) dB was affected by clipping due to the upper and lower bounds in the nuisance/background difficulty mapping. A corrected high-index extension was therefore run for the range \(-8:2:0\) dB. The corrected high-index results were then merged with the original main-performance CSV files to obtain the final nominal SNR/SCR-like index sweep used in the manuscript.

Relevant files include:

```text
code/runners/run_formal_main_performance.m
code/runners/run_formal_main_performance_hisnrfix.m
code/runners/merge_formal_main_performance_hisnrfix.m
results_csv/formal_main_performance/main_performance_detail_merged.csv
results_csv/formal_main_performance/main_performance_summary_merged.csv
```

The files with the suffix `merged` correspond to the final main-performance results used for manuscript Figures 2 and 3.

## Figures

The `figures/` directory contains the final figures used or prepared for the manuscript. Some file names retain internal development labels from the experiment-generation stage. The corresponding manuscript figure numbers are listed below:

```text
method_overview.pdf
    Manuscript Figure 1: Method overview of the proposed local SPD structure-field detector

fig1_main_auc_vs_nominal_snr_index_ci.pdf / .png
    Manuscript Figure 2: AUC versus nominal SNR/SCR-like index

fig2_main_fixed_pfa_vs_nominal_snr_index_ci.pdf / .png
    Manuscript Figure 3: Fixed-Pfa detection probability curves

fig3_baseline_comparison_ci.pdf / .png
    Manuscript Figure 4: Baseline comparison

fig4_ablation_analysis_main.pdf / .png
    Manuscript Figure 5: Ablation analysis

fig5_structure_strength_perturbation_main.pdf / .png
    Manuscript Figure 6: Structural perturbation robustness

fig6_nongaussian_main_figure.pdf / .png
    Manuscript Figure 7: Non-Gaussian robustness
## Results CSV Files

The `results_csv/` directory contains the CSV files supporting the reported figures and tables:

```text
results_csv/formal_main_performance/
results_csv/formal_baselines/
results_csv/formal_ablation/
results_csv/formal_local_structure_perturbation/
results_csv/formal_nongaussian_robustness/
results_csv/formal_pooling_sensitivity/
results_csv/formal_sample_size/
```

The first five folders correspond to the main manuscript experiments. The pooling-sensitivity and sample-size folders correspond to supplementary analyses.

## Fixed-\(P_{\mathrm{fa}}\) Protocol

All fixed-\(P_{\mathrm{fa}}\) evaluations use an independent \(H_0\) calibration set for threshold estimation and an independent \(H_0\) audit set for achieved-\(P_{\mathrm{fa}}\) validation. This protocol is used to avoid calibration/test leakage and to ensure fair fixed-\(P_{\mathrm{fa}}\) comparisons among different detectors.

## Random Seeds

The random seeds used in the formal experiments are provided in:

```text
seeds/random_seeds.txt
```

## Environment

Software environment notes are provided in:

```text
environment/matlab_version.txt
```

The experiments and plotting scripts were developed for MATLAB. Some formal experiments may be computationally intensive.

## Data Availability

The data used in this study are procedurally generated controlled SPD-field samples. Since no external dataset is used, the complete experimental data can be regenerated from the released scene-generation scripts, configuration notes, and random seeds. The CSV files in this repository provide the per-run and summary results supporting the figures and tables reported in the manuscript.

## Status

This repository provides the reproducibility package for the accepted manuscript **“Information-Geometric Detection via Local SPD Structure Fields in the Time-Frequency Domain”**. Some filenames retain internal development labels for traceability; the public scene name used in the manuscript is **“Main structured-locality detection scene”**.
