function T = detect_structure_field(F, ref0, ref1, Wmap, cfg, methodSpec)
Delta = compute_delta_map_airm(F, ref0, ref1, methodSpec.metric);
[T, ~] = aggregate_blockwise_scores(Delta, Wmap, cfg, methodSpec.name);
end
