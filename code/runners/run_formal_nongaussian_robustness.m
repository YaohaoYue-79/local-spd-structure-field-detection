function run_formal_nongaussian_robustness()
setup_paths_local();
ensure_local_pool_fast(4);

cfg = get_spd_scene_v2_config();
outDir = fullfile(cfg.outRoot, 'formal_nongaussian_robustness');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
methodSpecs = default_method_specs('main');
allRows = table();

for iseed = 1:numel(cfg.seeds)
    seed = cfg.seeds(iseed);
    for i = 1:numel(cfg.noiseSpecs)
        cacheFile = fullfile(cacheDir, sprintf('seed_%03d_noise_%02d.mat', seed, i));
        out = maybe_load_or_run_case(cacheFile, @() run_one_case(cfg, methodSpecs, seed, i));

        T = out.T;
        T.Seed = repmat(seed, height(T), 1);
        T.NoiseName = repmat(string(cfg.noiseSpecs(i).publicName), height(T), 1);
        T.GroupLabel = repmat(string(cfg.noiseSpecs(i).publicName), height(T), 1);
        allRows = [allRows; T]; %#ok<AGROW>
        fprintf('Done seed=%d, noise=%s\n', seed, cfg.noiseSpecs(i).publicName);
    end
end

writetable(allRows, fullfile(outDir, 'nongaussian_detail.csv'));
meanT = groupsummary(allRows, {'NoiseName','MethodName','MethodLabel'}, 'mean', ...
    {'AUC','Pd_Pfa1e2','Pd_Pfa1e3','AchPfa1e2','AchPfa1e3'});
writetable(meanT, fullfile(outDir, 'nongaussian_summary.csv'));
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_one_case(cfg, methodSpecs, seed, idx)
rng(seed, 'twister');
bundle0 = prepare_scene_bundle(cfg, cfg.quickSNR);
ns = cfg.noiseSpecs(idx);
bundle = bundle0;
bundle.calibH0 = apply_noise_model_to_field_set(bundle.calibH0, ns, cfg);
bundle.testH0  = apply_noise_model_to_field_set(bundle.testH0,  ns, cfg);
bundle.testH1  = apply_noise_model_to_field_set(bundle.testH1,  ns, cfg);
bundle.auditH0 = apply_noise_model_to_field_set(bundle.auditH0, ns, cfg);
[T, ~] = evaluate_method_set(bundle, cfg, methodSpecs);
out = struct('T', T);
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
