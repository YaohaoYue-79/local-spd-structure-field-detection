function rocMerged = merge_roc_structs(rocCell)
% Merge per-seed ROC score stores into one aggregated ROC store.
% rocCell is a cell array of rocStruct outputs from evaluate_method_set.

if isempty(rocCell)
    rocMerged = struct([]);
    return;
end

base = rocCell{1};
rocMerged = base;
for i = 1:numel(rocMerged)
    s0 = [];
    s1 = [];
    for k = 1:numel(rocCell)
        item = rocCell{k};
        s0 = [s0; item(i).scores0(:)]; %#ok<AGROW>
        s1 = [s1; item(i).scores1(:)]; %#ok<AGROW>
    end
    rocMerged(i).scores0 = s0;
    rocMerged(i).scores1 = s1;
end
end
