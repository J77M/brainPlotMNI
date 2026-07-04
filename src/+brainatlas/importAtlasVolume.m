function [volumeMNI, labels] = importAtlasVolume(atlasPath, opts)
% IMPORTATLASVOLUME - Loads an atlas .nii and converts to MNI coordinates.
%   Combines loadAtlasVolume and volume2MNI into a single convenience
%   function. Reads the NIfTI file, applies the affine transform, and
%   returns the MNI coordinates and labels for all non-background voxels.
% Syntax:
%   [volumeMNI, labels] = importAtlasVolume(atlasPath)
%   [volumeMNI, labels] = importAtlasVolume(atlasPath, 'ignoreVal', val)
% Input Arguments:
%   - atlasPath (char or string) - Path to the NIfTI (.nii) atlas file.
% Name-Value Options:
%   - ignoreVal (double) - Label value to filter out as background (default: 0).
% Output Arguments:
%   - volumeMNI (Mx3 double) - MNI coordinates [x, y, z] in mm for each labeled voxel.
%   - labels (Mx1 double) - Atlas label values corresponding to each MNI coordinate.

    arguments
        atlasPath (1,1) string {mustBeFile}
        opts.ignoreVal (1,1) double = 0
    end

    [Volume, transform] = brainatlas.loadAtlasVolume(atlasPath);
    [volumeMNI, labels] = brainatlas.volume2MNI(Volume, transform, 'ignoreVal', opts.ignoreVal);
end
