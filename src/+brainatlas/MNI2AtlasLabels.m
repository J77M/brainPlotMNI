function [channelsLabels, channelsApproxDist, channelsProbs] = ... 
    MNI2AtlasLabels(channelsMNI, atlasMNI, atlaslabels, areasNumbers, areasLabels, radius, atlasIgnore)
% MNI2ATLASLABELS - Maps channel MNI coordinates to named atlas labels.
%   Wraps MNI2Atlas to provide human-readable string labels. Converts
%   numeric atlas labels to the corresponding area names and filters out
%   low-probability label assignments (below 10%).
% Syntax:
%   [labels, dist, probs] = MNI2AtlasLabels(channelsMNI, atlasMNI, atlasLabels, areasNumbers, areasLabels)
%   [labels, dist, probs] = MNI2AtlasLabels(..., radius, atlasIgnore)
% Input Arguments:
%   - channelsMNI (Nx3 double) - MNI coordinates of channels/electrodes.
%   - atlasMNI (Mx3 double) - MNI coordinates of atlas voxels (from volume2MNI).
%   - atlasLabels (Mx1 int16) - Numeric label of each atlas voxel (from volume2MNI).
%   - areasNumbers (Kx1 int16) - Numeric identifiers of each atlas area.
%   - areasLabels (Kx1 string) - String names of each atlas area (same order as areasNumbers).
%   - radius (double) - Initial search sphere radius in mm (default: 5).
%   - atlasIgnore (int16) - Label value for unlabeled/background voxels (default: 0).
% Output Arguments:
%   - labels (Nx1 string) - Most probable atlas area name for each channel.
%   - dist (Nx1 double) - Distance in mm to nearest voxel of the assigned label.
%   - probs (Nx1 string) - Comma-separated string of label probabilities per channel,
%     filtered to entries above 10%, e.g. "L_MFG 85.3%, L_SFG 14.7%".
    
    arguments
        channelsMNI (:,3) double {mustBeReal}   % channels MNI coordinates
        atlasMNI (:,3) double {mustBeReal}      % MNI coordinates of atlas voxels
        atlaslabels (:,1) int16                 % labels (numeric) of atlas voxels
        areasNumbers (:,1) int16 {mustBeReal}   % labels (numeric) of atlas areas
        areasLabels (:,1) string                  % labels (string) of atlas areas, must correspond to areasNumbers
        radius (1,1) double {mustBeReal, mustBePositive} = 5  % [mm] initial sphere radius
        atlasIgnore (1,1) int16 = 0     % value/label of unlabeled voxels in the atlas (does not represent area)
        
    end
    prob_filter_val = 10; % in the probability of a label, it will only show labels with prob greater than 10%

    % REMOVE atlasIgnore voxels (voxels without label)
    atlasMNI = atlasMNI(atlaslabels ~= atlasIgnore, :);
    atlaslabels = atlaslabels(atlaslabels ~= atlasIgnore);

    % RUN MNI 2 ATLAS
    [channelsLabels_, channelsApproxDist, channelProbsLabels, channelProbs] = ... 
        brainatlas.MNI2Atlas(channelsMNI, atlasMNI, atlaslabels, radius);

    % convert to atlas string labels
    channelsLabels = cell(size(channelsLabels_));
    channelsProbs = cell(size(channelsLabels_));
    for ch= 1:length(channelsLabels)
        % get most probable label
        area_label = areasLabels{areasNumbers == channelsLabels_(ch)};
        channelsLabels{ch} = area_label;
        % filter probability of of labels
        histVals = channelProbs{ch};
        histLabels = channelProbsLabels{ch};
        histLabels = histLabels(histVals > prob_filter_val);
        histVals = histVals(histVals > prob_filter_val);
        histVals = histVals(:);
        % assign labels
        histLabels = arrayfun(@(x) areasLabels(areasNumbers == x), histLabels);
        % create string
        [~,idx] = sort(histVals,'descend');
        channelsProbs{ch} = strjoin(histLabels(idx) + " " + string(round(histVals(idx),1)) + "%", ", ");
    end

end
