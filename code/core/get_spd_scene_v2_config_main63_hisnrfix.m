function cfg = get_spd_scene_v2_config_main63_hisnrfix()
% Patch config for Section 6.3 high-SNR rerun.
% Goal: rerun only -8:2:0 dB with the same seeds and detector,
% but without the artificial plateau caused by a tight lower clamp.

cfg = get_spd_scene_v2_config();

% Separate result root: do not pollute the original formal result tree.
cfg.outRoot = fullfile(cfg.packageRoot, 'results_spd_scene_formal_patch63_hisnrfix');

% Only rerun the high-SNR tail.
cfg.mainSNRs = -8:2:0;

% For ROC storage in this patch, -8 dB is the only representative point.
% (The original -16/-12 ROC results stay in the old result folder.)
cfg.representativeSNRs = -8;

% Keep the same reference law (reference at -12 dB, same slope),
% but widen the clamp so that -8:-2:0 dB no longer collapse.
cfg.snrFactorClamp = [0.05, 20.0];

% Metadata tag.
cfg.scenePublicDescription = [cfg.scenePublicDescription, ' (6.3 high-SNR rerun without plateau clamp)'];
end
