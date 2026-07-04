% EXAMPLE02_MNICHANNELS - Plot MNI channel coordinates from two subjects.
%   Loads channel coordinates from CSV files, displays them on a brain
%   template with different colors per subject, and adds a legend.

clear;

% add the src folder to the MATLAB path
srcPath = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
addpath(srcPath);


% -- paths
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
volumePath = fullfile(dataDir, 'YeoAtlas', 'Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii');

% -- load atlas
[volumeMNI, ~] = brainatlas.importAtlasVolume(volumePath);

% -- load subject channel MNI coordinates
chTable1 = readtable(fullfile(fileparts(mfilename('fullpath')), 'channels_sub01.csv'));
chTable2 = readtable(fullfile(fileparts(mfilename('fullpath')), 'channels_sub02.csv'));

channels1 = [chTable1.MNI_X, chTable1.MNI_Y, chTable1.MNI_Z];
channels2 = [chTable2.MNI_X, chTable2.MNI_Y, chTable2.MNI_Z];

% -- plot
hfig = figure;
hfig.Position(3:end) = [720, 320];

brainvis.MNIplot(hfig, volumeMNI, {channels1, channels2}, {'r', 'b'}, ...
    figTitle="Channels MNI coordinates", markerSize=6);

brainvis.addLegend({'subject 1', 'subject 2'}, {'r', 'b'});
