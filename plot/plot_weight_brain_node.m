function plot_weight_brain_node(res, weight, wfname)
% plot_weight_brain_node
%
% # Syntax
%   plot_weight_brain_node(res, weight, wfname)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for regions...', 'any', res.roi.file.label);
T = readtable(labelfname);

% Check if necessary fields available
if ~all(ismember({'X' 'Y' 'Z' 'Label'}, T.Properties.VariableNames))
    error(sprintf(['The ROI label file should contain the following columns: X, Y, Z, Label', ...
        '\n\nConsider BrainNet_GenCoord to generate X, Y, Z coordinates from volumetric atlas file']));
end
if ~ismember('Color', T.Properties.VariableNames)
    T.Color = ones(size(T, 1), 1);
end

% Weights
T.Size = weight;

% Remove regions we don't want to visualize
if ~isempty(res.roi.out)
    T(ismember(T.Index, res.roi.out),:) = [];
end

% Save results to text file
T = T(T.Size~=0,:);
[B, I] = sort(abs(T.Size), 'descend'); % sort nodes for easier readibility
T = T(I,:);
writetable(table(T.Label, T.Size, T.Color, 'VariableNames', {'Node' 'Weight' 'Color'}), [wfname '.csv']);

% Prepare BrainNet files (from scratch to avoid bad files)
T.Size = abs(T.Size / max(abs(T.Size)) * 2 * pi); % rescale to improve visualization
fname = init_brainnet(res, 'labelfname', labelfname, 'T', T);

% Plot brainnet
if exist(fname.options, 'file')
    BrainNet_MapCfg(fname.surf, fname.node, [wfname res.gen.figure.ext], fname.options);
else
    BrainNet_MapCfg(fname.surf, fname.node, [wfname res.gen.figure.ext]);
end