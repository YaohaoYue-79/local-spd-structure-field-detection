function [detailTable, rocStruct] = evaluate_method_set(bundle, cfg, methodSpecs)
nMethods = numel(methodSpecs);
rows = cell(nMethods, 10);
rocStruct = struct([]);

for i = 1:nMethods
    spec = methodSpecs(i);

    Wmap = compute_weight_map_sep_disp(bundle.trainH0, bundle.trainH1, ...
        bundle.ref0, bundle.ref1, cfg, spec.name);

    scoresCal = score_field_set(bundle.calibH0, bundle.ref0, bundle.ref1, Wmap, cfg, spec);

    % Main test scores: used for ROC/AUC/Pd
    scores0_test = score_field_set(bundle.testH0, bundle.ref0, bundle.ref1, Wmap, cfg, spec);
    scores1_test = score_field_set(bundle.testH1, bundle.ref0, bundle.ref1, Wmap, cfg, spec);

    % Independent H0 audit scores: used only for achieved-Pfa validation
    scores0_audit = score_field_set(bundle.auditH0, bundle.ref0, bundle.ref1, Wmap, cfg, spec);

    thr1 = calibrate_threshold_h0(scoresCal, cfg.targetPfaList(1));
    thr2 = calibrate_threshold_h0(scoresCal, cfg.targetPfaList(2));

    auc  = compute_auc_from_scores(scores0_test, scores1_test);
    pd1  = mean(scores1_test > thr1);
    pd2  = mean(scores1_test > thr2);

    % Achieved-Pfa must be audited on an independent large-H0 set.
    pfa1 = mean(scores0_audit > thr1);
    pfa2 = mean(scores0_audit > thr2);

    rows(i,:) = { ...
        spec.name, spec.label, auc, pd1, pd2, pfa1, pfa2, ...
        thr1, thr2, numel(scoresCal)};

    rocStruct(i).name   = spec.name;
    rocStruct(i).label  = spec.label;
    rocStruct(i).scores0 = scores0_test;
    rocStruct(i).scores1 = scores1_test;
end

detailTable = cell2table(rows, 'VariableNames', ...
    {'MethodName','MethodLabel','AUC','Pd_Pfa1e2','Pd_Pfa1e3', ...
     'AchPfa1e2','AchPfa1e3','Thr1e2','Thr1e3','NumCalH0'});
end