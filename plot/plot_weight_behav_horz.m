function plot_weight_behav_horz(res, weight, iweight, wfname)
% plot_weight_behav_horz
%
% # Syntax
%   plot_weight_behav_horz(res, weight, iweight, wfname)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

% This file is part of CCA/PLS Toolkit.
%
% CCA/PLS Toolkit is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% CCA/PLS Toolkit is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with CCA/PLS Toolkit. If not, see <https://www.gnu.org/licenses/>.

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for behaviour...', 'any', res.behav.file.label);
T = readtable(labelfname);
if ~ismember('Label', T.Properties.VariableNames) % check if necessary fields available
    error('The behavioural label file should contain the following columns: Label');
end
iscategory = ismember('Category', T.Properties.VariableNames);
if ~iscategory
    T.Category = sprintfc('%d', ones(size(T, 1), 1));
end

% Open figure
if ~isempty(res.gen.figure.Position)
    figure('Position', res.gen.figure.Position);
else
    figure;
end

% Set colors for the categories
categ = unique(T.Category);
cmap = colormap('jet');
if size(cmap, 1) < numel(categ)
    error('Too many groups, not enough colors to plot them.')
end
cmap = cmap(round(linspace(1,size(cmap, 1),numel(categ))),:);

% Normalize weight
if strcmp(res.behav.weight.norm, 'minmax')
    minmax = max(abs(weight));
    weight = weight / minmax;
elseif strcmp(res.behav.weight.norm, 'std')
    weight = weight / std(weight);
elseif strcmp(res.behav.weight.norm, 'zscore')
    weight = zscore(weight);
end

% Create weight table
T.Weight = weight;
T = T(iweight,:); % reorder table based on the order of the weight
if ~isinf(res.behav.weight.numtop) || res.behav.weight.filtzero
    T(T.Weight==0,:) = []; % remove 0 weights
end

% Subselect category colours
[C, ia, ib] = intersect(categ, unique(T.Category));
cmap = cmap(ia,:);
categ = unique(T.Category);

% Plot weights
hold on;
for i=1:numel(categ)
    dummy = T.Weight;
    dummy(~ismember(T.Category, categ{i})) = 0;
    barh(dummy, 'FaceColor', cmap(i,:));
end
hold off;

% User friendly display for long label names
if ~isinf(res.behav.label.maxchar)
    for i=1:size(T, 1)
        if numel(T.Label{i}) > res.behav.label.maxchar
            T.Label{i} = T.Label{i}(1:res.behav.label.maxchar);
        end
    end
end

% Plot labels
ylabel(res.behav.ylabel);
xlabel(res.behav.xlabel);

% Update legend and axes
if iscategory
    name_value = parse_struct(res.gen.legend);
    legend(categ, name_value{:});
end
name_value = parse_struct(res.gen.axes);
set(gca, 'yTick', 1:numel(T.Label), 'yTickLabel', T.Label, name_value{:});

% Save figure
saveas(gcf, [wfname res.gen.figure.ext]);

% Save weights to csv
if iscategory
    writetable(T(:,{'Category' 'Label' 'Weight'}), [wfname '.csv'], ...
        'QuoteStrings', true);
else
    writetable(T(:,{'Label' 'Weight'}), [wfname '.csv'], 'QuoteStrings', true);
end