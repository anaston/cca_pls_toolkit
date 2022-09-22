function plot_weight_stem(res, weight, iweight, wfname, mod)
% plot_weight_stem
%
% # Syntax
%   plot_weight_stem(res, weight, iweight, wfname, mod)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

% Open figure
if ~isempty(res.gen.figure.Position)
    figure('Position', res.gen.figure.Position);
else
    figure;
end

idout = false(numel(weight), 1);

% Load true weight if exists
if exist(res.simul.weight.file.(mod), 'file')    
    % Load true weight
    data = load(res.simul.weight.file.(mod));
    field = fieldnames(data);
    weight_true = reshape(data.(field{1}), [], 1);

    % Sort weight
    [weight_true, iweight] = sort(weight_true, 'descend');

    if numel(weight_true) > 100
        idout = randperm(numel(weight_true))' < numel(weight_true)-99;
        weight_true(idout) = []; 
    end
end
    
% Update weight
weight = weight(iweight);
if ~isinf(res.simul.weight.numtop) || res.simul.weight.filtzero
    idout = weight==0;
end
weight(idout) = []; 

% Normalize weight
if strcmp(res.simul.weight.norm, 'minmax')
    minmax = max(abs(weight));
    weight = weight / minmax;
elseif strcmp(res.simul.weight.norm, 'std')
    weight = weight / std(weight);
end

% Plot weight
stem(find(~idout), weight);
lg = {'weight'};

% Plot labels
xlabel(res.simul.xlabel);
ylabel(res.simul.ylabel);

if exist(res.simul.weight.file.(mod), 'file')    
    % Normalize true weight to match scale
%     weight_true = weight_true / norm(weight_true) * norm(weight);
    % Normalize weight
    if strcmp(res.simul.weight.norm, 'minmax')
        minmax = max(abs(weight_true));
        weight_true = weight_true / minmax;
    elseif strcmp(res.simul.weight.norm, 'std')
        weight_true = weight_true / std(weight_true);
    end

    % Plot true weight
    hold on;
    stem(find(~idout), weight_true);
    lg = [lg {'true weight'}];
end

% Update legend and axes
name_value = parse_struct(res.gen.legend);
legend(lg, name_value{:});
name_value = parse_struct(res.gen.axes);
parse_input(gca, name_value{:});

saveas(gcf, [wfname res.gen.figure.ext]);