function cfg2 = apply_scene_override(cfg, overrideSpec)
% override fields can include any config entries used by the scene generator.
cfg2 = cfg;
fields = fieldnames(overrideSpec);
for i = 1:numel(fields)
    cfg2.(fields{i}) = overrideSpec.(fields{i});
end
end
