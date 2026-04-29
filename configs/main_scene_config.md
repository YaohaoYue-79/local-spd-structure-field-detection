# Main Scene Configuration

## Public Scene Name

Main structured-locality detection scene

## Random Seeds

101, 102, 103, 104, 105

## Nominal SNR-Index Sweep

-20:2:0 dB

## Fixed-\(P_{\mathrm{fa}}\) Operating Points

- \(P_{\mathrm{fa}}=10^{-2}\)
- \(P_{\mathrm{fa}}=10^{-3}\)

## Sample Counts

| Split | Count |
|---|---:|
| trainH0 | 120 |
| trainH1 | 120 |
| calibH0_formal | 20000 |
| testH0 | 500 |
| testH1 | 500 |
| auditH0_formal | 20000 |

## Patch and SPD Settings

| Parameter | Value |
|---|---:|
| patchFreq | 32 |
| patchTime | 32 |
| minEig | \(10^{-4}\) |

## Class-Defining Local Structures

| Parameter | Value |
|---|---:|
| thetaDiscSep_deg | 44 |
| rotJitterDiscDeg | 0.4 |
| logPerturbAmp_disc | 0.006 |
| island radius | 3.2 |
| island amplitudes | 1.00, 0.82, 0.68 |
| island centers | (8,8), (12,22), (23,14) |

## Distractors

| Parameter | Value |
|---|---:|
| number of distractors | 6 |
| distractor radius | 2.2 |
| distractor amplitude range | 0.22-0.48 |
| distractorRotJitterDeg | 16 |
| distractor orientation set | -75, -45, -15, 15, 45, 75 degrees |

## Pooling Settings

| Parameter | Value |
|---|---:|
| blockSize | 8 |
| blockStride | 4 |
| topFrac | 0.2 |
| aggAlpha | 0.65 |

## Weight Map and Reference Estimation

| Parameter | Value |
|---|---:|
| weightSmoothSigma | 1 |
| Karcher tolerance | \(10^{-6}\) |
| Karcher maxIter | 30 |

## Notes

The nominal SNR index is used as a nuisance/background difficulty index. It does not modify the class-defining structural separation or the amplitudes of the discriminative local structures.
