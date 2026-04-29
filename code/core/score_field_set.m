function scores = score_field_set(fieldSet, ref0, ref1, Wmap, cfg, methodSpec)
n = numel(fieldSet);
scores = zeros(n,1);
parfor i = 1:n
    scores(i) = detect_structure_field(fieldSet{i}, ref0, ref1, Wmap, cfg, methodSpec);
end
end
