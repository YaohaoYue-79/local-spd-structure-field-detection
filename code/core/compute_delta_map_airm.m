function Delta = compute_delta_map_airm(F, ref0, ref1, metricName)
% metricName: 'airm' | 'fro' | 'euclidean'
H = size(F,1);
W = size(F,2);
Delta = zeros(H,W);
for r = 1:H
    for c = 1:W
        C  = squeeze(F(r,c,:,:));
        C0 = squeeze(ref0(r,c,:,:));
        C1 = squeeze(ref1(r,c,:,:));
        switch lower(metricName)
            case 'airm'
                d0 = airm_dist_sq_2x2_local(C, C0);
                d1 = airm_dist_sq_2x2_local(C, C1);
            case {'fro', 'euclidean'}
                d0 = norm(C - C0, 'fro')^2;
                d1 = norm(C - C1, 'fro')^2;
            otherwise
                error('Unknown metricName: %s', metricName);
        end
        Delta(r,c) = d0 - d1;
    end
end
end

function d2 = airm_dist_sq_2x2_local(A,B)
A = (A + A.') / 2;
B = (B + B.') / 2;
[V,D] = eig(A);
AinvSqrt = V * diag(1 ./ sqrt(max(diag(D),1e-12))) * V.';
T = AinvSqrt * B * AinvSqrt;
T = (T + T.') / 2;
[~,D2] = eig(T);
ev = max(diag(D2), 1e-12);
d2 = sum(log(ev).^2);
end
