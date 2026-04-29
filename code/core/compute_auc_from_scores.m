function auc = compute_auc_from_scores(scores0, scores1)
scores = [scores0(:); scores1(:)];
labels = [zeros(numel(scores0),1); ones(numel(scores1),1)];
[~, idx] = sort(scores, 'descend');
labels = labels(idx);
P = sum(labels==1);
N = sum(labels==0);
tp = cumsum(labels==1) / P;
fp = cumsum(labels==0) / N;
auc = trapz(fp, tp);
auc = max(0, min(1, auc));
end
