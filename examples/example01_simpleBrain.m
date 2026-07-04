% EXAMPLE01_SIMPLEBRAIN - Basic brain envelope plot with default views.
%   Demonstrates loading the Colin27 brain mask and creating a standard
%   empty brain plot using brainvis.BRAINplot.

clear;

% add the src folder to the MATLAB path
srcPath = fullfile(fileparts(mfilename('fullpath')), '..', 'src');
addpath(srcPath);


% -- paths to one of the atlases brain template
dataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
volumePath = fullfile(dataDir, 'YeoAtlas', 'Yeo2011_7Networks_MNI152_FreeSurferConformed1mm.nii');

% -- load brain template
[volumeMNI, ~] = brainatlas.importAtlasVolume(volumePath);

% -- plot the empty brain envelope
hfig = figure;
hfig.Position(3:end) = [720, 230];

brainvis.BRAINplot(hfig, volumeMNI, brainAlpha=1, brainSmoothness=50, ...
    brainClr="w", camlight=true, backgroundClr='k', axesClr='w');
% brainAlpha        sets the transparency of the brain
% brainSmoothness   (percentage %) sets how smoothness of the generated volume 
%                       - percentage of vertices taken into account