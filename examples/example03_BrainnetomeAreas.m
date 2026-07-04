% EXAMPLE03_BRAINNETOMEAREAS - Display selected Brainnetome atlas areas.
%   Loads the Brainnetome atlas and renders four left-hemisphere areas
%   (L_A4hf, L_A4ul, L_A6cdl, L_A5l) with distinct colors.

clear;

% add the src folder to the MATLAB path
srcPath = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
addpath(srcPath);


% -- paths
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
volumePath = fullfile(dataDir, 'BrainnetomeAtlas', 'BN_Atlas_246_1mm.nii');
csvPath = fullfile(dataDir, 'BrainnetomeAtlas', 'BN_Atlas_labels.csv');

% -- load atlas
[volumeMNI, volumeLabels] = brainatlas.importAtlasVolume(volumePath);
atlasLabelsTable = brainatlas.loadAtlasLabels(csvPath);

% -- select Brainnetome atlas areas and their colors
areaNames = {'L_A4hf', 'L_A4ul', 'L_A6cdl', 'L_A5l'};
areaColors = lines(length(areaNames)); % lines colormap
areaColors = num2cell(areaColors, 2);

% get indices of the selected areas/labels
areaIndices = zeros(1, length(areaNames));
for i = 1:length(areaNames)
    areaIndices(i) = atlasLabelsTable.Index(strcmp(atlasLabelsTable.Label, areaNames{i}));
end


% -- plot
hfig = figure;
hfig.Position(3:end) = [720, 300];

brainvis.AREAplot(hfig, volumeMNI, volumeLabels, areaIndices, areaColors, ...
    figTitle='Brainnetome atlas - selected areas', views={'left', 'top', 'right'}, ...
    alpha=1, brainAlpha=0.01, brainSmoothness=5, roiSmoothness=70, ... 
    camlight=true, subtitle=false);

brainvis.addLegend(areaNames, areaColors);
