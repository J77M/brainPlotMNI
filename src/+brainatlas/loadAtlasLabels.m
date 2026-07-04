function T_out = loadAtlasLabels(csvPath)
% LOADATLASLABELS - Reads an atlas CSV and collapses left/right indices.
%   Reads a CSV file containing either:
%   - LeftIndex, RightIndex, Label columns (laterality is split per row) -
%     collapses each pair into separate rows with L_/R_ prefixes.
%   - Index, Label columns (single bilateral index per row) - returned as-is.
%   If a BrodmanArea column exists in the left/right format, laterality
%   prefixes are omitted.
% Syntax:
%   T = loadAtlasLabels(csvPath) Reads and processes the atlas label CSV.
% Input Arguments:
%   - csvPath (char or string) - Path to the atlas CSV file. Must contain
%     either columns [LeftIndex, RightIndex, Label] or [Index, Label].
% Output Arguments:
%   - T (table) - Table with a single Index column (sorted), optionally
%     laterality-prefixed Label entries, and any additional columns preserved.

    arguments
        csvPath (1,1) string {mustBeFile}
    end

    T = readtable(csvPath, 'TextType', 'string');
    varNames = T.Properties.VariableNames;

    % single-index format: Index column already present, no laterality processing
    hasIndexSingle = ismember("Index", varNames) ...
        && ~any(ismember(["LeftIndex","RightIndex"], varNames));

    if hasIndexSingle
        assert(ismember("Label", varNames), ...
            'CSV must contain an Index and Label column.');
        T_out = sortrows(T, "Index");
        return
    end

    % left/right-index format: requires LeftIndex, RightIndex, Label
    assert(all(ismember(["LeftIndex","RightIndex","Label"], varNames)), ...
        'CSV must contain either [Index, Label] or [LeftIndex, RightIndex, Label] columns.');

    hasBrodman = ismember("BrodmanArea", varNames);

    nonIndexCols = setdiff(varNames, ["LeftIndex","RightIndex"]);

    T_left  = T;
    T_right = T;

    T_left.Index  = T.LeftIndex;
    T_right.Index = T.RightIndex;

    T_left(:,["LeftIndex","RightIndex"])  = [];
    T_right(:,["LeftIndex","RightIndex"]) = [];

    T_left  = movevars(T_left,  "Index", "Before", 1);
    T_right = movevars(T_right, "Index", "Before", 1);

    for i = 1:length(nonIndexCols)
        col = nonIndexCols(i);

        if isstring(T.(col)) || iscellstr(T.(col))

            T_left.(col)  = string(T_left.(col));
            T_right.(col) = string(T_right.(col));

            if col == "Label" || endsWith(col,"Gyrus")
                T_left.(col)  = "L_" + T_left.(col);
                T_right.(col) = "R_" + T_right.(col);
            else
                T_left.(col)  = "left "  + lowerFirst(T_left.(col));
                T_right.(col) = "right " + lowerFirst(T_right.(col));
            end
        end
    end

    T_out = [T_left; T_right];
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