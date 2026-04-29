function run_formal_main_performance()
setup_paths_local();
ensure_local_pool_fast(4);

cfg = get_spd_scene_v2_config();
outDir = fullfile(cfg.outRoot, 'formal_main_performance');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end

methodSpecs = default_method_specs('main');
allRows = table();
rocStore = containers.Map('KeyType','char','ValueType','any');

for s = reshape(cfg.representativeSNRs,1,[])
    rocStore(num2str(s)) = {};
end

for iseed = 1:numel(cfg.seeds)
    seed = cfg.seeds(iseed);
    for snrDb = cfg.mainSNRs
        cacheFile = fullfile(cacheDir, sprintf('seed_%03d_snr_%+03d.mat', seed, snrDb));
        out = maybe_load_or_run_case(cacheFile, @() run_one_case(cfg, methodSpecs, seed, snrDb));

        T = out.T;
        T.Seed = repmat(seed, height(T), 1);
        T.SNR_dB = repmat(snrDb, height(T), 1);
        T.GroupLabel = repmat(string(sprintf('SNR=%+d dB', snrDb)), height(T), 1);
        allRows = [allRows; T]; %#ok<AGROW>

        if any(cfg.representativeSNRs == snrDb)
            tmp = rocStore(num2str(snrDb));
            tmp{end+1} = out.rocStruct;
            rocStore(num2str(snrDb)) = tmp;
        end

        fprintf('Done seed=%d, SNR=%+d dB\n', seed, snrDb);
    end
end

writetable(allRows, fullfile(outDir, 'main_performance_detail.csv'));

meanT = groupsummary(allRows, {'SNR_dB','MethodName','MethodLabel'}, 'mean', ...
    {'AUC','Pd_Pfa1e2','Pd_Pfa1e3','AchPfa1e2','AchPfa1e3'});
writetable(meanT, fullfile(outDir, 'main_performance_summary.csv'));
save(fullfile(outDir, 'main_performance_rocstore.mat'), 'rocStore', '-v7.3');
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_one_case(cfg, methodSpecs, seed, snrDb)
rng(seed, 'twister');
bundle = prepare_scene_bundle(cfg, snrDb);
[T, rocStruct] = evaluate_method_set(bundle, cfg, methodSpecs);
out = struct('T', T, 'rocStruct', rocStruct);
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
