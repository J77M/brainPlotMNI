function [MNI_V, labels] = volume2MNI(Volume, transform)
% VOLUME2MNI - Converts a 3D atlas volume to MNI coordinate space.
%   Iterates over all voxels in the 3D volume, filters out voxels with
%   zero label (background), and applies the affine transformation matrix
%   to obtain MNI coordinates in millimeters for each labeled voxel.
% Syntax:
%   [MNI_V, labels] = volume2MNI(Volume, transform) Converts volumetric atlas.
% Input Arguments:
%   - Volume (3D numeric array) - Voxel values of the atlas (from loadAtlasVolume).
%   - transform (3x4 double) - Affine transform matrix (from loadAtlasVolume).
% Output Arguments:
%   - MNI_V (Mx3 double) - MNI coordinates [x, y, z] in mm for each labeled voxel.
%   - labels (Mx1 numeric) - Atlas label values corresponding to each MNI coordinate.
    V_size = size(Volume);
    [X, Y, Z] = ndgrid(1:V_size(1), 1:V_size(2), 1:V_size(3));
    coordinates_indices = [X(:), Y(:), Z(:)];
    % get atlas labels for each coordinate
    labels = zeros(1, length(coordinates_indices));
    for c=1:length(coordinates_indices)
        coord = coordinates_indices(c, :);
        labels(c) = Volume(coord(1), coord(2), coord(3));
    end
    % remove zeros (no label)
    coordinates_indices = coordinates_indices(labels ~= 0, :);
    labels = labels(labels ~= 0).';
    
%     transform (only offset)
%     MNI_V = coordinates_indices - ones(size(coordinates_indices)) + transform(:, 4).';

%       % offset
      coordinates_indices = coordinates_indices - ones(size(coordinates_indices));
      MNI_V = transform(:, 1:3)*coordinates_indices.' + transform(:, 4);
      MNI_V = MNI_V.';
end