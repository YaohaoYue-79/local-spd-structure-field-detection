function Wmap = compute_weight_map_sep_disp(trainH0, trainH1, ref0, ref1, cfg, methodName)
if strcmpi(methodName, 'uniform_weight') || strcmpi(methodName, 'global_only') || strcmpi(methodName, 'double_ablation')
    Wmap = ones(size(ref0,1), size(ref0,2));
    return;
end

H = size(ref0,1);
W = size(ref0,2);
Wraw = zeros(H,W);
for r = 1:H
    for c = 1:W
        C0 = squeeze(ref0(r,c,:,:));
        C1 = squeeze(ref1(r,c,:,:));
        sep = airm_dist_sq_2x2_local(C0, C1);

        disp0 = 0;
        for i = 1:numel(trainH0)
            A = squeeze(trainH0{i}(r,c,:,:));
            disp0 = disp0 + airm_dist_sq_2x2_local(A, C0);
        end
        disp0 = disp0 / numel(trainH0);

        disp1 = 0;
        for i = 1:numel(trainH1)
            A = squeeze(trainH1{i}(r,c,:,:));
            disp1 = disp1 + airm_dist_sq_2x2_local(A, C1);
        end
        disp1 = disp1 / numel(trainH1);

        Wraw(r,c) = sep / (disp0 + disp1 + cfg.weightEps);
    end
end
Wmap = normalize_and_smooth_weight_map(Wraw, cfg.weightSmoothSigma);
end

function Wmap = normalize_and_smooth_weight_map(Wraw, sigma)
mn = min(Wraw(:));
mx = max(Wraw(:));
Wmap = (Wraw - mn) / (mx - mn + eps);
if sigma > 0
    G = gaussian_kernel_local(sigma);
    Wmap = conv2(Wmap, G, 'same');
    mn = min(Wmap(:));
    mx = max(Wmap(:));
    Wmap = (Wmap - mn) / (mx - mn + eps);
end
Wmap = min(max(Wmap, 0), 1);
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

function G = gaussian_kernel_local(sigma)
rad = max(1, ceil(3*sigma));
x = -rad:rad;
g = exp(-(x.^2)/(2*sigma^2));
g = g / sum(g);
G = g' * g;
end
