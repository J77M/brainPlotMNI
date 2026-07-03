function T_out = loadAtlasLabels(csvPath)
% LOADATLASLABELS - Reads an atlas CSV and collapses left/right indices.
%   Reads a CSV file containing LeftIndex, RightIndex, and Label columns
%   and collapses each pair of left/right rows into separate single-indexed
%   rows with laterality prefixes (L_ or R_). If a BrodmanArea column exists,
%   laterality prefixes are omitted.
% Syntax:
%   T = loadAtlasLabels(csvPath) Reads and processes the atlas label CSV.
% Input Arguments:
%   - csvPath (char or string) - Path to the atlas CSV file. Must contain
%     columns: LeftIndex, RightIndex, Label.
% Output Arguments:
%   - T (table) - Table with a single Index column (sorted), laterality-
%     prefixed Label entries, and any additional columns preserved.

    arguments
        csvPath (1,1) string {mustBeFile}
    end

    T = readtable(csvPath, 'TextType', 'string');
    
    % Validate required columns
    requiredCols = ["LeftIndex","RightIndex","Label"];
    if ~all(ismember(requiredCols, T.Properties.VariableNames))
        error('CSV must contain LeftIndex, RightIndex, and Label columns.');
    end
    
    % Check whether BrodmanArea exists
    hasBrodman = ismember("BrodmanArea", T.Properties.VariableNames);
    
    % Identify columns to modify (all except indices)
    varNames = T.Properties.VariableNames;
    nonIndexCols = setdiff(varNames, ["LeftIndex","RightIndex"]);
    
    % Prepare output container
    T_left  = T;
    T_right = T;
    
    % Replace Index columns
    T_left.Index  = T.LeftIndex;
    T_right.Index = T.RightIndex;
    
    % Remove old index columns
    T_left(:,["LeftIndex","RightIndex"])  = [];
    T_right(:,["LeftIndex","RightIndex"]) = [];
    
    % Reorder so Index is first column
    T_left  = movevars(T_left,  "Index", "Before", 1);
    T_right = movevars(T_right, "Index", "Before", 1);
    
    % Add laterality
    for i = 1:length(nonIndexCols)
        col = nonIndexCols(i);
        
        % Only modify string/text columns
        if isstring(T.(col)) || iscellstr(T.(col))
            
            % Convert to string for safety
            T_left.(col)  = string(T_left.(col));
            T_right.(col) = string(T_right.(col));
            
            % if col == "BrodmanArea"
            %     continue;
            % end
            if col == "Label" || endsWith(col,"Gyrus")
                % Prefix style (L_ / R_)
                T_left.(col)  = "L_" + T_left.(col);
                T_right.(col) = "R_" + T_right.(col);
            else
                % Textual laterality
                T_left.(col)  = "left "  + lowerFirst(T_left.(col));
                T_right.(col) = "right " + lowerFirst(T_right.(col));
            end
        end
    end
    
    % Concatenate left and right
    T_out = [T_left; T_right];
    
    % Sort by Index
    T_out = sortrows(T_out, "Index");
    
end


function s = lowerFirst(s)
% lowerFirst – makes first letter lowercase (for natural phrasing)
    s = string(s);
    if strlength(s) > 0
        firstChar = extractBetween(s,1,1);
        s = replaceBetween(s,1,1,lower(firstChar));
    end
end