% EXAMPLE06_CONNECTIVITY - Display connectivity between Brainnetome areas.
%   Selects six sensorimotor areas (bilateral motor and premotor regions)
%   and draws intra- and inter-hemispheric connectivity.

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
T = brainatlas.loadAtlasLabels(csvPath);

% -- select areas (bilateral motor/premotor)
areaNames = {'L_A2', 'R_A1/2/3ulhf', 'L_A44op', 'R_A46', 'L_A6cdl', 'R_A6cdl'};
nAreas = length(areaNames);

areaIndices = zeros(1, nAreas);
for i = 1:nAreas
    areaIndices(i) = T.Index(strcmp(T.Label, areaNames{i}));
end

% prepare colors
areaColors = lines(nAreas);
areaColors = num2cell(areaColors, 2);

% -- define connectivity matrix (upper triangle)
connMatrix = zeros(nAreas);
connMatrix(1,3) = 1;
connMatrix(3,5) = 1;
connMatrix(2,4) = 1;
connMatrix(4,6) = 1;
connMatrix(1,2) = 1;
connMatrix(3,4) = 1;
connMatrix(5,6) = 1;

% -- plot
hfig = figure;
hfig.Position(3:end) = [720, 300];

brainvis.AREAplotConnectivity(hfig, volumeMNI, volumeLabels, areaIndices, connMatrix, areaColors, ...
    figTitle='Example connectivity (Brainnetome atlas)', views={'left', 'top', 'front'}, ...
    alpha=1, brainAlpha=0.02, brainSmoothness=5, ...
    sphereRadius=5, lineWidth=1.5, lineColor='#333333', subtitle=false);

brainvis.addLegend(areaNames, areaColors, 6);
