function fields = generate_spd_field_scene(nSamples, classLabel, snrDb, cfg)
% Direct-SPD-field scene generator for the formal main-performance study.
% IMPORTANT:
% 1) The main scene identity is fixed across SNR.
% 2) SNR only controls nuisance/background difficulty, not the class-defining
%    structural separation itself.
% 3) Therefore, thetaDiscSep_deg and islandAmp remain scene-defining constants.

H = cfg.patchFreq;
W = cfg.patchTime;
fields = cell(1, nSamples);

thetaBgAtlas = build_background_theta_atlas(H, W, cfg);

thetaDiscH0 = cfg.thetaDiscBase_deg - cfg.thetaDiscSep_deg/2;
thetaDiscH1 = cfg.thetaDiscBase_deg + cfg.thetaDiscSep_deg/2;
if classLabel == 0
    thetaDisc = thetaDiscH0;
else
    thetaDisc = thetaDiscH1;
end

snrFactor = snr_controls(snrDb, cfg);

localCfg = cfg;
localCfg.logPerturbAmp_bg = cfg.logPerturbAmp_bg * snrFactor^cfg.snrBgPerturbExponent;
localCfg.rotJitterBgDeg   = cfg.rotJitterBgDeg   * snrFactor^cfg.snrBgJitterExponent;

% Keep discriminative structure identity fixed across SNR.
localCfg.logPerturbAmp_disc = cfg.logPerturbAmp_disc;
localCfg.rotJitterDiscDeg   = cfg.rotJitterDiscDeg;
localCfg.thetaDiscSep_deg   = cfg.thetaDiscSep_deg;
localCfg.islandAmp          = cfg.islandAmp;

localCfg.logPerturbAmp_distr = cfg.logPerturbAmp_distr * snrFactor^cfg.snrDistractorPerturbExponent;
localCfg.distractorAmpMin    = cfg.distractorAmpMin    * snrFactor^cfg.snrDistractorAmpExponent;
localCfg.distractorAmpMax    = cfg.distractorAmpMax    * snrFactor^cfg.snrDistractorAmpExponent;

localCfg.distractorAmpMin = min(localCfg.distractorAmpMin, 0.95);
localCfg.distractorAmpMax = min(localCfg.distractorAmpMax, 1.20);

thetaDiscH0 = cfg.thetaDiscBase_deg - localCfg.thetaDiscSep_deg/2;
thetaDiscH1 = cfg.thetaDiscBase_deg + localCfg.thetaDiscSep_deg/2;
if classLabel == 0
    thetaDisc = thetaDiscH0;
else
    thetaDisc = thetaDiscH1;
end

islandMasks = build_island_masks(H, W, localCfg.islandCenters, localCfg.islandRadius, localCfg.islandAmp);

for i = 1:nSamples
    F = zeros(H, W, 2, 2);

    % -------------------------
    % step 1: shared background
    % -------------------------
    for r = 1:H
        for c = 1:W
            theta0 = thetaBgAtlas(r,c) + localCfg.rotJitterBgDeg * randn;
            C0 = make_spd_block_proto(theta0, localCfg.lambda1, localCfg.lambda2);
            C  = apply_spd_perturbation_with_amp(C0, localCfg.logPerturbAmp_bg, localCfg.minEig);
            F(r,c,:,:) = C;
        end
    end

    % ------------------------------------
    % step 2: stable discriminative islands
    % ------------------------------------
    for k = 1:size(localCfg.islandCenters,1)
        Mk = islandMasks(:,:,k);
        for r = 1:H
            for c = 1:W
                if Mk(r,c) > 1e-6
                    thetaBg = thetaBgAtlas(r,c);
                    thetaLocal = blend_angle_deg(thetaBg, thetaDisc, Mk(r,c));
                    thetaLocal = thetaLocal + localCfg.rotJitterDiscDeg * randn;

                    C0 = make_spd_block_proto(thetaLocal, localCfg.lambda1, localCfg.lambda2);
                    C  = apply_spd_perturbation_with_amp(C0, localCfg.logPerturbAmp_disc, localCfg.minEig);
                    F(r,c,:,:) = C;
                end
            end
        end
    end

    % --------------------------------
    % step 3: shared unstable distractors
    % --------------------------------
    [X, Y] = meshgrid(1:W, 1:H);
    for j = 1:localCfg.numDistractors
        cx = randi([4, W-3]);
        cy = randi([4, H-3]);

        thetaDistr = localCfg.thetaPool_deg(randi(numel(localCfg.thetaPool_deg))) ...
                   + localCfg.distractorRotJitterDeg * randn;

        ampDistr = localCfg.distractorAmpMin + ...
            (localCfg.distractorAmpMax - localCfg.distractorAmpMin) * rand;

        Md = exp(-((X-cx).^2 + (Y-cy).^2) / (2*localCfg.distractorRadius^2));
        Md = Md / max(Md(:));
        Md = ampDistr * Md;

        for r = 1:H
            for c = 1:W
                if Md(r,c) > 1e-3
                    thetaBg = thetaBgAtlas(r,c);
                    thetaLocal = blend_angle_deg(thetaBg, thetaDistr, Md(r,c));

                    C0 = make_spd_block_proto(thetaLocal, localCfg.lambda1, localCfg.lambda2);
                    C  = apply_spd_perturbation_with_amp(C0, localCfg.logPerturbAmp_distr, localCfg.minEig);

                    F(r,c,:,:) = C;
                end
            end
        end
    end

    fields{i} = F;
end
end

function snrFactor = snr_controls(snrDb, cfg)
snrFactor = 10.^((cfg.snrReferenceDb - snrDb) / cfg.snrScaleSlopeDb);
snrFactor = min(max(snrFactor, cfg.snrFactorClamp(1)), cfg.snrFactorClamp(2));
end

function thetaMap = build_background_theta_atlas(H, W, cfg)
thetaMap = zeros(H,W);
for r = 1:H
    for c = 1:W
        if r <= H/2 && c <= W/2
            thetaMap(r,c) = cfg.thetaBg1_deg;
        elseif r <= H/2 && c > W/2
            thetaMap(r,c) = cfg.thetaBg2_deg;
        elseif r > H/2 && c <= W/2
            thetaMap(r,c) = cfg.thetaBg3_deg;
        else
            thetaMap(r,c) = cfg.thetaBg4_deg;
        end
    end
end
G = gaussian_kernel_local(1.2);
thetaMap = conv2(thetaMap, G, 'same');
end

function masks = build_island_masks(H, W, centers, radius, ampVec)
n = size(centers,1);
masks = zeros(H, W, n);
[X,Y] = meshgrid(1:W, 1:H);
for k = 1:n
    cy = centers(k,1);
    cx = centers(k,2);
    a  = ampVec(k);
    M = exp(-((X-cx).^2 + (Y-cy).^2) / (2*radius^2));
    M = M / max(M(:));
    masks(:,:,k) = a * M;
end
end

function theta = blend_angle_deg(thetaA, thetaB, alpha)
va = [cosd(thetaA), sind(thetaA)];
vb = [cosd(thetaB), sind(thetaB)];
v  = (1-alpha) * va + alpha * vb;
theta = atan2d(v(2), v(1));
end

function Cpert = apply_spd_perturbation_with_amp(C, amp, minEig)
C = (C + C.') / 2;
Delta = amp * randn(2);
Delta = (Delta + Delta.') / 2;
Cpert = expm(logm(C) + Delta);
Cpert = enforce_spd_local(Cpert, minEig);
end

function C = enforce_spd_local(C, minEig)
C = (C + C.') / 2;
[V,D] = eig(C);
d = diag(D);
d(d < minEig) = minEig;
C = V * diag(d) * V.';
C = (C + C.') / 2;
end

function G = gaussian_kernel_local(sigma)
rad = max(1, ceil(3*sigma));
x = -rad:rad;
g = exp(-(x.^2)/(2*sigma^2));
g = g / sum(g);
G = g' * g;
end