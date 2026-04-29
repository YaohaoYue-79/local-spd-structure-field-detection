function scores = score_global_baseline(fieldSet, ref0, ref1, baselineName)
scores = zeros(numel(fieldSet),1);
r0 = field_to_vec(ref0);
r1 = field_to_vec(ref1);
for i = 1:numel(fieldSet)
    F = fieldSet{i};
    switch lower(baselineName)
        case 'global_energy'
            scores(i) = mean(F(:,:,1,1) + F(:,:,2,2), 'all');
        case 'template_correlation'
            v = field_to_vec(F);
            c1 = safe_corr(v(:), r1(:));
            c0 = safe_corr(v(:), r0(:));
            scores(i) = c1 - c0;
        case 'pooled_covariance'
            C = mean_field_matrix(F);
            C0 = mean_field_matrix(ref0);
            C1 = mean_field_matrix(ref1);
            scores(i) = airm_dist_sq_2x2_local(C, C0) - airm_dist_sq_2x2_local(C, C1);
        otherwise
            error('Unknown baselineName: %s', baselineName);
    end
end
end

function r = safe_corr(a, b)
a = a(:); b = b(:);
a = a - mean(a);
b = b - mean(b);
da = norm(a); db = norm(b);
if da < 1e-12 || db < 1e-12
    r = 0;
else
    r = (a' * b) / (da * db);
end
end

function v = field_to_vec(F)
A = squeeze(F(:,:,1,1));
B = squeeze(F(:,:,1,2));
D = squeeze(F(:,:,2,2));
v = [A(:); B(:); D(:)];
end

function C = mean_field_matrix(F)
A = squeeze(F(:,:,1,1));
B = squeeze(F(:,:,1,2));
D = squeeze(F(:,:,2,2));
C = [mean(A(:)), mean(B(:)); mean(B(:)), mean(D(:))];
C = (C + C.') / 2;
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
