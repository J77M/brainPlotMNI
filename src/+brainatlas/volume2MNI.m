function [volumeMNI, labels] = volume2MNI(Volume, transform, opts)
% VOLUME2MNI - Converts a 3D atlas volume to MNI coordinate space.
%   Iterates over all voxels in the 3D volume, filters out voxels with
%   the ignoreVal label (background), and applies the affine transformation
%   matrix to obtain MNI coordinates in millimeters for each labeled voxel.
% Syntax:
%   [volumeMNI, labels] = volume2MNI(Volume, transform) Filters out label 0.
% Input Arguments:
%   - Volume (3D numeric array) - Voxel values of the atlas (from loadAtlasVolume).
%   - transform (3x4 double) - Affine transform matrix (from loadAtlasVolume).
% Name-Value Options:
%   - ignoreVal (double) - Label value to filter out as background (default: 0).
% Output Arguments:
%   - volumeMNI (Mx3 double) - MNI coordinates [x, y, z] in mm for each labeled voxel.
%   - labels (Mx1 double) - Atlas label values corresponding to each MNI coordinate.

    arguments
        Volume double
        transform (3,4) double
        opts.ignoreVal (1,1) double = 0
    end

    V_size = size(Volume);
    [X, Y, Z] = ndgrid(1:V_size(1), 1:V_size(2), 1:V_size(3));
    coordinates_indices = [X(:), Y(:), Z(:)];
    % get atlas labels for each coordinate
    labels = zeros(1, length(coordinates_indices));
    for c=1:length(coordinates_indices)
        coord = coordinates_indices(c, :);
        labels(c) = Volume(coord(1), coord(2), coord(3));
    end

    % remove voxels with no label
    coordinates_indices = coordinates_indices(labels ~= opts.ignoreVal, :);
    labels = labels(labels ~= opts.ignoreVal).';

%     transform (only offset)
%     volumeMNI = coordinates_indices - ones(size(coordinates_indices)) + transform(:, 4).';

    % transform offset
    coordinates_indices = coordinates_indices - ones(size(coordinates_indices));
    volumeMNI = transform(:, 1:3)*coordinates_indices.' + transform(:, 4);
    volumeMNI = volumeMNI.';
end