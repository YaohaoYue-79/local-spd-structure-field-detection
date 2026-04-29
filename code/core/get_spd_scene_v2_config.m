function cfg = get_spd_scene_v2_config()
% Formal experiment config for the local-SPD-structure-field detector.
% Public figure titles should use cfg.scenePublicName instead of internal scene codes.

cfg = struct();
coreDir = fileparts(mfilename('fullpath'));
pkgRoot = fileparts(coreDir);

% =========================
% public labels
% =========================
cfg.packageRoot = pkgRoot;
cfg.sceneInternalName = 'j04_d006';
cfg.scenePublicName = 'Main structured-locality detection scene';
cfg.scenePublicDescription = ['Main detection scene with matched global low-order cues ' ...
    'and discriminative local structural organization'];
cfg.boundaryScenePublicName = ...
    'Boundary auxiliary scene with weakened inter-class structural separation';

cfg.methodLabels = struct( ...
    'full', 'Proposed detector', ...
    'uniform_weight', 'Uniform-weight variant', ...
    'global_only', 'Global-pooling variant');

% =========================
% dimensions and seeds
% =========================
cfg.patchFreq = 32;
cfg.patchTime = 32;

cfg.seeds = 101:105;
cfg.quickSNR = -12;
cfg.mainSNRs = -20:2:0;
cfg.representativeSNRs = [-16, -12, -8];

cfg.targetPfaList = [1e-2, 1e-3];

% =========================
% sample counts
% =========================
cfg.trainH0 = 120;
cfg.trainH1 = 120;

% Independent H0 calibration for threshold estimation
cfg.calibH0_quick  = 5000;
cfg.calibH0_sanity = 10000;
cfg.calibH0_formal = 20000;

% Test sets for ROC / AUC / Pd
cfg.testH0  = 500;
cfg.testH1  = 500;

% Independent large-H0 audit set for achieved-Pfa validation
cfg.auditH0_formal = 20000;

cfg.sampleSizeGrid = [10, 20, 40, 80, 160];

% =========================
% output root
% =========================
cfg.outRoot = fullfile(pkgRoot, 'results_spd_scene_formal');

% =========================
% scene parameters
% =========================
cfg.lambda1 = 1.80;
cfg.lambda2 = 0.55;
cfg.minEig = 1e-4;

cfg.thetaBg1_deg = -55;
cfg.thetaBg2_deg = -15;
cfg.thetaBg3_deg =  35;
cfg.thetaBg4_deg =  70;

% Main class-defining structural separation:
% this must remain FIXED across SNR in the formal 6.3 main experiment.
cfg.thetaDiscBase_deg = 0;
cfg.thetaDiscSep_deg  = 44;

cfg.islandCenters = [ 8  8;
                     12 22;
                     23 14];
cfg.islandRadius = 3.2;
cfg.islandAmp = [1.00, 0.82, 0.68];

cfg.logPerturbAmp_bg   = 0.025;
cfg.logPerturbAmp_disc = 0.006;
cfg.rotJitterBgDeg     = 4.0;
cfg.rotJitterDiscDeg   = 0.4;

cfg.thetaPool_deg = [-75, -45, -15, 15, 45, 75];
cfg.numDistractors = 6;
cfg.distractorRadius = 2.2;
cfg.distractorAmpMin = 0.22;
cfg.distractorAmpMax = 0.48;
cfg.distractorRotJitterDeg = 16.0;
cfg.logPerturbAmp_distr = 0.020;

% =========================
% SNR-to-difficulty mapping for the formal main experiment
% IMPORTANT:
% 1) SNR changes nuisance/background difficulty only.
% 2) SNR must NOT change the scene-defining class separation itself.
% 3) Therefore, thetaDiscSep_deg and islandAmp stay fixed across SNR.
% =========================
cfg.snrReferenceDb = -12;
cfg.snrScaleSlopeDb = 20;

% Exponents controlling how nuisance/background difficulty grows
% as SNR decreases away from the reference operating point.
cfg.snrBgPerturbExponent         = 0.45;
cfg.snrBgJitterExponent          = 0.35;
cfg.snrDistractorPerturbExponent = 0.50;
cfg.snrDistractorAmpExponent     = 0.35;

% Clamp to avoid unrealistic tails when sweeping from -20 dB to 0 dB.
cfg.snrFactorClamp = [0.75, 2.50];

% =========================
% detector parameters
% =========================
cfg.blockSize = 8;
cfg.blockStride = 4;
cfg.topFrac = 0.20;
cfg.aggAlpha = 0.65;
cfg.weightSmoothSigma = 1.0;
cfg.weightEps = 1e-12;
cfg.poolEps   = 1e-12;

cfg.karcherTol = 1e-6;
cfg.karcherMaxIter = 30;

% =========================
% parameter grids for formal experiments
% =========================
cfg.blockSizeGrid = [4, 6, 8, 10];
cfg.topFracGrid = [0.10, 0.20, 0.30, 0.40];
cfg.aggAlphaGrid = [0.20, 0.40, 0.60, 0.80];

% local-structure count perturbations
cfg.localStructureCountSpecs = struct([]);
cfg.localStructureCountSpecs(1).publicName = 'Few discriminative local structures';
cfg.localStructureCountSpecs(1).islandCenters = [8 8; 23 14];
cfg.localStructureCountSpecs(1).islandAmp = [1.00, 0.70];
cfg.localStructureCountSpecs(1).numDistractors = 4;

cfg.localStructureCountSpecs(2).publicName = 'Main local-structure count';
cfg.localStructureCountSpecs(2).islandCenters = cfg.islandCenters;
cfg.localStructureCountSpecs(2).islandAmp = cfg.islandAmp;
cfg.localStructureCountSpecs(2).numDistractors = cfg.numDistractors;

cfg.localStructureCountSpecs(3).publicName = 'Many discriminative local structures';
cfg.localStructureCountSpecs(3).islandCenters = [8 8; 12 22; 23 14; 20 25];
cfg.localStructureCountSpecs(3).islandAmp = [1.00, 0.82, 0.68, 0.55];
cfg.localStructureCountSpecs(3).numDistractors = 8;

% structural-strength perturbations near the main scene
cfg.structuralStrengthSpecs = struct([]);
cfg.structuralStrengthSpecs(1).publicName = 'Slightly stronger structural stability';
cfg.structuralStrengthSpecs(1).rotJitterDiscDeg = 0.2;
cfg.structuralStrengthSpecs(1).logPerturbAmp_disc = 0.004;
cfg.structuralStrengthSpecs(1).thetaDiscSep_deg = 46;

cfg.structuralStrengthSpecs(2).publicName = cfg.scenePublicName;
cfg.structuralStrengthSpecs(2).rotJitterDiscDeg = cfg.rotJitterDiscDeg;
cfg.structuralStrengthSpecs(2).logPerturbAmp_disc = cfg.logPerturbAmp_disc;
cfg.structuralStrengthSpecs(2).thetaDiscSep_deg = cfg.thetaDiscSep_deg;

cfg.structuralStrengthSpecs(3).publicName = 'Slightly weaker structural stability';
cfg.structuralStrengthSpecs(3).rotJitterDiscDeg = 0.7;
cfg.structuralStrengthSpecs(3).logPerturbAmp_disc = 0.010;
cfg.structuralStrengthSpecs(3).thetaDiscSep_deg = 42;

cfg.structuralStrengthSpecs(4).publicName = cfg.boundaryScenePublicName;
cfg.structuralStrengthSpecs(4).rotJitterDiscDeg = 0.7;
cfg.structuralStrengthSpecs(4).logPerturbAmp_disc = 0.010;
cfg.structuralStrengthSpecs(4).thetaDiscSep_deg = 40;

% noise robustness specs (field-level perturbation hooks)
cfg.noiseSpecs = struct([]);
noiseNames = {'Gaussian background perturbation', 'Laplacian background perturbation', ...
    'Impulsive background perturbation', 'Heavy-tailed background perturbation'};
noiseKinds = {'gaussian', 'laplacian', 'impulsive', 'student_t'};
noiseScales = [0.010, 0.010, 0.012, 0.012];
for i = 1:numel(noiseNames)
    cfg.noiseSpecs(i).publicName = noiseNames{i};
    cfg.noiseSpecs(i).kind = noiseKinds{i};
    cfg.noiseSpecs(i).scale = noiseScales(i);
end
end
