function merge_formal_main_performance_hisnrfix()
setup_paths_local();

origCfg  = get_spd_scene_v2_config();
patchCfg = get_spd_scene_v2_config_main63_hisnrfix();

oldDir    = fullfile(origCfg.outRoot,  'formal_main_performance');
patchDir  = fullfile(patchCfg.outRoot, 'formal_main_performance');
mergedDir = fullfile(patchCfg.outRoot, 'formal_main_performance_merged');
if ~exist(mergedDir, 'dir'); mkdir(mergedDir); end

oldDetail   = readtable(fullfile(oldDir,   'main_performance_detail.csv'));
patchDetail = readtable(fullfile(patchDir, 'main_performance_detail.csv'));

% Keep original low/mid SNR range from the old experiment.
oldKeep = oldDetail.SNR_dB <= -10;
oldPart = oldDetail(oldKeep, :);

% Keep only the rerun high-SNR tail from the patch experiment.
patchKeep = ismember(patchDetail.SNR_dB, patchCfg.mainSNRs);
patchPart = patchDetail(patchKeep, :);

mergedDetail = [oldPart; patchPart];
mergedDetail = sortrows(mergedDetail, {'SNR_dB','MethodName','Seed'});
writetable(mergedDetail, fullfile(mergedDir, 'main_performance_detail_merged.csv'));

mergedSummary = groupsummary(mergedDetail, {'SNR_dB','MethodName','MethodLabel'}, 'mean', ...
    {'AUC','Pd_Pfa1e2','Pd_Pfa1e3','AchPfa1e2','AchPfa1e3'});
writetable(mergedSummary, fullfile(mergedDir, 'main_performance_summary_merged.csv'));

% Merge ROC stores: keep -16 and -12 from old, replace -8 by patch if available.
rocStore = containers.Map('KeyType','char','ValueType','any');
oldRocFile   = fullfile(oldDir,   'main_performance_rocstore.mat');
patchRocFile = fullfile(patchDir, 'main_performance_rocstore.mat');

if exist(oldRocFile, 'file')
    S = load(oldRocFile, 'rocStore');
    oldRoc = S.rocStore;
    wantedOld = [-16, -12];
    for k = 1:numel(wantedOld)
        kk = num2str(wantedOld(k));
        if isKey(oldRoc, kk)
            rocStore(kk) = oldRoc(kk);
        end
    end
end

if exist(patchRocFile, 'file')
    S = load(patchRocFile, 'rocStore');
    patchRoc = S.rocStore;
    if isKey(patchRoc, '-8')
        rocStore('-8') = patchRoc('-8');
    end
end

save(fullfile(mergedDir, 'main_performance_rocstore_merged.mat'), 'rocStore', '-v7.3');

fprintf('Merged main-performance results saved to: %s\n', mergedDir);
end

function setup_paths_local()
root = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(root, 'core'));
addpath(fullfile(root, 'plots'));
end
