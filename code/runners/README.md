# Experiment Runners

This directory contains MATLAB runner scripts for the formal and auxiliary experiments.

## Main Manuscript Runners

The following scripts correspond to experiments reported in the main manuscript:

```text
run_formal_main_performance.m
run_formal_baselines.m
run_formal_ablation.m
run_formal_local_structure_perturbation.m
run_formal_nongaussian_robustness.m
```

These scripts support the main performance evaluation, baseline comparison, ablation analysis, structural perturbation experiment, and non-Gaussian robustness experiment.

## Main-Performance High-Index Correction

The final main-performance results use a merged CSV output. During the first run of the main experiment, the high nominal SNR-index range from \(-8\) dB to \(0\) dB was affected by clipping due to the upper and lower bounds in the nuisance/background difficulty mapping. A corrected high-index extension was therefore run for \(-8:2:0\) dB.

The relevant scripts are:

```text
run_formal_main_performance_hisnrfix.m
merge_formal_main_performance_hisnrfix.m
```

The merged output is stored in:

```text
results_csv/formal_main_performance/main_performance_detail_merged.csv
results_csv/formal_main_performance/main_performance_summary_merged.csv
```

These merged files correspond to the final main-performance results used for Figure 1 and Figure 2.

## Supplementary and Auxiliary Runners

The following scripts are included as supplementary or auxiliary analyses:

```text
run_formal_pooling_sensitivity.m
run_formal_sample_size.m
```

These scripts support additional sensitivity analyses and are not the main focus of the manuscript.

## Notes

Some filenames retain internal development labels for traceability. The public scene name used in the manuscript is **Main structured-locality detection scene**.
