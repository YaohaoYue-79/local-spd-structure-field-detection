function run_formal_pooling_sensitivity()
setup_paths_local();
ensure_local_pool_fast(4);

cfg0 = get_spd_scene_v2_config();
outDir = fullfile(cfg0.outRoot, 'formal_pooling_sensitivity');
cacheDir = fullfile(outDir, 'case_cache');
if ~exist(outDir, 'dir'); mkdir(outDir); end
if ~exist(cacheDir, 'dir'); mkdir(cacheDir); end
methodSpecs = default_method_specs('main');
allRows = table();

paramBlocks = { ...
    struct('name','blockSize','grid',cfg0.blockSizeGrid), ...
    struct('name','topFrac','grid',cfg0.topFracGrid), ...
    struct('name','aggAlpha','grid',cfg0.aggAlphaGrid)};

for p = 1:numel(paramBlocks)
    paramName = paramBlocks{p}.name;
    gridVals = paramBlocks{p}.grid;
    for iseed = 1:numel(cfg0.seeds)
        seed = cfg0.seeds(iseed);
        for v = gridVals
            cacheFile = fullfile(cacheDir, sprintf('%s_seed_%03d_val_%s.mat', ...
                paramName, seed, sanitize_num_for_filename(v)));
            out = maybe_load_or_run_case(cacheFile, @() run_one_case(cfg0, methodSpecs, seed, paramName, v));

            T = out.T;
            T.Seed = repmat(seed, height(T), 1);
            T.ParamName = repmat(string(paramName), height(T), 1);
            T.ParamValue = repmat(v, height(T), 1);
            T.GroupLabel = repmat(string(sprintf('%s=%g', paramName, v)), height(T), 1);
            allRows = [allRows; T]; %#ok<AGROW>
            fprintf('Done %s, seed=%d, value=%g\n', paramName, seed, v);
        end
    end
end

writetable(allRows, fullfile(outDir, 'pooling_sensitivity_detail.csv'));
fprintf('Compute-only phase finished: %s\n', outDir);
end

function out = run_one_case(cfg0, methodSpecs, seed, paramName, v)
rng(seed, 'twister');
cfg = cfg0;
cfg.(paramName) = v;
bundle = prepare_scene_bundle(cfg, cfg.quickSNR);
out = struct('T', evaluate_method_set(bundle, cfg, methodSpecs));
end

function s = sanitize_num_for_filename(v)
s = regexprep(sprintf('%.6g', v), '[^0-9A-Za-z]+', '_');
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
