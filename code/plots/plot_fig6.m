%% plot_nongaussian_main_figure_v3.m
% Non-Gaussian robustness main figure
% Robust legend layout: dedicate one full row to the legend

clear; clc; close all;

%% ===================== User settings =====================
csvFile = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_nongaussian_robustness\nongaussian_summary.csv';
outDir  = fileparts(csvFile);

noiseOrder = { ...
    'Gaussian background perturbation', ...
    'Laplacian background perturbation', ...
    'Impulsive background perturbation', ...
    'Heavy-tailed background perturbation'};

noiseShort = {'Gaussian', 'Laplacian', 'Impulsive', 'Heavy-tailed'};

methodOrder  = {'full','uniform_weight','global_only'};
methodLegend = {'Proposed detector', 'Uniform-weight variant', 'Global-only variant'};

metricCols   = {'mean_AUC','mean_Pd_Pfa1e2','mean_Pd_Pfa1e3'};
metricTitles = {'AUC', '$P_d$ @ $P_{fa}=10^{-2}$', '$P_d$ @ $P_{fa}=10^{-3}$'};
yLabels      = {'AUC', '$P_d$ @ $P_{fa}=10^{-2}$', '$P_d$ @ $P_{fa}=10^{-3}$'};

barColors = [
    0.18 0.36 0.70
    0.42 0.60 0.84
    0.72 0.77 0.82
];

fontName = 'Times New Roman';
axisFontSize  = 11;
labelFontSize = 12;
titleFontSize = 13;
lw = 1.0;

%% ===================== Read table =====================
T = readtable(csvFile, 'TextType', 'string');

requiredCols = ["NoiseName","MethodName","mean_AUC","mean_Pd_Pfa1e2","mean_Pd_Pfa1e3"];
missingCols = setdiff(requiredCols, string(T.Properties.VariableNames));
if ~isempty(missingCols)
    error('Missing required columns: %s', strjoin(cellstr(missingCols), ', '));
end

T.NoiseName  = strtrim(T.NoiseName);
T.MethodName = strtrim(T.MethodName);

nNoise  = numel(noiseOrder);
nMethod = numel(methodOrder);
nMetric = numel(metricCols);

M = nan(nNoise, nMethod, nMetric);

for i = 1:nNoise
    for j = 1:nMethod
        idx = strcmp(T.NoiseName, noiseOrder{i}) & strcmp(T.MethodName, methodOrder{j});
        if ~any(idx)
            warning('Missing row: noise="%s", method="%s"', noiseOrder{i}, methodOrder{j});
            continue;
        end
        row = T(find(idx,1), :);
        for k = 1:nMetric
            M(i,j,k) = row.(metricCols{k});
        end
    end
end

%% ===================== Plot =====================
fig = figure('Color','w', 'Units','centimeters', 'Position',[2 2 31 10.5]);

% 2 rows: top row for 3 panels, bottom row for legend
t = tiledlayout(2,3, ...
    'TileSpacing','compact', ...
    'Padding','compact');

barHandles = gobjects(1,nMethod);

for k = 1:nMetric
    ax = nexttile(t, k);
    Y = M(:,:,k);   % 4 x 3

    b = bar(ax, Y, 'grouped', 'BarWidth', 0.76, 'LineStyle', 'none');
    hold(ax, 'on');

    for j = 1:nMethod
        b(j).FaceColor = barColors(j,:);
        b(j).EdgeColor = 'none';
        if k == 1
            barHandles(j) = b(j);
        end
    end

    ax.Box = 'off';
    ax.LineWidth = lw;
    ax.FontName = fontName;
    ax.FontSize = axisFontSize;
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.YGrid = 'on';
    ax.GridAlpha = 0.15;
    ax.XGrid = 'off';

    ax.XTick = 1:nNoise;
    ax.XTickLabel = noiseShort;
    ax.XTickLabelRotation = 12;

    title(metricTitles{k}, ...
        'Interpreter','latex', ...
        'FontSize', titleFontSize, ...
        'FontWeight','normal');

    ylabel(yLabels{k}, ...
        'Interpreter','latex', ...
        'FontSize', labelFontSize);

    % Slightly padded y-limits
    yMin = min(Y(:));
    yMax = max(Y(:));
    pad  = max(0.003, 0.18*(yMax - yMin));
    ylim([yMin - pad, yMax + pad]);
end

%% ===================== Dedicated legend row =====================
axLeg = nexttile(t, 4, [1 3]);   % occupy whole second row
axis(axLeg, 'off');

lgd = legend(axLeg, barHandles, methodLegend, ...
    'Orientation','horizontal', ...
    'NumColumns',3, ...
    'Location','north', ...
    'Box','off', ...
    'FontName',fontName, ...
    'FontSize',12);

% Make legend samples a bit longer
lgd.ItemTokenSize = [28, 12];

%% ===================== Save =====================
pngFile = fullfile(outDir, 'nongaussian_main_figure_v3.png');
pdfFile = fullfile(outDir, 'nongaussian_main_figure_v3.pdf');

exportgraphics(fig, pngFile, 'Resolution', 600);
exportgraphics(fig, pdfFile, 'ContentType', 'vector');

fprintf('Saved files:\n%s\n%s\n', pngFile, pdfFile);