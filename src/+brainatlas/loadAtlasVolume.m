function [Volume, transform] = loadAtlasVolume(atlasPath)
% LOADATLASVOLUME - Loads a NIfTI atlas volume and its affine transform.
%   Reads a .nii atlas file and extracts the 3D volume array and the sform
%   affine transformation matrix for converting voxel indices to MNI space.
% Syntax:
%   [Volume, transform] = loadAtlasVolume(atlasPath) Reads a .nii atlas file.
% Input Arguments:
%   - atlasPath (char or string) - Path to the NIfTI (.nii) atlas file.
% Output Arguments:
%   - Volume (3D numeric array) - Voxel values of the atlas image.
%   - transform (3x4 double) - Affine transformation matrix from voxel
%     indices to MNI coordinates (sform), assembled from srow_x/y/z.

    arguments
        atlasPath (1,1) string {mustBeFile}
    end

    % load atlas NIFTI file (.nii) using Image Processing and Computer Vision toolbox
    info = niftiinfo(atlasPath);
    Volume = niftiread(atlasPath);
    % https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html/document_view

    srow_x = info.raw.srow_x;
    srow_y = info.raw.srow_y;
    srow_z = info.raw.srow_z;
    transform = [srow_x; srow_y; srow_z];
end

