%% =========================================================
%  Structure Perturbation Main Figure
%  SCI-ready MATLAB version without readtable / dot indexing
% =========================================================
clear; clc; close all;

%% ===================== Paths =====================
csvFile = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_local_structure_perturbation\local_structure_perturbation_detail.csv';
outDir  = 'D:\spd_formal_exp0411\results_spd_scene_formal\formal_local_structure_perturbation';

%% ===================== Read CSV by readcell =====================
C = readcell(csvFile);

header = string(C(1, :));
data   = C(2:end, :);

% Helper: get column index
getCol = @(name) find(header == string(name), 1);

col_MethodName       = getCol("MethodName");
col_MethodLabel      = getCol("MethodLabel");
col_GroupLabel       = getCol("GroupLabel");
col_PerturbationType = getCol("PerturbationType");

col_AUC       = getCol("AUC");
col_Pd1e2     = getCol("Pd_Pfa1e2");
col_Pd1e3     = getCol("Pd_Pfa1e3");

requiredCols = [
    col_MethodName
    col_MethodLabel
    col_GroupLabel
    col_PerturbationType
    col_AUC
    col_Pd1e2
    col_Pd1e3
];

if any(cellfun(@isempty, num2cell(requiredCols)))
    disp("CSV header:");
    disp(header');
    error("Missing required columns. Please check CSV column names.");
end

%% ===================== Convert columns =====================
MethodName       = strtrim(string(data(:, col_MethodName)));
MethodLabel      = strtrim(string(data(:, col_MethodLabel)));
GroupLabel       = strtrim(string(data(:, col_GroupLabel)));
PerturbationType = strtrim(string(data(:, col_PerturbationType)));

AUC       = cell2num_safe(data(:, col_AUC));
Pd_Pfa1e2 = cell2num_safe(data(:, col_Pd1e2));
Pd_Pfa1e3 = cell2num_safe(data(:, col_Pd1e3));

%% ===================== Settings =====================
% Choose one:
% "StructuralStrength"
% "LocalStructureCount"
plotType = "LocalStructureCount";

if plotType == "StructuralStrength"

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

    baseName = "structure_strength_perturbation_main";

elseif plotType == "LocalStructureCount"

    groupOrder = [
        "Few discriminative local structures"
        "Main local-structure count"
        "Many discriminative local structures"
    ];

    groupShort = [
        "Few"
        "Main"
        "Many"
    ];

    baseName = "local_structure_count_perturbation_main";

else
    error("Unknown plotType.");
end

methodOrder = [
    "full"
    "uniform_weight"
    "global_only"
];

methodLegend = [
    "Proposed detector"
    "Uniform-weight variant"
    "Global-only variant"
];

metricTitles = [
    "AUC"
    "$P_d$ @ $P_{fa}=10^{-2}$"
    "$P_d$ @ $P_{fa}=10^{-3}$"
];

colors = [
    53 92 155
    107 142 193
    176 183 195
] / 255;

fontName = 'Times New Roman';

%% ===================== Build mean matrix over seeds =====================
nGroup  = numel(groupOrder);
nMethod = numel(methodOrder);
nMetric = 3;

M = nan(nGroup, nMethod, nMetric);

for i = 1:nGroup
    for j = 1:nMethod

        idx = PerturbationType == plotType & ...
              GroupLabel == groupOrder(i) & ...
              MethodName == methodOrder(j);

        if ~any(idx)
            warning('Missing data: group="%s", method="%s"', groupOrder(i), methodOrder(j));
            continue;
        end

        M(i,j,1) = mean(AUC(idx), 'omitnan');
        M(i,j,2) = mean(Pd_Pfa1e2(idx), 'omitnan');
        M(i,j,3) = mean(Pd_Pfa1e3(idx), 'omitnan');
    end
end

%% ===================== Plot =====================
fig = figure('Units','centimeters', ...
             'Position',[2 2 30 10], ...
             'Color','w');

t = tiledlayout(2,3, ...
    'TileSpacing','compact', ...
    'Padding','compact');

barHandles = gobjects(1,nMethod);
barWidth = 0.75;

for k = 1:nMetric
    ax = nexttile(k); hold on;

    Y = M(:,:,k);

    b = bar(Y, 'grouped', ...
        'BarWidth', barWidth, ...
        'LineStyle','none');

    for j = 1:nMethod
        b(j).FaceColor = colors(j,:);
        b(j).EdgeColor = 'none';

        if k == 1
            barHandles(j) = b(j);
        end
    end

    ax.Box = 'off';
    ax.LineWidth = 1.2;
    ax.FontName = fontName;
    ax.FontSize = 11;
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.YGrid = 'on';
    ax.GridLineStyle = '--';
    ax.GridAlpha = 0.18;
    ax.XGrid = 'off';

    ax.XTick = 1:nGroup;
    ax.XTickLabel = groupShort;
    ax.XTickLabelRotation = 12;

    title(metricTitles(k), ...
        'Interpreter','latex', ...
        'FontSize',13, ...
        'FontWeight','normal');

    ylabel(metricTitles(k), ...
        'Interpreter','latex', ...
        'FontSize',12);

    yMin = min(Y(:), [], 'omitnan');
    yMax = max(Y(:), [], 'omitnan');
    pad  = max(0.003, 0.15*(yMax-yMin));

    if isfinite(yMin) && isfinite(yMax)
        ylim([yMin-pad, yMax+pad]);
    end
end

%% ===================== Dedicated legend row =====================
axLeg = nexttile(4, [1 3]);
axis(axLeg,'off');

lgd = legend(axLeg, barHandles, methodLegend, ...
    'Orientation','horizontal', ...
    'NumColumns',3, ...
    'Location','north', ...
    'Box','off', ...
    'FontName',fontName, ...
    'FontSize',12);

lgd.ItemTokenSize = [28, 12];

%% ===================== Save =====================
pngFile = fullfile(outDir, baseName + ".png");
pdfFile = fullfile(outDir, baseName + ".pdf");

exportgraphics(fig, pngFile, 'Resolution', 600);
exportgraphics(fig, pdfFile, 'ContentType','vector');

fprintf('Saved:\n%s\n%s\n', pngFile, pdfFile);

%% =========================================================
%  Local helper function
%% =========================================================
function x = cell2num_safe(c)
    x = nan(size(c));

    for ii = 1:numel(c)
        v = c{ii};

        if isnumeric(v)
            x(ii) = v;
        elseif isstring(v) || ischar(v)
            x(ii) = str2double(string(v));
        else
            x(ii) = NaN;
        end
    end
end