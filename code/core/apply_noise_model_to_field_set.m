function noisyFields = apply_noise_model_to_field_set(fieldSet, noiseSpec, cfg)
% Field-level shared background perturbation hook for non-Gaussian robustness.
% This is an explicit approximation layer on top of the uploaded scene generator.

noisyFields = fieldSet;
for i = 1:numel(fieldSet)
    F = fieldSet{i};
    H = size(F,1);
    W = size(F,2);
    G = zeros(size(F));
    for r = 1:H
        for c = 1:W
            C = squeeze(F(r,c,:,:));
            Delta = sample_symmetric_noise(noiseSpec.kind, noiseSpec.scale);
            Cn = expm(logm((C + C.')/2) + Delta);
            Cn = enforce_spd_local(Cn, cfg.minEig);
            G(r,c,:,:) = Cn;
        end
    end
    noisyFields{i} = G;
end
end

function Delta = sample_symmetric_noise(kind, scale)
A = randn(2);
switch lower(kind)
    case 'gaussian'
        Z = A;
    case 'laplacian'
        U = rand(2) - 0.5;
        Z = -sign(U) .* log(1 - 2*abs(U));
    case 'impulsive'
        Z = A;
        if rand < 0.08
            Z = 4 * A;
        end
    case 'student_t'
        nu = 3;
        Z = trnd(nu, 2) / sqrt(nu / max(nu - 2, 1));
    otherwise
        error('Unknown noise kind: %s', kind);
end
Delta = scale * (Z + Z.') / 2;
end

function C = enforce_spd_local(C, minEig)
C = (C + C.') / 2;
[V,D] = eig(C);
d = diag(D);
d(d < minEig) = minEig;
C = V * diag(d) * V.';
C = (C + C.') / 2;
end
