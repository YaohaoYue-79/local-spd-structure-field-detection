function run_formal_local_structure_perturbation()
setup_paths_local();
ensure_local_pool_fast(4);

cfg0 = get_spd_scene_v2_config();
outDir = fullfile(cfg0.outRoot, 'formal_local_structure_perturbation');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
methodSpecs = default_method_specs('main');
allRows = table();

for iseed = 1:numel(cfg0.seeds)
    seed = cfg0.seeds(iseed);
    for i = 1:numel(cfg0.localStructureCountSpecs)
        cacheFile = fullfile(cacheDir, sprintf('count_seed_%03d_idx_%02d.mat', seed, i));
        out = maybe_load_or_run_case(cacheFile, @() run_count_case(cfg0, methodSpecs, seed, i));

        T = out.T;
        T.Seed = repmat(seed, height(T), 1);
        T.GroupLabel = repmat(string(cfg0.localStructureCountSpecs(i).publicName), height(T), 1);
        T.PerturbationType = repmat(string('LocalStructureCount'), height(T), 1);
        allRows = [allRows; T]; %#ok<AGROW>
    end
end

for iseed = 1:numel(cfg0.seeds)
    seed = cfg0.seeds(iseed);
    for i = 1:numel(cfg0.structuralStrengthSpecs)
        cacheFile = fullfile(cacheDir, sprintf('strength_seed_%03d_idx_%02d.mat', seed, i));
        out = maybe_load_or_run_case(cacheFile, @() run_strength_case(cfg0, methodSpecs, seed, i));

        T = out.T;
        T.Seed = repmat(seed, height(T), 1);
        T.GroupLabel = repmat(string(cfg0.structuralStrengthSpecs(i).publicName), height(T), 1);
        T.PerturbationType = repmat(string('StructuralStrength'), height(T), 1);
        allRows = [allRows; T]; %#ok<AGROW>
    end
end

writetable(allRows, fullfile(outDir, 'local_structure_perturbation_detail.csv'));
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_count_case(cfg0, methodSpecs, seed, idx)
rng(seed, 'twister');
cfg = cfg0;
cfg.islandCenters = cfg0.localStructureCountSpecs(idx).islandCenters;
cfg.islandAmp = cfg0.localStructureCountSpecs(idx).islandAmp;
cfg.numDistractors = cfg0.localStructureCountSpecs(idx).numDistractors;
bundle = prepare_scene_bundle(cfg, cfg.quickSNR);
out = struct('T', evaluate_method_set(bundle, cfg, methodSpecs));
end

function out = run_strength_case(cfg0, methodSpecs, seed, idx)
rng(seed, 'twister');
cfg = cfg0;
cfg.rotJitterDiscDeg = cfg0.structuralStrengthSpecs(idx).rotJitterDiscDeg;
cfg.logPerturbAmp_disc = cfg0.structuralStrengthSpecs(idx).logPerturbAmp_disc;
cfg.thetaDiscSep_deg = cfg0.structuralStrengthSpecs(idx).thetaDiscSep_deg;
bundle = prepare_scene_bundle(cfg, cfg.quickSNR);
out = struct('T', evaluate_method_set(bundle, cfg, methodSpecs));
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
