% EXAMPLE04_YEOATLAS - Display all Yeo 7-Network resting-state networks.
%   Loads the Yeo2011 7-Network atlas and renders each functional network
%   with a distinct color. The legend shows the network names.

clear;

% add the src folder to the MATLAB path
srcPath = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
addpath(srcPath);


% -- paths
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
volumePath = fullfile(dataDir, 'YeoAtlas', 'Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii');
csvPath = fullfile(dataDir, 'YeoAtlas', 'Yeo2011_7Networks_labels.csv');

% -- load atlas
[volumeMNI, volumeLabels] = brainatlas.importAtlasVolume(volumePath);
atlasLabelsTable = brainatlas.loadAtlasLabels(csvPath);

% get indices of the selected areas/labels
areaIndices = atlasLabelsTable.Index';
areaNames = cellstr(atlasLabelsTable.Label);

% prepare colors
areaColors = lines(length(areaIndices));
areaColors = num2cell(areaColors, 2);

% -- plot
hfig = figure;
hfig.Position(3:end) = [720, 300];

brainvis.AREAplot(hfig, volumeMNI, volumeLabels, areaIndices, areaColors, ...
    figTitle='Yeo (2011) 7-Network atlas', views={'left', 'top', 'right'}, ...
    alpha=1, brainAlpha=0.01, brainSmoothness=5, roiSmoothness=70, ...
    subtitle=false);

brainvis.addLegend(areaNames, areaColors, 7);
