function plot_paropt(res, split, metrics, varargin)
% plot_paropt
%
% It plots the grid search results of the hyperparameter optimization. 
%
% # Syntax
%   plot_paropt(res, split, metrics, varargin)
%
% # Inputs
% res:: struct 
%   res structure containing information about results and plot specifications
% split:: int
%   index of data split to be used
% metrics:: 'trcorrel', 'correl', 'trcovar', 'covar', 'trexvarx', 'exvarx', 'trexvary', 'exvary', 'simwx', 'simwy', 'simwxy', 'correl+simwxy'
%   metrics to be plotted as a function of hyperparameter grid, each metric 
%   in a separate subplot
% varargin:: name-value pairs
%   additional options can be passed via name-value pairs with dot notation
%   supported
%
% # Examples
%    % Plot hyperparameter surface for grid search results
%    plot_paropt(res, 1, {'correl', 'simwx', 'simwy'}, ...
%    'gen.figure.Position', [500 600 1200 400], 'gen.axes.FontSize', 20, ...
%    'gen.axes.XScale', 'log', 'gen.axes.YScale', 'log');
%
% ![hyperparameter_surface](../figures/example_simul_paropt.png)
%
% ---
% See also: [plot_proj](../plot_proj), [plot_weight](../plot_weight)
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

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Parse input and add default settings
res = res_defaults(res, 'paropt', varargin{:});

% Get grid search results
[param, S] = get_hyperparam(res, 'grid');

% Compute combined similarity and distance metric
for i=1:res.frwork.split.nall
    if any(contains(metrics, 'simwxy')) || any(contains(metrics, 'dist'))
        S.simwxy(i,:) = nanmean([S.simwx(i,:); S.simwy(i,:)], 1);
    end
    if ismember('dist', metrics)
        S.dist(i,:) = calc_distance(S.correl(i,:), S.simwxy(i,:));
    end
end

% Number of hyperparameter levels
p = cfg.machine.param.name; % shorthand variable
num = cell(1, numel(p));
for i=1:numel(p)
    num{i} = numel(cfg.machine.param.(p{i}));
end

% Remove parameters with 1 level
param = rmfield(param, p(cellfun(@(x) x==1, num)));
p(cellfun(@(x) x==1, num)) = [];
num(cellfun(@(x) x==1, num)) = [];

% Reshape data
for i=1:numel(metrics)
    S.(metrics{i}) = permute(S.(metrics{i}), [2 1]); % swap dimensions
    S.(metrics{i}) = reshape(S.(metrics{i}), num{:}, res.frwork.split.nall);
end

% Create figure
if ~isempty(res.gen.figure.Position)
    figure('Position', res.gen.figure.Position);
else
    figure;
end

% Plot grid search reasults for each metric as a subplot
if numel(p) == 1
    % Line plot as a function of 1 hyperparameter
    for i=1:numel(metrics)
        subplot(1, numel(metrics), i);
        plot_2D(res, S.(metrics{i})(:,split), p, metrics{i});
    end
    saveas(gcf, fullfile(res.dir.res, sprintf('parOpt_split%d%s', split, res.gen.figure.ext)));
    
elseif numel(p) == 2
    % Surface plot as a function of 2 hyperparameters
    for i=1:numel(metrics)
        subplot(1, numel(metrics), i);
        plot_3D(res, S.(metrics{i})(:,:,split), param(split), metrics{i});
    end
    saveas(gcf, fullfile(res.dir.res, sprintf('parOpt_split%d%s', res.frwork.split.all(split), res.gen.figure.ext)));
end


% --------------------------- Private functions ---------------------------

function plot_2D(res, data, fn, ylab)

cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Plot data
if ismember(fn{1}, {'L2x' 'L2y'})
    plot(1-cfg.machine.param.(fn{1}), data);
    xlabel(['1 - ' fn{1}]);
else
    plot(cfg.machine.param.(fn{1}), data);
    xlabel(fn{1});
end

% Add ylabel
ylabel(metric2str(ylab));

% Update axes properties
name_value = parse_struct(res.gen.axes);
parse_input(gca, name_value{:});


function plot_3D(res, data, param, zlab)

cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

fields = fieldnames(param);

% Plot data
[Y, X] = meshgrid(cfg.machine.param.(fields{2}), cfg.machine.param.(fields{1}));
if all(ismember(fields, {'L2x' 'L2y'}))
    surf(1-X, 1-Y, data);
    hold on;
    plot3(gca, 1-repmat(param.(fields{1}), 1, 2), 1-repmat(param.(fields{2}), 1, 2), ...
        get(gca, 'ZLim'), 'r', 'LineWidth', 2);
    xlabel(['1 - ' fields{1}]);
    ylabel(['1 - ' fields{2}]);
else
    surf(X, Y, data);
    hold on;
    plot3(gca, repmat(param.(fields{1}), 1, 2), repmat(param.(fields{2}), 1, 2), ...
        get(gca, 'ZLim'), 'r', 'LineWidth', 2);
    xlabel(fields{1});
    ylabel(fields{2});
end

% Add zlabel
zlabel(metric2str(zlab));

% Update axes properties
name_value = parse_struct(res.gen.axes);
parse_input(gca, name_value{:});

% Add view to help assessment
view(res.param.view(1), res.param.view(2));


function str = metric2str(metric)

% Add zlabel
switch metric
    case 'trcorrel'
        str = 'Training correlation';

    case 'correl'
        str = 'Test correlation';
    
    case 'dist'
        str = 'Distance';
    
    case 'simwxy'
        str = 'Average similarity of weigths';
    
    case 'simwx'
        str = 'Smilarity of X weights';
    
    case 'simwy'
        str = 'Smilarity of Y weights';
    
    case 'trexvary'
        str = 'Training explained variance of Y';
    
    case 'exvary'
        str = 'Explained variance of Y';
    
    case 'trexvarx'
        str = 'Training explained variance of X';
    
    case 'exvarx'
        str = 'Explained variance of X';
end