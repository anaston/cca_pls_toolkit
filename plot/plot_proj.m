function P = plot_proj(res, mod, level, sidvar, split, colour, func, varargin)
% plot_proj
%
% It plots the projections of the data (i.e., latent variables).
%
% # Syntax
%   plot_proj(res, mod, level, sidvar, split, colour, func, varargin)
%
% # Inputs
% res:: struct 
%   res structure containing information about results and plot specifications
% mod:: cell array 
%   modality of data to be used for plotting (i.e., `{'X', 'Y'}`) 
% level:: int or numeric array
%   level of associative effect with same dimensionality as `mod` or 
%   automatically extended (e.g., from int to numeric array)
% sidvar:: 'osplit', 'otrid', 'oteid', 'isplit', 'itrid',  'iteid'
%   specifies subjects to be used for plotting
%
%   first letter can be 'o' for outer or 'i' for inner split, followed by 
%   either 'trid' for training, 'teid' for test or 'split' for both 
%   training and test data
% split:: int or numeric array
%   index of data split to be used with same dimensionality as `mod` or 
%   automatically extended (e.g., from int to numeric array)
% colour:: 'none', char 
%   `'none'` for scatterplot with same colour for all subjects or it can be
%   used as a continuous colormap or for colouring different groups; there
%   are three ways to define the colour
% 
%   specify a variable, which can be loaded from a data file (e.g., `Y.mat`)
%   using the name of the variable defined in a label file (e.g., 
%   `LabelsY.csv`)
%
%   use `'training+test'` to colour-code the training and test sets
%
%   use any other string with a `'+'` sign (e.g., 'MDD+HC') to define the 
%   colour-code based on `group.mat`
% func:: '2d', '2d_group', '2d_cmap'
%   name of the specific plotting function (after plot_proj_* prefix) to
%   be called
% varargin:: name-value pairs
%   additional options can be passed via name-value pairs with dot notation
%   supported
%
% # Examples
%
% ## Simple plots
% Most often, we plot a brain latent variable vs. a behavioural latent variable
% for a specific level (i.e., associative effect).
%
%    % Plot data projections coloured by groups
%    plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.best, ...
%    'training+test', '2d_group', 'gen.axes.FontSize', 20, ...
%    'gen.legend.FontSize', 20, 'gen.legend.Location', 'NorthWest', ... 
%    'proj.scatter.SizeData', 120, 'proj.scatter.MarkerEdgeColor', 'k', ...
%    'proj.scatter.MarkerFaceColor', [0.3 0.3 0.9; 0.9 0.3 0.3]);  
%
% ![projection_plot](../figures/plot_proj_simple.png)
%
% ## Multi-level plots
% To plot projections aggregated over multiple levels, all you need to 
% specify is res.proj.multi_level = 1 and provide a 2D cell array of input 
% variable 'mod'. Input variables 'level' and 'split' should have the same 
% dimensionality or they will be extended automatically from 1-D or 2-D arrays
% (e.g. level = repmat(level, size(mod))).
%
%    % Plot data projections across levels (and averaged across modalities 
%    % in a level after standardization)
%    plot_proj(res, {'X' 'Y'; 'X' 'Y'}, [1 1; 2 2], 'osplit', res.frwork.split.best, ...
%              'none', '2d', 'proj.multi_label', 1);
%
% ---
% See also: [plot_paropt](../plot_paropt), [plot_weight](../plot_weight/)
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
res = res_defaults(res, 'projection', varargin{:});

% Add SPM if needed
if strcmp(res.gen.selectfile, 'interactive')
    set_path('spm');
end

% Match modalities, levels, splits and flips
if res.proj.multi_level && size(mod, 1) < 2
    error(['Please specify at least 2x2 modalities for multi level plotting! ' ...
        'See function description for more information.'])
end
if numel(level) == 1
    level = repmat(level, size(mod));
elseif size(level, 2) == 1
    level = repmat(level, 1, 2);
end
if numel(split) == 1
    split = repmat(split, size(mod));
elseif size(split, 2) == 1
    split = repmat(split, 1, 2);
end
if numel(res.proj.flip) == 1
    res.proj.flip = repmat(res.proj.flip, size(mod));
elseif size(res.proj.flip, 2) == 1
    res.proj.flip = repmat(res.proj.flip, 1, 2);
end

%----- Calculate projection separately for each axis

[nlevels, nmods] = size(mod);
for i=1:nlevels
    for j=1:nmods
        % Update res if needed
        if res.frwork.level ~= level(i)
            res.frwork.level = level(i);
            res = res_defaults(res, 'load');
        end
        
        % Load weights
        w = loadmat(res, fullfile(res.dir.res, 'model.mat'), ['w' mod{i,j}]);
        w = w(split(i,j,1),:)';
            
        if ismember(cfg.machine.name, {'pls' 'spls'})
            % Load data in input space
            [trdata, trid, tedata, teid] = load_data(res, mod(i,j), sidvar, squeeze(split(i,j,:)));

        else
            % Load data in feature space
            if ismember(sidvar, {'isplit' 'itrid' 'iteid'})
                error('Functionality not implemented yet. The models should be retrained.')
            end
            if ismember(sidvar, {'otrid' 'itrid' 'oext'})
                [trdata, trid] = load_data(res, {['R' mod{i,j}]}, ...
                    sidvar, squeeze(split(i,j,:)));
            else
                [trdata, trid, tedata, teid] = load_data(res, {['R' mod{i,j}]}, ...
                    sidvar, squeeze(split(i,j,:)));
            end
        end
         
        switch sidvar
            case {'otrid' 'itrid' 'oext'}
                data = trdata;
                sid = trid;
                
            case {'oteid' 'iteid' 'iext'}
                data = tedata;
                sid = teid;
                
            case {'osplit' 'isplit'}
                % Concatenate data
                if ismember(cfg.machine.name, {'cca' 'rcca'})
                    data = concat_data(trdata, tedata, {['R' mod{i,j}]}, trid, teid);
                else
                    data = concat_data(trdata, tedata, mod(i,j), trid, teid);
                end
                sid = any([trid teid], 2);
        end

        if ismember(cfg.machine.name, {'pls' 'spls'})
            % Project data in input space
            P(:,i,j) = calc_proj(data.(mod{i,j}), w);
            
        else
            % Load parameter
            param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
            
            % Define feature index
            featid = get_featid(trdata, param(split(i,j,1)), mod{i,j});
                    
            % Project data in feature space
            w = trdata.(['V' mod{i,j}])(:,featid)' * w;
            P(:,i,j) = calc_proj(data.(['R' mod{i,j}])(:,featid), w);
        end
                    
        % Flip sign if requested
        if res.proj.flip(i,j)
            P(:,i,j) = -P(:,i,j);
        end
    end
end

%----- Calculate mean over modalities to plot multiple levels

if res.proj.multi_level
    % Standardize data and calculate mean over modalities
    P = zscore(P);
    P = mean(P, 3);
    
    % Update axis labels (only 2D plots at the moment!)
    for i=1:nlevels
        axesLabels{i} = sprintf('Level %d (%s)', i, strjoin(mod(i,:), '-'));
    end
    res.proj.xlabel = axesLabels{1};
    res.proj.ylabel = axesLabels{2};
else
    P = squeeze(P);
end

%----- Define label (e.g. cluster or colormap)
if nargout == 1 && isempty(colour)
    return
else
    colour = strsplit(colour, '+');
end

if strcmp(colour{1}, 'none') % no group and no colormap
    grp = ones(cfg.data.nsubj, 1);
    lg = {''};
        
elseif all(ismember(colour, {'training' 'test'}))
    if numel(unique(split)) > 1
        error('This functionality works only with 1 splits of data.')
    end
    [~, oteid] = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid', 'oteid');
    grp = oteid(:,unique(split)) + 1;
    lg = colour;
    
elseif numel(colour) > 1 % groups based on cfg.data.group
    S = load(fullfile(res.dir.project, 'data', 'group.mat'), 'group');
    grp = S.group;
    lg = colour;

else % groups/colormap based on custom variable
    % Load data file
    fname = select_file(res, fullfile(res.dir.project, 'data'), ...
        ['Select data file including ' colour{1} '...'], 'mat', res.proj.file.data);
    D = load(fname);
    fieldname = fieldnames(D);
    
    % Load label file
    fname = select_file(res, fullfile(res.dir.project, 'data'), ...
        ['Select delimited label file including ' colour{1} '...'], 'any', res.proj.file.label);
    T = readtable(fname);
    if isnumeric(T.Label)
        T.Label = cellfun(@num2str, num2cell(T.Label), 'un', 0);
    end

    if ismember(colour{1}, T.Label)
        grp = D.(fieldname{1})(:,ismember(T.Label, colour{1}));
        if strfind(func, 'cmap')
            lg = colour{1};
        elseif strfind(func, 'group')
            if iscell(grp)
                [lg, ia, grp] = unique(grp);
            else
                g = unique(grp);
                if ismember(0, g)
                    grp = grp + 1;
                end
                lg = sprintfc([colour{1} ' %d'], g);
            end
        end
    else
        error('Grptype must match a field in the selected label file.')
    end
end

% Select relevant subjects
grp = grp(sid);

%----- Visualize projections/latent space

% Specify file name
if res.proj.multi_level
    fname = fullfile(res.dir.frwork, 'res', 'proj');
else
    fname = fullfile(res.dir.res, 'proj');
end
if ~strcmp(colour{1}, 'none')
    fname = sprintf('%s_%s', fname, colour{1});
end
if any(ismember(sidvar, {'osplit' 'otrid' 'oteid' 'iext'}))% outer splits
    fname = sprintf('%s_split%d', fname, split(1));
    if ~strcmp(sidvar, 'osplit')
        fname = sprintf('%s_%s', fname, sidvar(2:end));
    end 
elseif strcmp(sidvar, 'oext')
    fname = sprintf('%s_%s', fname, sidvar);
end

% Scatter plot
func = str2func(['plot_proj_' func]);
if isequal(func, @plot_proj_2d)
    func(res, P, fname);
else
    func(res, P, fname, grp, lg);
end