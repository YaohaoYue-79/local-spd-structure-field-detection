function run_formal_ablation()
setup_paths_local();
ensure_local_pool_fast(4);

cfg = get_spd_scene_v2_config();
outDir = fullfile(cfg.outRoot, 'formal_ablation');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
methodSpecs = default_method_specs('ablation');
allRows = table();

for iseed = 1:numel(cfg.seeds)
    seed = cfg.seeds(iseed);
    cacheFile = fullfile(cacheDir, sprintf('seed_%03d.mat', seed));
    out = maybe_load_or_run_case(cacheFile, @() run_one_case(cfg, methodSpecs, seed));

    T = out.T;
    T.Seed = repmat(seed, height(T), 1);
    T.GroupLabel = repmat(string('Representative SNR'), height(T), 1);
    allRows = [allRows; T]; %#ok<AGROW>
    fprintf('Done seed=%d\n', seed);
end

writetable(allRows, fullfile(outDir, 'ablation_detail.csv'));
meanT = groupsummary(allRows, {'MethodName','MethodLabel'}, 'mean', ...
    {'AUC','Pd_Pfa1e2','Pd_Pfa1e3'});
writetable(meanT, fullfile(outDir, 'ablation_summary.csv'));
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_one_case(cfg, methodSpecs, seed)
rng(seed, 'twister');
bundle = prepare_scene_bundle(cfg, cfg.quickSNR);
out = struct('T', evaluate_method_set(bundle, cfg, methodSpecs));
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
