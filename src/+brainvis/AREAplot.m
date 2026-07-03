function varargout = AREAplot(hfig, MNIatlasVolume, atlasLabels, ROIsNumbers, colors, opts)
%   AREAplot - Plots the Colin27 MNI volume with colored atlas ROI regions.
%   Displays selected atlas ROIs as alpha shapes with configurable colors and views.
%   Each ROI is shown with a color corresponding to its index in the colors cell array.
%   ROIsNumbers are defined by the atlas used, see the relevant .csv file or the documentation of the atlas.
% Syntax:
%   hfig = AREAplot(hfig, MNIatlasVolume, atlasLabels, ROIsNumbers, colors) Basic usage.
%   [hfig, axs, tLayout] = AREAplot(..., Name, Value) Returns axes handles and accepts options.
% Input Arguments:
%   - hfig (figure handle) - Target figure.
%   - MNIatlasVolume (Nx3 double) - MNI coordinates of all atlas voxels.
%   - atlasLabels (Nx1 double) - Atlas label index for each voxel in MNIatlasVolume.
%   - ROIsNumbers (1xM double) - Atlas label numbers of ROIs to display.
%   - colors (1xM cell) - Color for each ROI; length must match ROIsNumbers.
% Name-Value Options:
%   - brainSmoothness (double) - Brain envelope smoothness as a percentage (default 15).
%   - roiSmoothness (double) - ROI alpha shape smoothness as a percentage (default 20).
%   - figTitle - Figure title; nan means no title (default nan).
%   - alpha (double) - ROI face transparency 0-1 (default 0.75).
%   - views (cell) - Views as named string labels or 1x2 [az, el] pairs (default {'left','front','top'}).
%   - backgroundClr - Background color (default 'w').
%   - objectsClr - Axes and label color (default 'k').
%   - alphaTemplate (double) - Brain envelope face transparency 0-1 (default 0.04).
%   - mapViewLabels (logical) - Map view names to anatomical terms (default false).
%   - camlight (logical) - Apply camlight and Gouraud lighting per view after plotting (default false).
% Output Arguments:
%   - hfig (figure handle) - The figure handle.
%   - axs (1xN axes array) - Axes handles, one per view tile (optional).
%   - tLayout (TiledChartLayout) - The tiledlayout handle (optional).

    arguments
        hfig
        MNIatlasVolume
        atlasLabels
        ROIsNumbers
        colors
        opts.brainSmoothness (1,1) double = 15
        opts.roiSmoothness (1,1) double = 20
        opts.figTitle = nan
        opts.alpha (1,1) double = 0.75
        opts.views (1,:) cell = {'left', 'front', 'top'}
        opts.backgroundClr = 'w'
        opts.objectsClr = 'k'
        opts.alphaTemplate (1,1) double = 0.04
        opts.mapViewLabels (1,1) logical = false
        opts.camlight (1,1) logical = false
    end

    assert(length(ROIsNumbers) == length(colors), ...
        "number of colors must be the same as number of ROIs")

    roiSmoothness = opts.roiSmoothness / 100;

    % -- call BRAINplot to set up figure and axes
    [hfig, axs, tLayout] = brainvis.BRAINplot(hfig, MNIatlasVolume, ...
        'brainSmoothness', opts.brainSmoothness, ...
        'figTitle', opts.figTitle, ...
        'views', opts.views, ...
        'backgroundClr', opts.backgroundClr, ...
        'objectsClr', opts.objectsClr, ...
        'alphaTemplate', opts.alphaTemplate, ...
        'mapViewLabels', opts.mapViewLabels, ...
        'camlight', opts.camlight);

    % -- build ROI alpha shapes (once, before axes loop)
    roiShapes = cell(1, length(ROIsNumbers));
    for roi = 1:length(ROIsNumbers)
        MNI_ROI = MNIatlasVolume(atlasLabels == ROIsNumbers(roi), :);
        idx = 1:round(1/roiSmoothness):size(MNI_ROI, 1);
        roiShapes{roi} = alphaShape(MNI_ROI(idx, :));
    end

    % -- plot ROIs on each view axis
    for v = 1:length(axs)
        axes(axs(v));
        for roi = 1:length(ROIsNumbers)
            plot(roiShapes{roi}, 'FaceColor', colors{roi}, 'FaceAlpha', opts.alpha, 'EdgeColor', 'none');
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