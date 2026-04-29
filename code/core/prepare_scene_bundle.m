function bundle = prepare_scene_bundle(cfg, snrDb, counts)
% counts struct may contain:
% trainH0, trainH1, calibH0, testH0, testH1, auditH0

if nargin < 3 || isempty(counts)
    counts = struct( ...
        'trainH0', cfg.trainH0, ...
        'trainH1', cfg.trainH1, ...
        'calibH0', cfg.calibH0_formal, ...
        'testH0',  cfg.testH0, ...
        'testH1',  cfg.testH1, ...
        'auditH0', cfg.auditH0_formal);
else
    if ~isfield(counts, 'trainH0'); counts.trainH0 = cfg.trainH0; end
    if ~isfield(counts, 'trainH1'); counts.trainH1 = cfg.trainH1; end
    if ~isfield(counts, 'calibH0'); counts.calibH0 = cfg.calibH0_formal; end
    if ~isfield(counts, 'testH0');  counts.testH0  = cfg.testH0; end
    if ~isfield(counts, 'testH1');  counts.testH1  = cfg.testH1; end
    if ~isfield(counts, 'auditH0'); counts.auditH0 = cfg.auditH0_formal; end
end

trainH0 = generate_spd_field_scene(counts.trainH0, 0, snrDb, cfg);
trainH1 = generate_spd_field_scene(counts.trainH1, 1, snrDb, cfg);
calibH0 = generate_spd_field_scene(counts.calibH0, 0, snrDb, cfg);
testH0  = generate_spd_field_scene(counts.testH0,  0, snrDb, cfg);
testH1  = generate_spd_field_scene(counts.testH1,  1, snrDb, cfg);
auditH0 = generate_spd_field_scene(counts.auditH0, 0, snrDb, cfg);

bundle.trainH0 = build_structure_field_set_from_spd_scene(trainH0);
bundle.trainH1 = build_structure_field_set_from_spd_scene(trainH1);
bundle.calibH0 = build_structure_field_set_from_spd_scene(calibH0);
bundle.testH0  = build_structure_field_set_from_spd_scene(testH0);
bundle.testH1  = build_structure_field_set_from_spd_scene(testH1);
bundle.auditH0 = build_structure_field_set_from_spd_scene(auditH0);

bundle.ref0 = estimate_reference_field_karcher_from_cells(bundle.trainH0, cfg);
bundle.ref1 = estimate_reference_field_karcher_from_cells(bundle.trainH1, cfg);
end