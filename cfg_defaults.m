function cfg = cfg_defaults(cfg, varargin)
% cfg_defaults
%
% Set defaults in your configuration (`cfg`) structure which will define 
% the settings of your analysis (e.g., machine, framework, statistical 
% inference). Use this function to update and add all necessary defaults to 
% your `cfg`. If you defined anything in your `cfg` before calling the 
% function, it won't overwrite those values. The path to the project folder 
% should be always defined in your `cfg` or passed as varargin, otherwise 
% the function throws an error. All the other fields are optional and can 
% be filled up by `cfg_defaults`.
%
% No results will be stored in the cfg structure. See [res_defaults](../res_defaults) 
% for more information on results.
%
% !!! note "Warning"
%     We strongly advise to inspect the output of `cfg_defaults` to make 
%     sure that the defaults are set as expected.
%
% # Syntax
%   cfg = cfg_defaults(cfg, varargin)
%
% # Inputs
% cfg:: struct
% varargin:: name-value pairs
%   additional parameters can be set via name-value pairs with dot notation 
%   supported (e.g., 'frwork.split.nout', 5)
%
% # Outputs
% cfg:: struct
%   configuration structure that has been updated with defaults
%   
% # Examples
%
%   % Example 1
%   [X, Y, wX, wY] = generate_data(1000, 100, 100, 10, 10, 1);
%
% ---
% See also: [cfg](../../cfg), [res_defaults](../res_defaults/)
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

def = parse_input([], varargin{:});

% Initialize cfg
if isempty(cfg)
    cfg = struct();
end
cfg = assign_defaults(cfg, def);

%----- Primary defaults

% Get toolkit version from git commit
[~, def.env.commit] = system('git rev-parse HEAD');

% Framework
def.frwork.name = 'holdout'; % holdout/permutation
def.frwork.flag = ''; % string to specify analysis in folder name

% Machine
def.machine.name = 'spls';

% Computer environment
def.env.comp = 'local'; % local/cluster
if ismac
    def.env.OS = 'mac';
elseif isunix
    def.env.OS = 'unix';
elseif ispc
    def.env.OS = 'pc';
end

% Verbosity level
% 1: detailed progress update with elapsed time info
% 2: detailed progress update
% 3: minimal progress update
def.env.verbose = 2;

% Data block structure (see exchangeability blocks below)
def.data.block = 0;
 
% Data modalities and confounds
def.data.mod = {'X' 'Y'};
def.data.conf = 0;

% Update fields
cfg = assign_defaults(cfg, def);

% Check that path to project folder exists
if ~isfield(cfg, 'dir') || ~isfield(cfg.dir, 'project')
    error('Path to project folder should be given.')
end

%----- Secondary defaults

% Data train-test splitting
switch cfg.frwork.name
    case 'holdout'
        % Multiple holdout framework (see Monteiro et al 2016 J Neurosci Methods)
        def.frwork.split.nout = 5;
        def.frwork.split.propout = 0.2;
        def.frwork.split.nin = 5;
        def.frwork.split.propin = 0.2;
        
    case 'permutation'
        % Permutation framework (see Smith et al Nat Neurosci 2015)
        % without train-test splitting
        def.frwork.split.nout = 1;
end

% Number of permutations in statistical inference
def.stat.nperm = 1000;

% Metrics to evaluate machines
def.machine.metric = {'trcorrel' 'correl'}; % correlation between projections
if strcmp(cfg.machine.name, 'spls')
    def.machine.metric = [def.machine.metric {'simwx' 'simwy'}]; % stability of weights
end

% Update fields
cfg = assign_defaults(cfg, def);

% Similarity metric
if any(contains(cfg.machine.metric, 'sim'))
    if strcmp(cfg.machine.name, 'spls')
        def.machine.simw = 'overlap-corrected';
    else
        def.machine.simw = 'correlation-Pearson';
    end
end

% Statistical inference
if cfg.stat.nperm ~= 0
    def.stat.crit = 'correl';
    def.stat.perm = 'train+test'; % 'train'
    def.stat.alpha = 0.05;
end

% Update fields
cfg = assign_defaults(cfg, def);

% Deflation formulation
if ~isfield(cfg.frwork, 'nlevel') || cfg.frwork.nlevel > 1
    if ismember(cfg.machine.name, {'pls' 'spls'})
        def.defl.name = 'pls-modeA';
    else
        cfg.defl.name = 'generalized'; % overwrite user's option to be safe
    end
    
    % Deflation strategy with data splitting
    def.defl.crit = 'correl';
end

% Filename suffix on cluster or set default
if strcmp(cfg.env.comp, 'cluster') && ~isempty(getenv('SGE_TASK_ID')) ...
        && ~strcmp(getenv('SGE_TASK_ID'), 'undefined')
    def.env.fileend = ['_' num2str(getenv('SGE_TASK_ID'))]; 
elseif strcmp(cfg.env.comp, 'cluster') && ~isempty(getenv('SLURM_ARRAY_TASK_ID'))
    def.env.fileend = ['_' num2str(getenv('SLURM_ARRAY_TASK_ID'))];
else
    def.env.fileend = '_1';
end

% Compression setting for saving files
def.env.save.compression = 1;

% Exchangeability blocks (EB) for restricted partitioning and permutation
% (see Winkler et al 2015 Neuroimage, https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM)
if cfg.data.block
    load(fullfile(cfg.dir.project, 'data', 'EB.mat'))
    if ~exist('EB', 'var')
        error('EB matrix not available');
    end
    
    % Columns of EB for restricted partitioning
    def.data.EB.split = 1:size(EB, 2);
    
    % Columns of EB for restricted permutations
    def.data.EB.stat = 1:size(EB, 2);
end

% Data path and preprocessing
if cfg.data.conf
    mod = [cfg.data.mod {'C'}]; % modalities including confound matrix
else
    mod = cfg.data.mod;
end
for i=1:numel(mod)
    def.data.(mod{i}).fname = fullfile(cfg.dir.project, 'data', [mod{i} '.mat']);
    def.data.(mod{i}).preproc = {'impute' 'zscore'};
end
if cfg.data.conf
    for i=1:numel(cfg.data.mod)
        def.data.(cfg.data.mod{i}).preproc = [def.data.(cfg.data.mod{i}).preproc {'deconf'}];
    end
end

% Update fields
cfg = assign_defaults(cfg, def);

% Data processing in details
for i=1:numel(mod)
    if ismember('impute', cfg.data.(mod{i}).preproc)
        def.data.(mod{i}).impute = 'median';
    end
    if ismember('deconf', cfg.data.(mod{i}).preproc)
        def.data.(mod{i}).deconf = 'standard';
    end
end

% Seed options for reproducibility
% this is important in case multiple jobs are started simultaneously on a
% cluster, avoids jobs running same hyperparameters and permutations
% simply uses the number of the fileend as seed
% default, shuffle, number or struct returned by rng
def.env.seed.split = 'default';
tmp = regexp(cfg.env.fileend, '_(\d+)\>', 'tokens');
def.env.seed.model = cellfun(@str2num, tmp{1});
def.env.seed.perm = 'default';

% Load data
if exist(cfg.data.X.fname, 'file') && exist(cfg.data.Y.fname, 'file')
    for m=1:numel(mod)
        % Access data without loading into memory
        matobj = matfile(cfg.data.(mod{m}).fname);
        if ismember(who(matobj), mod{m})
            data.(mod{m}) = matobj;
        else
            error('%s matrix not available in %s.', mod{m}, cfg.data.(mod{m}).fname);
        end
    end
else
    error('X and Y input data cannot be found in path, check your data folder.');
end

% Update fields
cfg = assign_defaults(cfg, def);

%----- Defaults set based on X, Y

% Maximum number of associative effects
if strcmp(cfg.defl.name, 'pls-regression')
    def.frwork.nlevel = min(size(data.X, 'X'));
else
    def.frwork.nlevel = min(cellfun(@(x) min(size(data.(x), x)), cfg.data.mod));
end
if isfield(cfg.frwork, 'nlevel') && cfg.frwork.nlevel > def.frwork.nlevel
    cfg.frwork.nlevel = def.frwork.nlevel;
end

% Data dimensionality
for i=1:numel(cfg.data.mod)
    if ~isfield(cfg.data, 'nsubj')
        cfg.data.nsubj = size(data.(cfg.data.mod{i}), cfg.data.mod{i}, 1);
    elseif size(data.(cfg.data.mod{i}), cfg.data.mod{i}, 1) ~= cfg.data.nsubj
        error('The number of examples do not match across data modalities');
    end
    cfg.data.(cfg.data.mod{i}).nfeat = size(data.(cfg.data.mod{i}), cfg.data.mod{i}, 2);
end

% Initialize machine hyperparameters
def.machine.param.name = {};

% Update fields
cfg = assign_defaults(cfg, def);

% Grid search settings for machines
for i=1:numel(cfg.data.mod)
    m = lower(cfg.data.mod{i}); % shorthand for modality in lowercase
    
    switch cfg.machine.name
        case {'pls' 'spls'}
            % Hyperparameter name
            if isempty(cfg.machine.param.name)
                cfg.machine.param.name = {['L1' m]};
            elseif ~ismember(['L1' m], cfg.machine.param.name)
                cfg.machine.param.name = [cfg.machine.param.name {['L1' m]}];
            end
            
            if strcmp(cfg.machine.name, 'pls')
                % Hyperparameter type
                cfg.machine.param.type = 'matched';
                
                % No grid search as L1 regularizaion used with fix 
                % parameter outside of SPLS range
                
            elseif strcmp(cfg.machine.name, 'spls')
                % Hyperparameter type
                def.machine.param.type = 'factorial';
                
                % L1 regularization hyperparameter
                def.machine.param.(['rangeL1' m]) = [1 sqrt(size(data.(upper(m)), upper(m), 2))];
            end
            
        case 'cca'
            % Hyperparameter name and type
            if isempty(cfg.machine.param.name)
                cfg.machine.param.name = {['L2' m]};
            elseif ~ismember(['L2' m], cfg.machine.param.name)
                cfg.machine.param.name = [cfg.machine.param.name {['L2' m]}];
            end
            def.machine.param.type = 'factorial';
            
            % Explained variance treated as hyperparameter
            if ismember(['VAR' m], cfg.machine.param.name)
                def.machine.param.(['rangeVAR' m]) = [0.1 1];
            end
            
            % PCA components treated as hyperparameter
            if ismember(['PCA' m], cfg.machine.param.name)
                dim = size(data.(upper(m)), upper(m));
                if strcmp(cfg.frwork.name, 'holdout')
                    dim(1) = dim(1) * (1 - cfg.frwork.split.propout) * (1 - cfg.frwork.split.propin);
                end
                def.machine.param.(['rangePCA' m]) = [1 floor(min(dim))];
            end
            
        case 'rcca'
            % Hyperparameter name and type
            if isempty(cfg.machine.param.name)
                cfg.machine.param.name = {['L2' m]};
            elseif ~ismember(['L2' m], cfg.machine.param.name)
                cfg.machine.param.name = [cfg.machine.param.name {['L2' m]}];
            end
            def.machine.param.type = 'factorial';
            
            % L2 regularization hyperparameter
            if strcmp(cfg.machine.name, 'rcca')
                def.machine.param.(['rangeL2' m]) = [1 size(data.(upper(m)), upper(m), 2)^2];
            end
    end
end

% Update fields
cfg = assign_defaults(cfg, def);

% Number of default hyperparameters
for i=1:numel(cfg.machine.param.name)
   if isfield(cfg.machine.param, (['range' cfg.machine.param.name{i}]))
       def.machine.param.(['n' cfg.machine.param.name{i}]) = 10;
   end
end

% Update fields
cfg = assign_defaults(cfg, def);

% Hyperparameter settings for machines
for i=1:numel(cfg.data.mod)
    m = lower(cfg.data.mod{i}); % shorthand for modality in lowercase
    
    switch cfg.machine.name
        case 'pls'
            % Uses SPLS with L1 regularization outside of range (see below)
            cfg.machine.param.(['L1' m]) = size(data.(upper(m)), upper(m), 2);
            
        case 'spls'
            % L1 regularization hyperparameter for sparsity
            % Note: logarithmic space for efficient L1 norm
            if ismember(['L1' m], cfg.machine.param.name)
                def.machine.param.(['L1' m]) = logspace(log10(cfg.machine.param.(['rangeL1' m])(1)), ...
                    log10(cfg.machine.param.(['rangeL1' m])(2)), cfg.machine.param.(['nL1' m]));
            end
   
        case 'cca'
            % RCCA with L2 regularization set to 0 (see above)
            cfg.machine.param.(['L2' m]) = 0;
            
            % Explained variance treated as hyperparameter
            if ismember(['VAR' m], cfg.machine.param.name)
                def.machine.param.(['VAR' m]) = linspace(cfg.machine.param.(['rangeVAR' m])(1), ...
                    cfg.machine.param.(['rangeVAR' m])(end), cfg.machine.param.(['nVAR' m]));
            end
            
            % PCA components treated as hyperparameter
            if ismember(['PCA' m], cfg.machine.param.name)
                def.machine.param.(['PCA' m]) = logspace(log10(cfg.machine.param.(['rangePCA' m])(1)), ...
                    log10(cfg.machine.param.(['rangePCA' m])(2)), cfg.machine.param.(['nPCA' m]));
                def.machine.param.(['PCA' m]) = unique(round(def.machine.param.(['PCA' m])));
            end
            
        case 'rcca'
            % L2 regularization hyperparameter for smoothing between CCA (l2=0) and PLS (l2=1)
            % Note: 1 - logarithmic space for efficient L2 norm
            def.machine.param.(['L2' m]) = 1 - logspace(-log10(cfg.machine.param.(['rangeL2' m])(1)), ...
                    -log10(cfg.machine.param.(['rangeL2' m])(2)), cfg.machine.param.(['nL2' m]));
    end
end

% Criterion for hyperparameter selection
def.machine.param.crit = 'correl';

% Additional settings for machines
if ismember(cfg.machine.name, {'pls' 'spls'})
    % Tolerance and maximum number of iterations
    def.machine.spls.tol = 1e-5;
    def.machine.spls.maxiter = 100;
    
else
    % Tolerance
    def.machine.svd.tol = 1e-10;
    
     % Explained variance
    if strcmp(cfg.machine.name, 'cca')
        def.machine.svd.varx = 1; % Note that it can be effectively overwritten by hyperparameter
        def.machine.svd.vary = 1;
    elseif strcmp(cfg.machine.name, 'rcca')
        def.machine.svd.varx = 0.99;
        def.machine.svd.vary = 0.99; % No hyperparameter here, so it always has an effect
    end
end
   
% Update fields
cfg = assign_defaults(cfg, def);

% Sanity checks for hyperparameter settings
for i=1:numel(cfg.data.mod)
    m = lower(cfg.data.mod{i}); % shorthand for modality in lowercase
    
    % Check if L1 regularization obeys limits
    if strcmp(cfg.machine.name, 'spls') && (cfg.machine.param.(['rangeL1' m])(1) < 1 || ...
            cfg.machine.param.(['rangeL1' m])(2) > sqrt(cfg.data.(upper(m)).nfeat))
        error('L1 regularization is out of interval: [1, sqrt(size(%s, 2)].', upper(m));
    end
end

% Check and update machine parameter fields
fields = fieldnames(cfg.machine.param);
for i=1:numel(fields)
    if ~isempty(regexp(fields{i}, 'range')) || ~isempty(regexp(fields{i}, 'n.*(x|y)'))
        try
            def.machine.param = rmfield(def.machine.param, fields{i});
        catch; end
        cfg.machine.param = rmfield(cfg.machine.param, fields{i});
    end
end

% Check if grid search needed
param = get_hyperparam(cfg, 'default');

% Check and update framework settings
if numel(param) == 1
    if isfield(def.frwork.split, 'nin')
        def.frwork.split = rmfield(def.frwork.split, 'nin');
    end
    if isfield(cfg.frwork.split, 'nin')
        cfg.frwork.split = rmfield(cfg.frwork.split, 'nin');
    end
    if isfield(def.frwork.split, 'propin')
        def.frwork.split = rmfield(def.frwork.split, 'propin');
    end
    if isfield(cfg.frwork.split, 'propin')
        cfg.frwork.split = rmfield(cfg.frwork.split, 'propin');
    end
end

% Project subdirectories
switch cfg.frwork.name
    case 'holdout'
        if numel(param) > 1
            def.dir.frwork = sprintf('%s_holdout%d-%.2f_subsamp%d-%.2f', cfg.machine.name, ...
            cfg.frwork.split.nout, cfg.frwork.split.propout, cfg.frwork.split.nin, cfg.frwork.split.propin);
        else
            def.dir.frwork = sprintf('%s_holdout%d-%.2f', cfg.machine.name, cfg.frwork.split.nout, ...
                cfg.frwork.split.propout);
        end
        
    case 'permutation'
        def.dir.frwork = sprintf('%s_permutation', cfg.machine.name);
end
if all(isfield(cfg.machine.param, {'PCAx' 'PCAy'}))
    if numel(cfg.machine.param.PCAx) == 1 && numel(cfg.machine.param.PCAy) == 1
        if cfg.machine.param.PCAx == cfg.machine.param.PCAy
            def.dir.frwork = strrep(def.dir.frwork, 'cca', sprintf('cca_pca%d', cfg.machine.param.PCAx));
        else
            def.dir.frwork = strrep(def.dir.frwork, 'cca', sprintf('cca_pca%d-%d', ...
                cfg.machine.param.PCAx, cfg.machine.param.PCAy));
        end
    else
        def.dir.frwork = strrep(def.dir.frwork, 'cca', 'cca_pca');
    end
end
def.dir.frwork = [fullfile(cfg.dir.project, 'framework', def.dir.frwork) cfg.frwork.flag];
def.dir.load = fullfile(def.dir.frwork, 'load');

% Update fields
cfg = assign_defaults(cfg, def);

% Check if statistical inference is supported
if cfg.stat.nperm > 0
    if strcmp(cfg.machine.name, 'pls') && ~ismember(cfg.stat.crit, {'correl' 'covar'})
        error('Statistical inference should be based on correlation or covariance.')
    elseif ~strcmp(cfg.stat.crit, 'correl')
        error('Statistical inference should be based on correlation.')
    end
end

%----- Save cfg
if ~isdir(cfg.dir.frwork)
    mkdir(cfg.dir.frwork)
end
savemat(cfg, fullfile(cfg.dir.frwork, 'cfg.mat'), 'cfg', cfg);
