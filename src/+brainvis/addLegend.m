function leg = addLegend(names, colors, Ncols, height)
% ADDLEGEND - Creates a horizontal legend with colored dot markers.
%   Renders a legend from name/color pairs using dot markers, positioned
%   at the bottom of the current axes. Each entry appears as a colored dot.
% Syntax:
%   leg = addLegend(names, colors) Legend with one row per entry.
%   leg = addLegend(names, colors, Ncols) Legend arranged in Ncols columns.
%   leg = addLegend(names, colors, Ncols, height) Custom legend height.
% Input Arguments:
%   - names (1xN cellstr) - Legend entry labels.
%   - colors (1xN cell of char) - Marker colors for each entry.
%   - Ncols (double) - Number of legend columns (default: length(names)).
%   - height (double) - Legend box height in normalized units (default: 0.07).
% Output Arguments:
%   - leg (Legend handle) - The created legend object.

    if nargin < 3
        Ncols = length(names);
    end
    if nargin < 4
        height = 0.07;
    end

    dummy = zeros(length(names), 1);
    for s=1:length(names)
        dummy(s) = plot(nan,nan,'.', 'Color',colors{s}, 'MarkerSize',20);
    end

    leg = legend(dummy, names, 'Orientation', 'horizontal', ...
        'NumColumns', Ncols, 'Location', 'south');


    leg.TextColor = 'k'; % Ensure legend text color is white
    leg.Interpreter = 'none';
    leg.EdgeColor = 'k';
%     leg.Color = 'none';
    
    %  adjust the legend position
    pos_leg = get(leg, 'Position');
    pos_leg(3) = pos_leg(3) + 0.03; % PREVIOUSLY ADDED: + 0.15; 
    pos_leg(1) = (1-pos_leg(3))/2;
    pos_leg(2) = 0.01;  
    pos_leg(4) = height;  
    % pos_leg(3) = pos_leg(3) + 0.02; 
    set(leg, 'Position', pos_leg);
    leg.Box = 'off';
end