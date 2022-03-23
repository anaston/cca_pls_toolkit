function plot_weight_behav_vert(res, weight, iweight, wfname)
% plot_weight_behav_vert
%
% Syntax:  plot_weight_behav_vert(res, weight, iweight, wfname)

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
    bar(dummy, 'FaceColor', cmap(i,:));
end
hold off;

% Plot labels
ylabel(res.behav.ylabel);
xlabel(res.behav.xlabel);

% Update legend and axes
if numel(categ) > 1
    name_value = parse_struct(res.gen.legend);
    legend(categ, name_value{:});
end
name_value = parse_struct(res.gen.axes);
set(gca, name_value{:});

% Save figure
saveas(gcf, [wfname res.gen.figure.ext]);

% Save weights to csv
if iscategory
    writetable(T(:,{'Category' 'Label' 'Weight'}), [wfname '.csv'], ...
        'QuoteStrings', true);
else
    writetable(T(:,{'Label' 'Weight'}), [wfname '.csv'], 'QuoteStrings', true);
end