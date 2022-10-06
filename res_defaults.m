function res = res_defaults(res, mode, varargin)
% res_defaults
%
% Set defaults in your results (`res`) structure including information about
% the results and settings for plotting. Use this function to update and 
% add all necessary defaults to your `res`. If you have defined anything in 
% `res` before calling the function, it won't overwrite those values. The 
% path to the framework folder should be always defined in your `res` or 
% passed as varargin, otherwise the function throws an error. All the other 
% fields are optional and can be filled up by `res_defaults`.
%
% This function can be also called to load an existing `res*.mat` file. 
%
% # Syntax
%   res = res_defaults(res, mode, varargin)
%
% # Inputs
% res:: struct
%   results structure (more information below)
% mode:: 'init', 'load', 'projection', 'simul', 'behav', 'conn', 'vbm', 'roi', 'brainnet'
%   mode of calling res_defaults, either referring to initialization ('init'),
%   loading ('load'), type of plot ('projection', 'simul', 'behav', 'conn', 
%   'vbm', 'roi') or settings for toolbox ('brainnet') 
% varargin:: name-value pairs
%   additional parameters can be set via name-value pairs with dot notation 
%   supported (e.g., 'behav.weight.numtop', 20)
%
% # Outputs
% res:: struct
%   result structure that has been updated with defaults
%
% # Examples
%   % Example 1
%   res.dir.frwork = 'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME';
%   res.frwork.level = 1;
%   res.env.fileend = '_1';
%   res = res_defaults(res, 'load');
%
%   % Example 2
%   res = res_defaults([], 'load', 'dir.frwork', ...
%                      'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME');
%   
%   % Example 3
%   res = res_defaults([], 'load', 'dir.frwork', ...
%                      'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME');
%   res = res_defaults(res, 'behav');
%
% ---
% See also: [res](../../res), [cfg_defaults](../cfg_defaults/)
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

% Initialize res
if isempty(res)
    res = struct();
end
res = assign_defaults(res, def);

% Level of results
def.frwork.level = 1;

% Filename suffix
def.env.fileend = '_1';

% Update res
res = assign_defaults(res, def);

% Check that path to framework folder exists
if ~isfield(res, 'dir') || ~isfield(res.dir, 'frwork')
    error('Path to framework folder should be given.')
end

%----- Initialize or load results

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

if strcmp(mode, 'init')
    % Set up folders
    def.dir.project = cfg.dir.project;
    res.dir.frwork = cfg.dir.frwork;
    subdir = {'perm' 'res'};
    if strcmp(cfg.frwork.name, 'holdout')
        subdir{end+1} = 'grid';
    end
    for i=1:numel(subdir)
        res.dir.(subdir{i}) = fullfile(cfg.dir.frwork, subdir{i}, sprintf('level%d', ...
            res.frwork.level));
    end
    
    % Set up stats
    res.stat = struct('nperm', cfg.stat.nperm);

    % Set up maximum number of effects
    res.frwork.nlevel = cfg.frwork.nlevel;

    % Initialize split details
    def.frwork.split = struct('all', (1:cfg.frwork.split.nout)', ...
        'nall', cfg.frwork.split.nout);

    % Initialize res
    res = assign_defaults(res, def);
    
    % Inherit compression setting for saving files
    res.env.save = cfg.env.save;
    
    return;
    
else
    % Keep copy of current res
    def = res;
    
    % Load res
    res = loadmat(res, fullfile(res.dir.frwork, 'res', ['level', ...
        num2str(res.frwork.level)], 'res.mat'), 'res');
    
    % Update res with saved copy
    res = assign_defaults(res, def);
end

%----- General settings for plots

% Project folder
def.dir.project = cfg.dir.project;
    
% Update defaults
res = assign_defaults(res, def);

if strcmp(mode, 'load')
    return
end

% File selection
def.gen.selectfile = 'interactive'; % selection for label, mask file etc: 'interactive' or 'none'

% Flip sign of weight
def.gen.weight.flip = 0; % boolean whether flip or not

% General figure settings
def.gen.figure.ext = '.png';
def.gen.figure.Position = [];
def.gen.axes.Position = [];
def.gen.axes.XLim = [];
def.gen.axes.YLim = [];
def.gen.axes.FontSize = [];
def.gen.axes.FontName = [];
def.gen.axes.XTick = [];
def.gen.axes.YTick = [];
def.gen.axes.XScale = [];
def.gen.axes.YScale = [];
def.gen.legend.FontSize = [];
def.gen.legend.Location = [];

% Data file names
def.data.X.fname = cfg.data.X.fname;
def.data.Y.fname = cfg.data.Y.fname;
if isfield(cfg.data, 'C')
    def.data.C.fname = cfg.data.C.fname;
end

% Update defaults
res = assign_defaults(res, def);

if strcmp(mode, 'paropt')
    %----- Grid-search plots of hyperparameters
    
    % View of 3D plot to help assessment 
    def.param.view = [-130 20];

elseif strcmp(mode, 'projection')
    %----- Projection/latent space plots
        
    % Colormap/group information files
    def.proj.file.label = fullfile(res.dir.project, 'data', 'LabelsY.csv');
    def.proj.file.data = fullfile(res.dir.project, 'data', 'Y.mat');
    
    % Flip sign of projections
    def.proj.flip = res.gen.weight.flip; % boolean whether flip or not
    
    % multiple levels (average over modalities)
    def.proj.multi_level = 0;
    
    % Figure settings
    def.proj.xlabel = 'Brain latent variable';
    def.proj.ylabel = 'Behavioural latent variable';
    def.proj.scatter.SizeData = [];
    def.proj.scatter.MarkerFaceColor = [];
    def.proj.scatter.MarkerEdgeColor = [];
    def.proj.lsline = 'off';

else  
    % Type of weight
    def.gen.weight.type = 'weight'; % 'weight' 'correlation' 
            
    switch mode
        case 'simul'
            %----- Stem plots for simulations
            
            % Weight postprocessing
            def.simul.weight.filtzero = 0; % filter out weights with zero weights
            def.simul.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.simul.weight.sorttype = ''; % sort weights: '', 'sign' or 'abs'
            def.simul.weight.norm = 'none';

            % Tue weight files
            def.simul.weight.file.X = fullfile(res.dir.project, 'data', 'wX.mat');
            def.simul.weight.file.Y = fullfile(res.dir.project, 'data', 'wY.mat');
            
            % Figure settings
            def.simul.xlabel = 'Variables';
            def.simul.ylabel = 'Weight';
            
        case 'behav'
            %----- Behavioural bar plots
            
            % Weight postprocessing
            def.behav.weight.filtzero = 1; % filter out weights with zero weights
            def.behav.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.behav.weight.sorttype = 'sign'; % sort weights: '', 'sign' or 'abs'
            def.behav.weight.norm = 'none';
            
            % Label settings
            def.behav.file.label = fullfile(res.dir.project, 'data', 'LabelsY.csv');
            def.behav.label.maxchar = Inf; % set maximum number of characters for label names
            
            % Figure settings
            def.behav.xlabel = 'Behavioural variables';
            def.behav.ylabel = 'Weight';

        case 'conn'
            %----- Connectivity plots
            
            % Mask file
            def.conn.file.mask = fullfile(res.dir.project, 'data', 'mask.mat');
            
            % Weight postprocessing
            def.conn.weight.filtzero = 1; % filter out weights with zero weights
            def.conn.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.conn.weight.sorttype = 'sign'; % sort weights: '', 'sign' or 'abs'
            def.conn.weight.type = 'auto'; % 'auto' 'strength'
            def.conn.weight.sign = 'all'; % select subset of weights: 'all' 'positive' or 'negative'
            
            % Module weight visualization
            def.conn.module.disp = 0;  % display module weights
            def.conn.module.type = 'average'; % average sum
            def.conn.module.norm = 'none'; % normalize module weights: 'global', 'max', 'none'
                        
            % Label file
            def.conn.file.label = fullfile(res.dir.project, 'data', 'LabelsX.csv');
            
        case 'vbm'
            %----- VBM (voxel-based morphometry) plots
            
            % Weight postprocessing
            def.vbm.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.vbm.weight.sorttype = '';
            def.vbm.weight.norm = 'none';

            % Mask file
            def.vbm.file.mask = fullfile(res.dir.project, 'data', 'mask.nii');
            
            % Normalization to MNI space
            def.vbm.file.MNI = 'T1_1mm_brain.nii'; % template/source image for normalization
            def.vbm.transM = eye(4); % transformation matrix
                        
            % Update res
            res = assign_defaults(res, def);
            
        case 'roi'
            %----- ROI (regions of interest) plots
            
            % Weight postprocessing
            def.roi.weight.filtzero = 1; % filter out weights with zero weights
            def.roi.weight.numtop = Inf; % number of top weights: Inf (all weights), 20 etc.
            def.roi.weight.sorttype = 'sign'; % sort weights: '', 'sign' or 'abs'
            
            % ROI index/structure to remove
            def.roi.out = [];
            
            % Label file
            def.roi.file.label = fullfile(res.dir.project, 'data', 'LabelsX.csv');
            
        case 'brainnet'
            %----- Brainnet files
            
            % Brainnet files
            def.brainnet.file.surf = 'BrainMesh_ICBM152.nv'; % brain mesh file (should be in the path!)
            def.brainnet.file.options = fullfile(res.dir.project, 'data', 'BrainNet', 'options.mat'); % options file
    end
end

% Update defaults
res = assign_defaults(res, def);
