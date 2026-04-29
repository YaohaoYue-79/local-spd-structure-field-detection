function [T, sList] = aggregate_blockwise_scores(Delta, Wmap, cfg, methodName)
blk = cfg.blockSize;
stp = cfg.blockStride;
H = size(Delta,1);
Wn = size(Delta,2);

switch lower(methodName)
    case {'uniform_weight', 'global_only', 'double_ablation'}
        Wuse = ones(size(Wmap));
    otherwise
        Wuse = Wmap;
end

nRowBlk = floor((H - blk) / stp) + 1;
nColBlk = floor((Wn - blk) / stp) + 1;
nBlk = nRowBlk * nColBlk;
sList = zeros(nBlk, 1);
idx = 0;
for r0 = 1:stp:(H-blk+1)
    for c0 = 1:stp:(Wn-blk+1)
        idx = idx + 1;
        B  = Delta(r0:r0+blk-1, c0:c0+blk-1);
        WB = Wuse(r0:r0+blk-1, c0:c0+blk-1);
        sList(idx) = sum(WB(:).*B(:)) / (sum(WB(:)) + cfg.poolEps);
    end
end
sList = sort(sList, 'descend');
K = max(1, floor(cfg.topFrac * numel(sList)));
muAll = mean(sList);

if strcmpi(methodName, 'global_only') || strcmpi(methodName, 'double_ablation')
    T = muAll;
else
    muTop = mean(sList(1:K));
    T = (1 - cfg.aggAlpha) * muAll + cfg.aggAlpha * muTop;
end
end
