function varargout = AREAplotConnectivity(hfig, MNIatlasVolume, atlasLabels, ROIsNumbers, connectivityMatrix, colors, opts)
% AREAplotConnectivity - Plots the Colin27 MNI volume with ROI spheres and connectivity lines.
%   Displays a sphere at each ROI centroid and draws lines between connected ROIs.
%   The connectivityMatrix encodes connection strength; zero or NaN entries are skipped.
%   Only unique (i,j) pairs are drawn (upper triangle of the matrix).
% Syntax:
%   hfig = AREAplotConnectivity(hfig, MNIatlasVolume, atlasLabels, ROIsNumbers, connectivityMatrix, colors) Basic usage.
%   [hfig, axs, tLayout] = AREAplotConnectivity(..., Name, Value) Returns axes handles and accepts options.
% Input Arguments:
%   - hfig (figure handle) - Target figure.
%   - MNIatlasVolume (Nx3 double) - MNI coordinates of all atlas voxels.
%   - atlasLabels (Nx1 double) - Atlas label index for each voxel in MNIatlasVolume.
%   - ROIsNumbers (1xM double) - Atlas label numbers of ROIs to display.
%   - connectivityMatrix (MxM double) - Connectivity values; 0 or NaN entries are not drawn.
%   - colors (1xM cell) - Sphere color for each ROI; length must match ROIsNumbers.
% Name-Value Options:
%   - brainSmoothness (double) - Brain envelope smoothness as a percentage (default 15).
%   - figTitle - Figure title; nan means no title (default nan).
%   - views (cell) - Views as named string labels or 1x2 [az, el] pairs (default {'left','front','top'}).
%   - backgroundClr - Background color (default 'w').
%   - brainClr - Brain envelope color (default 'k').
%   - axesClr - Axes and label color (default 'k').
%   - alphaTemplate (double) - Brain envelope face transparency 0-1 (default 0.04).
%   - mapViewLabels (logical) - Map view names to anatomical terms (default false).
%   - camlight (logical) - Apply camlight and Gouraud lighting per view (default false).
%   - alpha (double) - Sphere face transparency 0-1 (default 0.5).
%   - sphereRadius (double) - Sphere radius in mm (default 3).
%   - lineColor - Connectivity line color (default '#0072BD').
%   - lineWidth (double) - Connectivity line width in points (default 2.5).
% Output Arguments:
%   - hfig (figure handle) - The figure handle.
%   - axs (1xN axes array) - Axes handles, one per view tile (optional).
%   - tLayout (TiledChartLayout) - The tiledlayout handle (optional).

    arguments
        hfig
        MNIatlasVolume
        atlasLabels
        ROIsNumbers
        connectivityMatrix
        colors
        opts.brainSmoothness (1,1) double = 15
        opts.figTitle = nan
        opts.views (1,:) cell = {'left', 'front', 'top'}
        opts.backgroundClr = 'w'
        opts.brainClr = 'k'
        opts.axesClr = 'k'
        opts.alphaTemplate (1,1) double = 0.04
        opts.mapViewLabels (1,1) logical = false
        opts.camlight (1,1) logical = false
        opts.alpha (1,1) double = 0.5
        opts.sphereRadius (1,1) double = 3
        opts.lineColor = '#0072BD'
        opts.lineWidth (1,1) double = 2.5
    end

    assert(length(ROIsNumbers) == length(colors), ...
        "number of colors must be the same as number of ROIs")

    % -- call BRAINplot to set up figure and axes
    [hfig, axs, tLayout] = brainvis.BRAINplot(hfig, MNIatlasVolume, ...
        'brainSmoothness', opts.brainSmoothness, ...
        'figTitle', opts.figTitle, ...
        'views', opts.views, ...
        'backgroundClr', opts.backgroundClr, ...
        'brainClr', opts.brainClr, ...
        'axesClr', opts.axesClr, ...
        'alphaTemplate', opts.alphaTemplate, ...
        'mapViewLabels', opts.mapViewLabels, ...
        'camlight', opts.camlight);

    nROIs = length(ROIsNumbers);

    % -- compute ROI centroids
    centers = zeros(nROIs, 3);
    for roi = 1:nROIs
        centers(roi, :) = mean(MNIatlasVolume(atlasLabels == ROIsNumbers(roi), :), 1);
    end

    % -- precompute sphere unit mesh (reused for all ROIs)
    [Xs, Ys, Zs] = sphere(20);

    % -- precompute unique ROI pairs for connectivity lines
    pairs = nchoosek(1:nROIs, 2);

    % -- plot spheres and connections on each view axis
    for v = 1:length(axs)
        hold(axs(v), 'on')

        % spheres at ROI centroids
        for roi = 1:nROIs
            cx = centers(roi, 1); cy = centers(roi, 2); cz = centers(roi, 3);
            surf(axs(v), Xs*opts.sphereRadius + cx, Ys*opts.sphereRadius + cy, Zs*opts.sphereRadius + cz, ...
                'FaceColor', colors{roi}, 'EdgeColor', 'none', 'FaceAlpha', opts.alpha)
        end

        % connectivity lines between unique ROI pairs
        for p = 1:size(pairs, 1)
            i = pairs(p, 1); j = pairs(p, 2);
            if connectivityMatrix(i, j) == 0 || isnan(connectivityMatrix(i, j))
                continue
            end
            plot3(axs(v), centers([i, j], 1), centers([i, j], 2), centers([i, j], 3), ...
                'Color', opts.lineColor, 'LineWidth', opts.lineWidth, 'Marker', 'none')
        end

        % workaround for scaling of fugures (axis limits being reset by plot calls?)
        pbaspect(axs(v), [1, 1, 1]);
        xlim(axs(v), [-89, 90]);
        ylim(axs(v), [-108, 73]);
        zlim(axs(v), [-74.5, 104.5]);
    end

    % -- output
    varargout{1} = hfig;
    if nargout > 1
        varargout{2} = axs;
    end
    if nargout > 2
        varargout{3} = tLayout;
    end

end
