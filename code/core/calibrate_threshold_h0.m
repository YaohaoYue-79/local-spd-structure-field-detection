function thr = calibrate_threshold_h0(scoresCal, targetPfa)
scores = sort(scoresCal(:), 'ascend');
n = numel(scores);
k = ceil((1 - targetPfa) * n);
k = min(max(k, 1), n);
thr = scores(k);
end
