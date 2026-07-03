function [channelsLabels, channelsApproxDist, channelProbsLabels, channelProbs] = MNI2Atlas(channelsMNI, atlasMNI, atlaslabels, radiusInit, opts)
% MNI2ATLAS - Maps channel MNI coordinates to atlas labels via spherical search.
%   For each channel, grows a sphere from radiusInit up to maxRadius until it
%   intersects labeled atlas voxels. The most frequent label within the
%   sphere is assigned. Does not distinguish between white matter and
%   undefined voxels in the atlas; use the returned distance to assess
%   confidence (large distances may indicate white matter localization).
% Syntax:
%   [labels, dist] = MNI2Atlas(channelsMNI, atlasMNI, atlasLabels, radiusInit)
%   [labels, dist, probLabels, probs] = MNI2Atlas(..., radiusInit, Name, Value)
% Input Arguments:
%   - channelsMNI (Nx3 double) - MNI coordinates of channels/electrodes.
%   - atlasMNI (Mx3 double) - MNI coordinates of atlas voxels (from volume2MNI).
%   - atlasLabels (Mx1 numeric) - Label of each atlas voxel (from volume2MNI).
%   - radiusInit (double) - Initial search sphere radius in mm.
% Name-Value Options:
%   - maxRadius (double) - Maximum search sphere radius in mm (default: 10).
% Output Arguments:
%   - labels (Nx1 double) - Most probable atlas label for each channel (nan if not localized).
%   - dist (Nx1 double) - Distance in mm to nearest voxel of the assigned label.
%   - probLabels (Nx1 cell) - Cell array of all label candidates per channel.
%   - probs (Nx1 cell) - Cell array of label probabilities (percentage) per channel.

    arguments
        channelsMNI (:,3) double {mustBeReal}
        atlasMNI (:,3) double {mustBeReal}
        atlaslabels (:,1) double
        radiusInit (1,1) double {mustBeReal, mustBePositive}
        opts.maxRadius (1,1) double {mustBeReal, mustBePositive} = 10
    end

    radiusIncr = 1; % [mm]
    numChannels = size(channelsMNI, 1);

    % allocate labels for channels
    channelsLabels = zeros(numChannels, 1);
    % allocate approx distatnces for channels
    channelsApproxDist = zeros(numChannels, 1);
    % allocate for statistics
    if nargout > 2
        channelProbsLabels = cell(numChannels, 1);
        channelProbs = cell(numChannels, 1);
    end

    % find label for each channel
    for ch = 1:numChannels
        localized = false;
        radius = radiusInit;
        while (~localized) && radius <= opts.maxRadius
            input_MNI = channelsMNI(ch, :);
    
            % compute distances between inputcoordinate and all volume coordinates 
            distances = sqrt(sum((atlasMNI - input_MNI).^2, 2));
            % find indices of coordinates within the sphere
            indices_within_sphere = distances <= radius;
            
            % get labels of coordinates_in
            labels_in = atlaslabels(indices_within_sphere);

            % check any atlas areas found in 
            if ~isempty(labels_in)
                % find unique labels and counts
                unique_labels = unique(labels_in);
                label_counts = histcounts(labels_in, [unique_labels; max(unique_labels)+1]);
                % find the label that occurred the most times
                [~, max_count_index] = max(label_counts);
                % save statistics
                if nargout > 2 
                    channelProbsLabels{ch} = unique_labels;
                    channelProbs{ch} = 100*label_counts./sum(label_counts);
                end
                % get the most common label
                most_common_label = unique_labels(max_count_index);
                localized = true;
            else
                radius = radius + radiusIncr;
            end
        end
        
        % compute distance to nearest voxel of the most common label
        if localized
            channelsApproxDist(ch) = round(min(distances(atlaslabels == most_common_label)), 3);
        else
            channelsApproxDist(ch) = nan;
            most_common_label = nan;
        end
        channelsLabels(ch) = most_common_label;
    end

end

