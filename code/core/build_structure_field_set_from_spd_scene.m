function fields = build_structure_field_set_from_spd_scene(sceneCells)
% Keeps the direct-SPD field format while enforcing symmetry.

n = numel(sceneCells);
fields = cell(1, n);
for i = 1:n
    F = sceneCells{i};
    H = size(F,1);
    W = size(F,2);
    G = zeros(H,W,2,2);
    for r = 1:H
        for c = 1:W
            C = squeeze(F(r,c,:,:));
            G(r,c,:,:) = (C + C.') / 2;
        end
    end
    fields{i} = G;
end
end
