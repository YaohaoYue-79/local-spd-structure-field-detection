function refField = estimate_reference_field_karcher_from_cells(fieldSet, cfg)
n = numel(fieldSet);
H = size(fieldSet{1},1);
W = size(fieldSet{1},2);
refField = zeros(H,W,2,2);
for r = 1:H
    for c = 1:W
        mats = cell(1,n);
        for i = 1:n
            mats{i} = squeeze(fieldSet{i}(r,c,:,:));
        end
        refField(r,c,:,:) = karcher_mean_2x2_cell(mats, cfg.karcherTol, cfg.karcherMaxIter, cfg.minEig);
    end
end
end

function M = karcher_mean_2x2_cell(mats, tol, maxIter, minEig)
n = numel(mats);
M = zeros(2,2);
for i = 1:n
    M = M + mats{i};
end
M = M / n;
M = enforce_spd_local(M, minEig);
for it = 1:maxIter
    MinvSqrt = mat_inv_sqrt_2x2(M);
    MSqrt    = mat_sqrt_2x2(M);
    Delta = zeros(2,2);
    for i = 1:n
        T = MinvSqrt * mats{i} * MinvSqrt;
        T = (T + T.') / 2;
        Delta = Delta + mat_log_2x2(T);
    end
    Delta = (Delta / n + (Delta / n).') / 2;
    if norm(Delta, 'fro') < tol
        break;
    end
    M = MSqrt * mat_exp_2x2(Delta) * MSqrt;
    M = enforce_spd_local(M, minEig);
end
end

function C = enforce_spd_local(C, minEig)
C = (C + C.') / 2;
[V,D] = eig(C);
d = diag(D);
d(d < minEig) = minEig;
C = V * diag(d) * V.';
C = (C + C.') / 2;
end

function S = mat_sqrt_2x2(A)
A = (A + A.') / 2;
[V,D] = eig(A);
S = V * diag(sqrt(max(diag(D),1e-12))) * V.';
S = (S + S.') / 2;
end

function S = mat_inv_sqrt_2x2(A)
A = (A + A.') / 2;
[V,D] = eig(A);
S = V * diag(1 ./ sqrt(max(diag(D),1e-12))) * V.';
S = (S + S.') / 2;
end

function L = mat_log_2x2(A)
A = (A + A.') / 2;
[V,D] = eig(A);
L = V * diag(log(max(diag(D),1e-12))) * V.';
L = (L + L.') / 2;
end

function E = mat_exp_2x2(A)
A = (A + A.') / 2;
[V,D] = eig(A);
E = V * diag(exp(diag(D))) * V.';
E = (E + E.') / 2;
end
