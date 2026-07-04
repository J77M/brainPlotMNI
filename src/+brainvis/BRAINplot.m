function [hfig, axs, tLayout] = BRAINplot(hfig, MNIatlasVolume, opts)
% BRAINPLOT - Plots the Colin27 MNI volume with configurable views.
%   Creates an empty 3D brain plot with tiled views, axis styling, anatomical
%   direction labels, and optional figure title. Serves as the shared base
%   function for MNIplot, ROIplot, and similar visualization functions.
% Syntax:
%   [hfig, axs, tLayout] = BRAINPLOT(hfig, MNIatlasVolume) Basic usage with default 3 views.
%   [hfig, axs, tLayout] = BRAINPLOT(hfig, MNIatlasVolume, Name, Value) With optional arguments.
% Input Arguments:
%   - hfig (figure handle) - Target figure.
%   - MNIatlasVolume (Nx3 double) - MNI coordinates of all atlas voxels.
% Name-Value Options:
%   - brainSmoothness (double) - Brain envelope smoothness as a percentage (default 15).
%   - figTitle - Figure title string; nan means no title (default nan).
%   - views (cell) - Views as named string labels or 1x2 [az, el] numeric pairs (default {'left','front','top'}).
%   - backgroundClr - Background and axes fill color (default 'w').
%   - brainClr - Brain envelope color (default 'k').
%   - axesClr - Axes, tick, and label color (default 'k').
%   - brainAlpha (double) - Brain envelope face transparency 0-1 (default 0.04).
%   - mapViewLabels (logical) - Map view names to anatomical terms, e.g. front->anterior (default false).
%   - camlight (logical) - Apply camlight and Gouraud lighting per view (default false).
% Output Arguments:
%   - hfig (figure handle) - The figure handle.
%   - axs (1xN axes array) - Array of axes handles, one per view tile.
%   - tLayout (TiledChartLayout) - The tiledlayout handle.

    arguments
        hfig
        MNIatlasVolume
        opts.brainSmoothness (1,1) double = 15
        opts.figTitle = nan
        opts.views (1,:) cell = {'left', 'front', 'top'}
        opts.backgroundClr = 'w'
        opts.brainClr = 'k'
        opts.axesClr = 'k'
        opts.brainAlpha (1,1) double = 0.04
        opts.mapViewLabels (1,1) logical = false
        opts.camlight (1,1) logical = false
    end

    smoothness = opts.brainSmoothness / 100;
    offset_text = 20;
    nViews = length(opts.views);

    % -- build brain envelope
    idx = 1:round(1/smoothness):size(MNIatlasVolume, 1);
    shp = alphaShape(MNIatlasVolume(idx, :));

    % -- prepare figure layout
    hfig.Color = opts.backgroundClr;
    tLayout = tiledlayout(1, nViews, 'Padding', 'compact', 'TileSpacing', 'compact');

    axs = gobjects(1, nViews);

    % -- iterate over views
    for v = 1:nViews
        nexttile
        plot(shp, 'FaceColor', opts.brainClr, 'FaceAlpha', opts.brainAlpha, 'EdgeColor', 'none')
        ax = gca;
        hold(ax, 'on')

        % resolve view specification to az, el and label
        [az, el, label, isNamed] = resolveView(opts.views{v});
        view(ax, az, el)

        % -- axis styling
        pbaspect(ax, [1, 1, 1])
        xlim(ax, [-89, 90])
        ylim(ax, [-108, 73])
        zlim(ax, [-74.5, 104.5])
        xlabel(ax, "MNI x [mm]")
        ylabel(ax, "MNI y [mm]")
        zlabel(ax, "MNI z [mm]")
        xticks(ax, [-50, 0, 50])
        yticks(ax, [-50, 0, 50])
        zticks(ax, [-50, 0, 50])
        grid(ax, 'off')
        set(ax, 'Color', opts.backgroundClr, 'XColor', opts.axesClr, ...
            'YColor', opts.axesClr, 'ZColor', opts.axesClr);
        set(ax, 'TickDir', 'out', 'TickLength', [0.02, 0.02]);
        disableDefaultInteractivity(ax);
        ax.Toolbar.Visible = 'off';

        % add tile title for named views when there are multiple tiles
        if nViews > 1 && isNamed
            displayLabel = label;
            if opts.mapViewLabels
                displayLabel = applyLabelMap(label);
            end
            title(ax, displayLabel, 'Color', opts.axesClr)
        end

        % add anatomical direction corner labels for named views only
        if isNamed
            axLims = [ax.XLim; ax.YLim; ax.ZLim];
            [text1, text2, p1, p2] = getDirectionLabels(label, axLims, offset_text, opts.mapViewLabels);
            if ~isempty(text1)
                text(ax, p1(1), p1(2), p1(3), text1, 'Color', opts.axesClr)
                text(ax, p2(1), p2(2), p2(3), text2, 'Color', opts.axesClr)
            end
        end

        % apply camlight and lighting if requested
        if opts.camlight
            camlight(ax);
            lighting(ax, 'gouraud');
        end

        axs(v) = ax;
    end

    % -- set figure title
    hasFigTitle = ~(isnumeric(opts.figTitle) && isscalar(opts.figTitle) && isnan(opts.figTitle));
    if hasFigTitle
        % workaround for tiledlayout title centering
        anot = annotation('textbox', [0.5 0.85 0.1 0.1], 'String', opts.figTitle, ...
            'FitBoxToText', 'on', 'EdgeColor', 'none');
        anot.Color = opts.axesClr;
        anot.FontName = tLayout.Title.FontName;
        anot.FontSize = tLayout.Title.FontSize;
        anot.UserData = 'CustomTitle';
        pause(0.5)
        newPos = [anot.Position(1) - anot.Position(3)/2 anot.Position(2:end)];
        set(anot, 'Position', newPos);
        pause(0.5)
    end

end

% -- local helper functions

function [az, el, label, isNamed] = resolveView(viewSpec)
    % resolves a view specification to az, el angles and a label string
    if isnumeric(viewSpec)
        az = viewSpec(1);
        el = viewSpec(2);
        label = '';
        isNamed = false;
        return
    end
    label = lower(viewSpec);
    isNamed = true;
    switch label
        case 'left'
            az = -90; el = 0;
        case 'right'
            az = 90;  el = 0;
        case 'front'
            az = 180; el = 0;
        case 'back'
            az = 0;   el = 0;
        case 'top'
            az = 0;   el = 90;
        case 'bottom'
            az = 0;   el = -90;
        otherwise
            az = 0; el = 0;
            isNamed = false;
    end
end

function displayLabel = applyLabelMap(label)
    % maps named view labels to anatomical direction terms
    map = containers.Map( ...
        {'front', 'back', 'top', 'bottom', 'left', 'right'}, ...
        {'anterior', 'posterior', 'superior', 'inferior', 'left', 'right'});
    if isKey(map, label)
        displayLabel = map(label);
    else
        displayLabel = label;
    end
end

function [text1, text2, p1, p2] = getDirectionLabels(label, axLims, offset, mapLabels)
    % returns corner direction text strings and [x,y,z] position vectors for a named view
    % axLims: [3x2] matrix [xMin xMax; yMin yMax; zMin zMax]
    minX = axLims(1,1) + offset; maxX = axLims(1,2) - offset;
    minY = axLims(2,1) + offset; maxY = axLims(2,2) - offset;
    minZ = axLims(3,1) + offset;
    switch label
        case {'left', 'right'}
            % lateral view: horizontal axis = Y (posterior/anterior)
            if mapLabels
                text1 = 'posterior'; text2 = 'anterior';
            else
                text1 = 'back'; text2 = 'front';
            end
            p1 = [5, minY, minZ];
            p2 = [5, maxY, minZ];
        case {'front', 'back'}
            % coronal view: horizontal axis = X (left/right)
            text1 = 'left'; text2 = 'right';
            p1 = [minX, 5, minZ];
            p2 = [maxX, 5, minZ];
        case {'top', 'bottom'}
            % axial view: horizontal axis = X (left/right)
            text1 = 'left'; text2 = 'right';
            p1 = [minX, minY, 5];
            p2 = [maxX, minY, 5];
        otherwise
            text1 = ''; text2 = '';
            p1 = []; p2 = [];
    end
end
