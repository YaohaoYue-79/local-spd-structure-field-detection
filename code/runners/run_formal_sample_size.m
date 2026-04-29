function run_formal_sample_size()
setup_paths_local();
ensure_local_pool_fast(4);

cfg = get_spd_scene_v2_config();
outDir = fullfile(cfg.outRoot, 'formal_sample_size');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
methodSpecs = default_method_specs('main');
allRows = table();

for iseed = 1:numel(cfg.seeds)
    seed = cfg.seeds(iseed);
    for nTrain = cfg.sampleSizeGrid
        cacheFile = fullfile(cacheDir, sprintf('seed_%03d_train_%04d.mat', seed, nTrain));
        out = maybe_load_or_run_case(cacheFile, @() run_one_case(cfg, methodSpecs, seed, nTrain));

        T = out.T;
        T.Seed = repmat(seed, height(T), 1);
        T.TrainSize = repmat(nTrain, height(T), 1);
        T.GroupLabel = repmat(string(sprintf('Train=%d', nTrain)), height(T), 1);
        allRows = [allRows; T]; %#ok<AGROW>
        fprintf('Done seed=%d, train=%d\n', seed, nTrain);
    end
end

writetable(allRows, fullfile(outDir, 'sample_size_detail.csv'));
meanT = groupsummary(allRows, {'TrainSize','MethodName','MethodLabel'}, 'mean', ...
    {'AUC','Pd_Pfa1e2','Pd_Pfa1e3'});
writetable(meanT, fullfile(outDir, 'sample_size_summary.csv'));
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_one_case(cfg, methodSpecs, seed, nTrain)
rng(seed, 'twister');
counts = struct('trainH0', nTrain, 'trainH1', nTrain, ...
    'calibH0', cfg.calibH0_formal, 'testH0', cfg.testH0, ...
    'testH1', cfg.testH1, 'auditH0', cfg.auditH0_formal);
bundle = prepare_scene_bundle(cfg, cfg.quickSNR, counts);
out = struct('T', evaluate_method_set(bundle, cfg, methodSpecs));
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
