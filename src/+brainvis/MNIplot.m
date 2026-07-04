function varargout = MNIplot(hfig, MNIatlasVolume, MNIchannelsCell, colors, opts)
% MNIPLOT - Plots the Colin27 MNI volume with channel MNI coordinates.
%   Displays sets of MNI channel coordinates as colored scatter points.
%   Each element of MNIchannelsCell is an Nx3 matrix of MNI coordinates
%   displayed with the corresponding color from the colors cell array.
% Syntax:
%   hfig = MNIPLOT(hfig, MNIatlasVolume, MNIchannelsCell, colors) Basic usage.
%   [hfig, axs, tLayout] = MNIPLOT(..., Name, Value) Returns axes handles and accepts options.
% Input Arguments:
%   - hfig (figure handle) - Target figure.
%   - MNIatlasVolume (Nx3 double) - MNI coordinates of all atlas voxels.
%   - MNIchannelsCell (1xM cell) - Each cell contains an Nx3 matrix of MNI channel coordinates.
%   - colors (1xM cell) - Color for each channel set; length must match MNIchannelsCell.
% Name-Value Options:
%   - brainSmoothness (double) - Brain envelope smoothness as a percentage (default 15).
%   - figTitle - Figure title; nan means no title (default nan).
%   - markerSize (double) - Marker size for channel dots, scalar or 1xM array (default 5.7).
%   - views (cell) - Views as named string labels or 1x2 [az, el] pairs (default {'left','front','top'}).
%   - backgroundClr - Background color (default 'w').
%   - brainClr - Brain envelope color (default 'k').
%   - axesClr - Axes and label color (default 'k').
%   - brainAlpha (double) - Brain envelope face transparency 0-1 (default 0.04).
%   - mapViewLabels (logical) - Map view names to anatomical terms (default false).
%   - camlight (logical) - Apply camlight and Gouraud lighting per view (default false).
% Output Arguments:
%   - hfig (figure handle) - The figure handle.
%   - axs (1xN axes array) - Axes handles, one per view tile (optional).
%   - tLayout (TiledChartLayout) - The tiledlayout handle (optional).

    arguments
        hfig
        MNIatlasVolume
        MNIchannelsCell
        colors
        opts.brainSmoothness (1,1) double = 15
        opts.figTitle = nan
        opts.markerSize = 5.7
        opts.views (1,:) cell = {'left', 'front', 'top'}
        opts.backgroundClr = 'w'
        opts.brainClr = 'k'
        opts.axesClr = 'k'
        opts.brainAlpha (1,1) double = 0.04
        opts.mapViewLabels (1,1) logical = false
        opts.camlight (1,1) logical = false
    end

    assert(length(MNIchannelsCell) == length(colors), ...
        "number of colors must be the same as number of cells in MNIchannelsCell")

    % expand markerSize to per-set array if scalar
    if isscalar(opts.markerSize)
        markerSizes = opts.markerSize * ones(1, length(colors));
    else
        markerSizes = opts.markerSize;
    end

    % -- call BRAINplot to set up figure and axes
    [hfig, axs, tLayout] = brainvis.BRAINplot(hfig, MNIatlasVolume, ...
        'brainSmoothness', opts.brainSmoothness, ...
        'figTitle', opts.figTitle, ...
        'views', opts.views, ...
        'backgroundClr', opts.backgroundClr, ...
        'brainClr', opts.brainClr, ...
        'axesClr', opts.axesClr, ...
        'brainAlpha', opts.brainAlpha, ...
        'mapViewLabels', opts.mapViewLabels, ...
        'camlight', opts.camlight);

    % -- plot channel coordinates on each view axis
    for v = 1:length(axs)
        for s = 1:length(MNIchannelsCell)
            ch = MNIchannelsCell{s};
            plot3(axs(v), ch(:, 1), ch(:, 2), ch(:, 3), ...
                'Marker', '.', 'MarkerSize', markerSizes(s), 'LineStyle', 'none', 'Color', colors{s});
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
