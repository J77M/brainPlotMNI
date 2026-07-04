% EXAMPLE05_CHANNELSLOCALIZATION - Localize channels in the Brainnetome atlas.
%   Maps subject channels to Brainnetome areas using MNI2AtlasLabels,
%   counts channels per area, and displays areas colored by channel count.
%   Requires MATLAB R2023a or later (for the sky colormap).

clear;

% add the src folder to the MATLAB path
srcPath = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
addpath(srcPath);


% -- parameters
radius = 5;               % [mm] initial search sphere radius
atlasIgnore = 0;          % atlas label for unparceled voxels

% -- data paths
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
volumePath = fullfile(dataDir, 'BrainnetomeAtlas', 'BN_Atlas_246_1mm.nii');
csvPath = fullfile(dataDir, 'BrainnetomeAtlas', 'BN_Atlas_labels.csv');
sub01Path = fullfile(fileparts(mfilename('fullpath')), 'channels_sub01.csv');
sub02Path = fullfile(fileparts(mfilename('fullpath')), 'channels_sub02.csv');

% -- load atlas
[volumeMNI, volumeLabels] = brainatlas.importAtlasVolume(volumePath);
atlasLabelsTable = brainatlas.loadAtlasLabels(csvPath);

% -- load subject channels
ch01 = readtable(sub01Path);
ch02 = readtable(sub02Path);
channels01 = [ch01.MNI_X, ch01.MNI_Y, ch01.MNI_Z];
channels02 = [ch02.MNI_X, ch02.MNI_Y, ch02.MNI_Z];

% -- localize channels
chanLabels01 = brainatlas.MNI2AtlasLabels(channels01, volumeMNI, volumeLabels, ...
    atlasLabelsTable.Index, atlasLabelsTable.Label, radius, atlasIgnore);
chanLabels02 = brainatlas.MNI2AtlasLabels(channels02, volumeMNI, volumeLabels, ...
    atlasLabelsTable.Index, atlasLabelsTable.Label, radius, atlasIgnore);

allLabels = [chanLabels01; chanLabels02];
allLabels = allLabels(~ismissing(allLabels));

% -- count channels per area
[uniqueLabels, ~, labelIdx] = unique(allLabels);
chanCounts = accumarray(labelIdx, 1);
maxChCount = max(chanCounts);

% -- build colors from sky colormap
cmap = sky(256);
colorIndices = round(chanCounts / maxChCount * 255);
colorIndices(colorIndices < 1) = 1;
areaColors = cmap(colorIndices, :);
areaColors = num2cell(areaColors, 2);

% -- map area names to atlas indices
areaIndices = zeros(1, length(uniqueLabels));
for i = 1:length(uniqueLabels)
    areaIndices(i) = atlasLabelsTable.Index(strcmp(atlasLabelsTable.Label, uniqueLabels{i}));
end

% -- plot
hfig = figure;
hfig.Position(3:end) = [720, 300];

brainvis.AREAplot(hfig, volumeMNI, volumeLabels, areaIndices, areaColors, ...
    figTitle='Channels per area (Brainnetome atlas)', views={'left', 'top', 'right'}, ...
    alpha=1, brainAlpha=0.02, brainSmoothness=5, roiSmoothness=70, ...
    subtitle=false);

colormap(cmap);
clim([0, maxChCount]);
cbar = colorbar;
cbar.Layout.Tile = 'east';
cbar.Label.String = 'number of channels';
