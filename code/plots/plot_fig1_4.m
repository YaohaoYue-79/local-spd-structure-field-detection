%% =========================================================
%  plot_step2_ci_and_paired_difference.m
%  Scene credibility figures: 95% CI + paired differences
% =========================================================
clear; clc; close all;
%% ===================== Main-text figure switches =====================
makeMainTextVersion = true;

% CI visual style: lighter and thinner
ciLineWidth = 0.7;
ciCapSize   = 3;
ciLighten   = 0.45;   % 0=original color, 1=white

% Axes padding: avoid over-zooming
lineAxisPadFrac = 0.18;
barAxisPadFrac  = 0.18;

% Main text ablation figure: use mean bars only
showCIInAblationMain = false;

% Paired-difference figures should be generated as supplementary only
savePairedDifferenceAsSupplement = true;
%% ===================== Paths =====================
mainDetail = 'D:\spd_formal_exp0411\results_spd_scene_formal_patch63_hisnrfix\formal_main_performance_merged\main_performance_detail_merged.csv';
baseDetail = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_baselines\baseline_detail.csv';
ablaDetail = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_ablation\ablation_detail.csv';
localPertDetail = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_local_structure_perturbation\local_structure_perturbation_detail.csv';
nongDetail = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_nongaussian_robustness\nongaussian_detail.csv';

outDir = 'D:\spd_formal_exp0411\results_spd_scene_formal\paper_figures_step2';

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% ===================== Global style =====================
fontName = 'Times New Roman';

colProposed = [53 92 155] / 255;
colUniform  = [107 142 193] / 255;
colGlobal   = [176 183 195] / 255;
colDouble   = [214 124 57] / 255;

mutedPalette = [
    53 92 155
    107 142 193
    176 183 195
    142 142 142
    214 124 57
    103 154 120
] / 255;

methodColorMap = containers.Map;
methodColorMap('full') = colProposed;
methodColorMap('uniform_weight') = colUniform;
methodColorMap('global_only') = colGlobal;
methodColorMap('double_ablation') = colDouble;
methodColorMap('no_weight_no_top') = colDouble;
methodColorMap('euclidean_structure_field') = mutedPalette(2,:);
methodColorMap('fro_structure_field') = mutedPalette(3,:);
methodColorMap('template_correlation') = mutedPalette(4,:);
methodColorMap('template_correlation_baseline') = mutedPalette(4,:);
methodColorMap('pooled_covariance') = mutedPalette(5,:);
methodColorMap('global_energy') = mutedPalette(6,:);

lineWidth = 1.7;
markerSize = 6;
axisLineWidth = 1.1;
gridAlpha = 0.18;

useZoomedAxes = true;
omitDuplicateFrobeniusBaseline = true;

metricNames = ["AUC", "Pd_Pfa1e2", "Pd_Pfa1e3"];
metricTitles = [
    "AUC"
    "$P_d$ @ $P_{fa}=10^{-2}$"
    "$P_d$ @ $P_{fa}=10^{-3}$"
];
% Display label for the controlled SPD-field benchmark.
% In this benchmark, SNR is a nominal nuisance-difficulty index,
% not a physical waveform SNR.
snrAxisLabel = 'Nominal SNR index (dB)';
%% =========================================================
%  Figure 1 and Figure 2: main performance with CI
%% =========================================================
Main = read_csv_as_struct(mainDetail);

mainOrder = [
    "full"
    "uniform_weight"
    "global_only"
];
mainOrder = keep_existing_methods(mainOrder, Main.MethodName);

mainLabels = arrayfun(@display_label, mainOrder);
mainColors = zeros(numel(mainOrder),3);
for i = 1:numel(mainOrder)
    mainColors(i,:) = get_method_color(mainOrder(i), methodColorMap, mutedPalette, i);
end

snrList = unique(Main.SNR_dB);
snrList = sort(snrList(:));

% ---------- Figure 1: AUC vs SNR with 95% CI ----------
fig1 = figure('Units','centimeters','Position',[2 2 17.5 9.8],'Color','w');
ax1 = axes(fig1); hold(ax1,'on');

lineHandles = gobjects(numel(mainOrder),1);
allY = [];

for i = 1:numel(mainOrder)
    m = mainOrder(i);

    mu = nan(numel(snrList),1);
    ci = nan(numel(snrList),1);

    for s = 1:numel(snrList)
        idx = Main.MethodName == m & Main.SNR_dB == snrList(s);
        [mu(s), ci(s)] = mean_ci95(Main.AUC(idx));
    end

% Light CI first
errorbar(ax1, snrList, mu, ci, ...
    'LineStyle','none', ...
    'Color', lighten_color(mainColors(i,:), ciLighten), ...
    'LineWidth', ciLineWidth, ...
    'CapSize', ciCapSize, ...
    'HandleVisibility','off');

% Main trend line
lineHandles(i) = plot(ax1, snrList, mu, '-o', ...
    'Color', mainColors(i,:), ...
    'LineWidth', lineWidth, ...
    'MarkerSize', markerSize, ...
    'MarkerFaceColor', mainColors(i,:), ...
    'MarkerEdgeColor', mainColors(i,:), ...
    'DisplayName', mainLabels(i));

    allY = [allY; mu(:)+ci(:); mu(:)-ci(:)]; %#ok<AGROW>
end

style_axis(ax1, fontName, axisLineWidth, gridAlpha);
xlabel(ax1, snrAxisLabel, 'FontName',fontName, 'FontSize',12);
ylabel(ax1, 'AUC', 'FontName',fontName, 'FontSize',12);
title(ax1, 'AUC versus nominal SNR index', ...
    'FontName',fontName, 'FontSize',14, 'FontWeight','normal');
xlim(ax1, [min(snrList), max(snrList)]);

if useZoomedAxes
    apply_tight_ylim(ax1, allY, lineAxisPadFrac);
else
    ylim(ax1, [0,1]);
end

lgd1 = legend(ax1, lineHandles, mainLabels, ...
    'Location','southoutside', ...
    'Orientation','horizontal', ...
    'NumColumns',numel(mainOrder), ...
    'Box','off', ...
    'FontName',fontName, ...
    'FontSize',11);
lgd1.ItemTokenSize = [24, 12];

exportgraphics(fig1, fullfile(outDir,'fig1_main_auc_vs_nominal_snr_index_ci.png'), 'Resolution',600);
exportgraphics(fig1, fullfile(outDir,'fig1_main_auc_vs_nominal_snr_index_ci.pdf'), 'ContentType','vector');

% ---------- Figure 2: Pd vs SNR with 95% CI ----------
fig2 = figure('Units','centimeters','Position',[2 2 27 10.2],'Color','w');
t2 = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

ax21 = nexttile(t2,1); hold(ax21,'on');
ax22 = nexttile(t2,2); hold(ax22,'on');

lineHandles2 = gobjects(numel(mainOrder),1);
allY1 = [];
allY2 = [];

for i = 1:numel(mainOrder)
    m = mainOrder(i);

    mu1 = nan(numel(snrList),1);
    ci1 = nan(numel(snrList),1);
    mu2 = nan(numel(snrList),1);
    ci2 = nan(numel(snrList),1);

    for s = 1:numel(snrList)
        idx = Main.MethodName == m & Main.SNR_dB == snrList(s);
        [mu1(s), ci1(s)] = mean_ci95(Main.Pd_Pfa1e2(idx));
        [mu2(s), ci2(s)] = mean_ci95(Main.Pd_Pfa1e3(idx));
    end

errorbar(ax21, snrList, mu1, ci1, ...
    'LineStyle','none', ...
    'Color', lighten_color(mainColors(i,:), ciLighten), ...
    'LineWidth', ciLineWidth, ...
    'CapSize', ciCapSize, ...
    'HandleVisibility','off');

lineHandles2(i) = plot(ax21, snrList, mu1, '-o', ...
    'Color', mainColors(i,:), ...
    'LineWidth', lineWidth, ...
    'MarkerSize', markerSize, ...
    'MarkerFaceColor', mainColors(i,:), ...
    'MarkerEdgeColor', mainColors(i,:), ...
    'DisplayName', mainLabels(i));

 errorbar(ax22, snrList, mu2, ci2, ...
    'LineStyle','none', ...
    'Color', lighten_color(mainColors(i,:), ciLighten), ...
    'LineWidth', ciLineWidth, ...
    'CapSize', ciCapSize, ...
    'HandleVisibility','off');

plot(ax22, snrList, mu2, '-o', ...
    'Color', mainColors(i,:), ...
    'LineWidth', lineWidth, ...
    'MarkerSize', markerSize, ...
    'MarkerFaceColor', mainColors(i,:), ...
    'MarkerEdgeColor', mainColors(i,:), ...
    'DisplayName', mainLabels(i));

    allY1 = [allY1; mu1(:)+ci1(:); mu1(:)-ci1(:)]; %#ok<AGROW>
    allY2 = [allY2; mu2(:)+ci2(:); mu2(:)-ci2(:)]; %#ok<AGROW>
end

style_axis(ax21, fontName, axisLineWidth, gridAlpha);
style_axis(ax22, fontName, axisLineWidth, gridAlpha);

xlabel(ax21, snrAxisLabel, 'FontName',fontName, 'FontSize',12);
ylabel(ax21, '$P_d$', 'Interpreter','latex', 'FontName',fontName, 'FontSize',12);
title(ax21, '$P_d$ @ $P_{fa}=10^{-2}$', 'Interpreter','latex', ...
    'FontName',fontName, 'FontSize',14, 'FontWeight','normal');

xlabel(ax22, snrAxisLabel, 'FontName',fontName, 'FontSize',12);
ylabel(ax22, '$P_d$', 'Interpreter','latex', 'FontName',fontName, 'FontSize',12);
title(ax22, '$P_d$ @ $P_{fa}=10^{-3}$', 'Interpreter','latex', ...
    'FontName',fontName, 'FontSize',14, 'FontWeight','normal');

xlim(ax21, [min(snrList), max(snrList)]);
xlim(ax22, [min(snrList), max(snrList)]);

if useZoomedAxes
    apply_tight_ylim(ax21, allY1, lineAxisPadFrac);
apply_tight_ylim(ax22, allY2, lineAxisPadFrac);
else
    ylim(ax21, [0,1]);
    ylim(ax22, [0,1]);
end

ax2Leg = nexttile(t2,3,[1 2]);
axis(ax2Leg,'off');
lgd2 = legend(ax2Leg, lineHandles2, mainLabels, ...
    'Orientation','horizontal', ...
    'NumColumns',numel(mainOrder), ...
    'Location','north', ...
    'Box','off', ...
    'FontName',fontName, ...
    'FontSize',11);
lgd2.ItemTokenSize = [24, 12];

exportgraphics(fig2, fullfile(outDir,'fig2_main_fixed_pfa_vs_nominal_snr_index_ci.png'), 'Resolution',600);
exportgraphics(fig2, fullfile(outDir,'fig2_main_fixed_pfa_vs_nominal_snr_index_ci.pdf'), 'ContentType','vector');

%% =========================================================
%  Figure 3: baseline comparison with 95% CI
%% =========================================================
Base = read_csv_as_struct(baseDetail);

baseOrder = [
    "full"
    "euclidean_structure_field"
    "fro_structure_field"
    "template_correlation"
    "template_correlation_baseline"
    "pooled_covariance"
    "global_energy"
];
baseOrder = keep_existing_methods(baseOrder, Base.MethodName);

if omitDuplicateFrobeniusBaseline && ...
        any(baseOrder=="euclidean_structure_field") && ...
        any(baseOrder=="fro_structure_field")

    idxE = Base.MethodName=="euclidean_structure_field";
    idxF = Base.MethodName=="fro_structure_field";

    if abs(mean(Base.AUC(idxE),'omitnan') - mean(Base.AUC(idxF),'omitnan')) < 1e-10
        baseOrder(baseOrder=="fro_structure_field") = [];
    end
end

baseLabels = arrayfun(@display_label, baseOrder);
baseColors = zeros(numel(baseOrder),3);
for i = 1:numel(baseOrder)
    baseColors(i,:) = get_method_color(baseOrder(i), methodColorMap, mutedPalette, i);
end

fig3 = figure('Units','centimeters','Position',[2 2 27 10.5],'Color','w');
t3 = tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

for k = 1:3
    ax = nexttile(t3,k); hold(ax,'on');

    metric = metricNames(k);
    nBase = numel(baseOrder);
    yTicks = 1:nBase;
    yTickLabels = flipud(baseLabels(:));

    vals = nan(nBase,1);
    cis = nan(nBase,1);

    for i = 1:nBase
        idx = Base.MethodName == baseOrder(i);
        [vals(i), cis(i)] = mean_ci95(Base.(metric)(idx));
    end

    xMin = min(vals-cis,[],'omitnan');
    xMax = max(vals+cis,[],'omitnan');
    pad = max(0.01,0.12*(xMax-xMin));
    xLeft = max(0,xMin-pad);
    xRight = xMax+pad;

    for i = 1:nBase
        yy = nBase - i + 1;

        plot(ax, [xLeft vals(i)], [yy yy], '-', ...
            'Color',[0.78 0.80 0.84], ...
            'LineWidth',1.1);

       line(ax, [vals(i)-cis(i), vals(i)+cis(i)], [yy yy], ...
    'Color', lighten_color(baseColors(i,:), 0.35), ...
    'LineWidth', 1.0);

        plot(ax, vals(i), yy, 'o', ...
            'MarkerSize',8.0, ...
            'MarkerFaceColor',baseColors(i,:), ...
            'MarkerEdgeColor',baseColors(i,:));
    end

    style_axis(ax, fontName, axisLineWidth, gridAlpha);
    ax.YTick = yTicks;
    ax.YTickLabel = yTickLabels;
    ax.YLim = [0.4,nBase+0.6];
    ax.XLim = [xLeft,xRight];
    ax.YGrid = 'off';
    ax.XGrid = 'on';

    title(ax, metricTitles(k), 'Interpreter','latex', ...
        'FontName',fontName, 'FontSize',14, 'FontWeight','normal');
    xlabel(ax, metricTitles(k), 'Interpreter','latex', ...
        'FontName',fontName, 'FontSize',12);
end

exportgraphics(fig3, fullfile(outDir,'fig3_baseline_comparison_ci.png'), 'Resolution',600);
exportgraphics(fig3, fullfile(outDir,'fig3_baseline_comparison_ci.pdf'), 'ContentType','vector');

%% =========================================================
%  Figure 4: ablation analysis with 95% CI
%% =========================================================
Abla = read_csv_as_struct(ablaDetail);

ablaOrder = [
    "full"
    "uniform_weight"
    "global_only"
    "double_ablation"
    "no_weight_no_top"
];

ablaOrder = keep_existing_methods(ablaOrder, Abla.MethodName);

allA = unique(Abla.MethodName,'stable');
for i = 1:numel(allA)
    if ~any(ablaOrder == allA(i))
        ablaOrder(end+1,1) = allA(i); %#ok<AGROW>
    end
end

ablaLabels = arrayfun(@display_label, ablaOrder);
ablaColors = zeros(numel(ablaOrder),3);
for i = 1:numel(ablaOrder)
    ablaColors(i,:) = get_method_color(ablaOrder(i), methodColorMap, mutedPalette, i);
end

fig4 = figure('Units','centimeters','Position',[2 2 33 10.8],'Color','w');
t4 = tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

barHandles = gobjects(numel(ablaOrder),1);

for k = 1:3
    ax = nexttile(t4,k); hold(ax,'on');

    vals = nan(numel(ablaOrder),1);
    cis = nan(numel(ablaOrder),1);

    for i = 1:numel(ablaOrder)
        idx = Abla.MethodName == ablaOrder(i);
        [vals(i), cis(i)] = mean_ci95(Abla.(metricNames(k))(idx));

        bh = bar(ax, i, vals(i), 0.68, ...
            'FaceColor',ablaColors(i,:), ...
            'EdgeColor','none');
        if k == 1
            barHandles(i) = bh;
        end

        if showCIInAblationMain
    draw_vertical_ci(ax, i, vals(i), cis(i), [0.20 0.20 0.20]);
end
    end

    style_axis(ax, fontName, axisLineWidth, gridAlpha);

    title(ax, metricTitles(k), 'Interpreter','latex', ...
        'FontName',fontName, 'FontSize',14, 'FontWeight','normal');
    ylabel(ax, metricTitles(k), 'Interpreter','latex', ...
        'FontName',fontName, 'FontSize',12);

    ax.XTick = 1:numel(ablaOrder);
    ax.XTickLabel = ablaLabels;
    ax.XTickLabelRotation = 12;
    xlim(ax,[0.4,numel(ablaOrder)+0.6]);
    if showCIInAblationMain
    apply_tight_ylim(ax, [vals-cis; vals+cis], barAxisPadFrac);
else
    apply_tight_ylim(ax, vals, barAxisPadFrac);
end
end

ax4Leg = nexttile(t4,4,[1 3]);
axis(ax4Leg,'off');
lgd4 = legend(ax4Leg, barHandles, ablaLabels, ...
    'Orientation','horizontal', ...
    'NumColumns',numel(ablaOrder), ...
    'Location','north', ...
    'Box','off', ...
    'FontName',fontName, ...
    'FontSize',11);
lgd4.ItemTokenSize = [24, 12];

if showCIInAblationMain
    fig4Name = 'fig4_ablation_analysis_ci';
else
    fig4Name = 'fig4_ablation_analysis_main';
end

exportgraphics(fig4, fullfile(outDir, fig4Name + ".png"), 'Resolution',600);
exportgraphics(fig4, fullfile(outDir, fig4Name + ".pdf"), 'ContentType','vector');

%% =========================================================
%  Figure 5b: paired difference for ablation
%% =========================================================
fig5b = figure('Units','centimeters','Position',[2 2 26 9.5],'Color','w');
t5b = tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

comparisonMethods = [
    "uniform_weight"
    "global_only"
    "double_ablation"
    "no_weight_no_top"
];
comparisonMethods = keep_existing_methods(comparisonMethods, Abla.MethodName);
compLabels = "Proposed - " + arrayfun(@display_label, comparisonMethods);

for k = 1:3
    ax = nexttile(t5b,k); hold(ax,'on');

    vals = nan(numel(comparisonMethods),1);
    cis = nan(numel(comparisonMethods),1);

    for i = 1:numel(comparisonMethods)
        d = paired_diff_by_seed(Abla, "full", comparisonMethods(i), metricNames(k));
        [vals(i), cis(i)] = mean_ci95(d);

        bar(ax, i, vals(i), 0.62, ...
            'FaceColor', get_method_color(comparisonMethods(i), methodColorMap, mutedPalette, i+1), ...
            'EdgeColor','none');
        draw_vertical_ci(ax, i, vals(i), cis(i), [0.20 0.20 0.20]);
    end

    yline(ax, 0, '-', 'Color',[0.20 0.20 0.20], 'LineWidth',1.0);

    style_axis(ax, fontName, axisLineWidth, gridAlpha);
    title(ax, metricTitles(k), 'Interpreter','latex', ...
        'FontName',fontName, 'FontSize',14, 'FontWeight','normal');
    ylabel(ax, 'Paired difference', 'FontName',fontName, 'FontSize',12);
    ax.XTick = 1:numel(comparisonMethods);
    ax.XTickLabel = compLabels;
    ax.XTickLabelRotation = 15;
    xlim(ax,[0.4,numel(comparisonMethods)+0.6]);
    apply_tight_ylim(ax, [vals-cis; vals+cis; 0], 0.20);
end

exportgraphics(fig5b, fullfile(outDir,'figS1_ablation_paired_difference.png'), 'Resolution',600);
exportgraphics(fig5b, fullfile(outDir,'figS1_ablation_paired_difference.pdf'), 'ContentType','vector');

%% =========================================================
%  Figure 6b: paired difference for structural-strength perturbation
%% =========================================================
LocalP = read_csv_as_struct(localPertDetail);

Tss = filter_rows(LocalP, LocalP.PerturbationType == "StructuralStrength");

groupOrder = [
    "Slightly stronger structural stability"
    "Main structured-locality detection scene"
    "Slightly weaker structural stability"
    "Boundary auxiliary scene with weakened inter-class structural separation"
];

groupShort = [
    "Stronger"
    "Main"
    "Weaker"
    "Boundary"
];

fig6b = figure('Units','centimeters','Position',[2 2 27 9.5],'Color','w');
t6b = tiledlayout(1,3,'TileSpacing','compact','Padding','compact');

for k = 1:3
    ax = nexttile(t6b,k); hold(ax,'on');

    vals = nan(numel(groupOrder),1);
    cis = nan(numel(groupOrder),1);

    for g = 1:numel(groupOrder)
        Tg = filter_rows(Tss, Tss.GroupLabel == groupOrder(g));
        d = paired_diff_by_seed(Tg, "full", "uniform_weight", metricNames(k));
        [vals(g), cis(g)] = mean_ci95(d);

        bar(ax, g, vals(g), 0.65, ...
            'FaceColor', colProposed, ...
            'EdgeColor','none');
        draw_vertical_ci(ax, g, vals(g), cis(g), [0.20 0.20 0.20]);
    end

    yline(ax, 0, '-', 'Color',[0.20 0.20 0.20], 'LineWidth',1.0);

    style_axis(ax, fontName, axisLineWidth, gridAlpha);
    title(ax, metricTitles(k), 'Interpreter','latex', ...
        'FontName',fontName, 'FontSize',14, 'FontWeight','normal');
    ylabel(ax, 'Proposed - Uniform-weight', 'FontName',fontName, 'FontSize',12);
    ax.XTick = 1:numel(groupShort);
    ax.XTickLabel = groupShort;
    ax.XTickLabelRotation = 12;
    xlim(ax,[0.4,numel(groupShort)+0.6]);
    apply_tight_ylim(ax, [vals-cis; vals+cis; 0], 0.20);
end

exportgraphics(fig6b, fullfile(outDir,'figS2_structural_strength_paired_difference.png'), 'Resolution',600);
exportgraphics(fig6b, fullfile(outDir,'figS2_structural_strength_paired_difference.pdf'), 'ContentType','vector');

fprintf('\nAll Step-2 credibility figures saved to:\n%s\n', outDir);

%% =========================================================
%  Local functions
%% =========================================================
function S = read_csv_as_struct(csvFile)
    if ~exist(csvFile,'file')
        error('File not found: %s', csvFile);
    end

    C = readcell(csvFile);
    header = string(C(1,:));
    data = C(2:end,:);

    S = struct();

    for j = 1:numel(header)
        name = matlab.lang.makeValidName(header(j));
        col = data(:,j);

        numericCol = cell2num_safe(col);
        nonNanRatio = mean(~isnan(numericCol));

        if nonNanRatio > 0.80
            S.(name) = numericCol;
        else
            S.(name) = strtrim(string(col));
        end
    end
end

function x = cell2num_safe(c)
    x = nan(size(c));
    for ii = 1:numel(c)
        v = c{ii};
        if isnumeric(v)
            x(ii) = v;
        elseif ischar(v) || isstring(v)
            x(ii) = str2double(string(v));
        else
            x(ii) = NaN;
        end
    end
end

function [mu, ci] = mean_ci95(x)
    x = x(isfinite(x));
    n = numel(x);

    if n == 0
        mu = NaN;
        ci = NaN;
        return;
    end

    mu = mean(x,'omitnan');

    if n == 1
        ci = 0;
        return;
    end

    s = std(x,0,'omitnan');

    if exist('tinv','file') || exist('tinv','builtin')
        tcrit = tinv(0.975,n-1);
    else
        tcrit = 1.96;
    end

    ci = tcrit * s / sqrt(n);
end

function order = keep_existing_methods(preferredOrder, methodNames)
    order = strings(0,1);
    for i = 1:numel(preferredOrder)
        if any(methodNames == preferredOrder(i))
            order(end+1,1) = preferredOrder(i); %#ok<AGROW>
        end
    end
end

function label = display_label(methodName)
    methodName = string(methodName);
    switch methodName
        case "full"
            label = "Proposed";
        case "uniform_weight"
            label = "Uniform-weight";
        case "global_only"
            label = "Global-only";
        case "double_ablation"
            label = "Double ablation";
        case "no_weight_no_top"
            label = "Double ablation";
        case "euclidean_structure_field"
            label = "Euclidean SF";
        case "fro_structure_field"
            label = "Frobenius SF";
        case "pooled_covariance"
            label = "Pooled Cov.";
        case "global_energy"
            label = "Global Energy";
        case "template_correlation"
            label = "Template";
        case "template_correlation_baseline"
            label = "Template";
        otherwise
            label = methodName;
    end
end

function color = get_method_color(methodName, methodColorMap, palette, idx)
    key = char(string(methodName));
    if isKey(methodColorMap,key)
        color = methodColorMap(key);
    else
        color = palette(mod(idx-1,size(palette,1))+1,:);
    end
end

function style_axis(ax, fontName, axisLineWidth, gridAlpha)
    ax.Box = 'off';
    ax.LineWidth = axisLineWidth;
    ax.FontName = fontName;
    ax.FontSize = 11;
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.YGrid = 'on';
    ax.XGrid = 'off';
    ax.GridLineStyle = '--';
    ax.GridAlpha = gridAlpha;
end

function apply_tight_ylim(ax, y, padFrac)
    y = y(isfinite(y));
    if isempty(y)
        return;
    end

    yMin = min(y);
    yMax = max(y);

    if yMax == yMin
        pad = max(0.003,0.05*abs(yMax)+0.003);
    else
        pad = max(0.003,padFrac*(yMax-yMin));
    end

    ylim(ax,[yMin-pad,yMax+pad]);
end

function draw_vertical_ci(ax, x, mu, ci, color)
    if ~isfinite(mu) || ~isfinite(ci)
        return;
    end

    line(ax, [x x], [mu-ci mu+ci], ...
        'Color',color, ...
        'LineWidth',1.0);

    cap = 0.08;
    line(ax, [x-cap x+cap], [mu+ci mu+ci], ...
        'Color',color, ...
        'LineWidth',1.0);

    line(ax, [x-cap x+cap], [mu-ci mu-ci], ...
        'Color',color, ...
        'LineWidth',1.0);
end

function d = paired_diff_by_seed(T, methodA, methodB, metric)
    seeds = unique(T.Seed);
    d = [];

    for i = 1:numel(seeds)
        idxA = T.MethodName == methodA & T.Seed == seeds(i);
        idxB = T.MethodName == methodB & T.Seed == seeds(i);

        if any(idxA) && any(idxB)
            a = T.(metric)(find(idxA,1));
            b = T.(metric)(find(idxB,1));
            d(end+1,1) = a - b; %#ok<AGROW>
        end
    end
end

function Tout = filter_rows(T, idx)
    fields = fieldnames(T);
    Tout = struct();

    for i = 1:numel(fields)
        f = fields{i};
        Tout.(f) = T.(f)(idx,:);
    end
end
function c2 = lighten_color(c, amount)
    % amount in [0,1], larger means lighter
    c2 = c + amount * (1 - c);
    c2 = min(max(c2,0),1);
end