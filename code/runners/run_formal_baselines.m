function run_formal_baselines()
setup_paths_local();
ensure_local_pool_fast(4);

cfg = get_spd_scene_v2_config();
outDir = fullfile(cfg.outRoot, 'formal_baselines');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
allRows = table();

mainSpecs = default_method_specs('main');
geomSpecs = default_method_specs('geometry_baselines');
methodSpecs = method_specs_without_duplicates(mainSpecs, geomSpecs);

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

writetable(allRows, fullfile(outDir, 'baseline_detail.csv'));
meanT = groupsummary(allRows, {'MethodName','MethodLabel'}, 'mean', ...
    {'AUC','Pd_Pfa1e2','Pd_Pfa1e3','AchPfa1e2','AchPfa1e3'});
writetable(meanT, fullfile(outDir, 'baseline_summary.csv'));
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_one_case(cfg, methodSpecs, seed)
rng(seed, 'twister');
bundle = prepare_scene_bundle(cfg, cfg.quickSNR);

T1 = evaluate_method_set(bundle, cfg, methodSpecs);
T2 = evaluate_global_low_order_baselines(bundle, cfg);
out = struct('T', [T1; T2]);
end

function T = evaluate_global_low_order_baselines(bundle, cfg)
methodNames = {'global_energy', 'template_correlation', 'pooled_covariance'};
labels = {'Global energy baseline','Template-correlation baseline','Pooled-covariance baseline'};
rows = cell(numel(methodNames), 10);
for i = 1:numel(methodNames)
    scoresCal   = score_global_baseline(bundle.calibH0,  bundle.ref0, bundle.ref1, methodNames{i});
    scores0     = score_global_baseline(bundle.testH0,   bundle.ref0, bundle.ref1, methodNames{i});
    scores1     = score_global_baseline(bundle.testH1,   bundle.ref0, bundle.ref1, methodNames{i});
    scores0aud  = score_global_baseline(bundle.auditH0,  bundle.ref0, bundle.ref1, methodNames{i});
    thr1 = calibrate_threshold_h0(scoresCal, cfg.targetPfaList(1));
    thr2 = calibrate_threshold_h0(scoresCal, cfg.targetPfaList(2));
    rows(i,:) = {methodNames{i}, labels{i}, compute_auc_from_scores(scores0, scores1), ...
        mean(scores1 > thr1), mean(scores1 > thr2), mean(scores0aud > thr1), mean(scores0aud > thr2), thr1, thr2, numel(scoresCal)};
end
T = cell2table(rows, 'VariableNames', {'MethodName','MethodLabel','AUC','Pd_Pfa1e2','Pd_Pfa1e3','AchPfa1e2','AchPfa1e3','Thr1e2','Thr1e3','NumCalH0'});
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
