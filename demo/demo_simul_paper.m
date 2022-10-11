function demo_simul_paper
% demo_simul_paper
%
% # Syntax
%   demo_simul_paper
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



%----- Analysis

% Set path for analysis
set_path;

% Project folder
cfg.dir.project = fileparts(mfilename('fullpath'));

% Machine settings
cfg.machine.name = 'spls';
cfg.machine.metric = {'trcorrel' 'correl' 'simwx' 'simwy' ...
    'trexvarx' 'trexvary'};
cfg.machine.param.crit = 'correl';
cfg.machine.simw = 'correlation-Pearson';

% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 10;
cfg.frwork.split.nin = 10;

% Deflation settings
cfg.defl.name = 'pls-modeA';

% Environment settings
cfg.env.comp = 'local';

% % Number of permutations
cfg.stat.nperm = 1000;
   
% Update cfg with defaults
cfg = cfg_defaults(cfg);

% Run analysis
main(cfg);

% Clean up analysis files to save disc space
cleanup_files(cfg);

%----- Visualization

% Set path for plotting
set_path('plot');

% Load res
res.dir.frwork = cfg.dir.frwork;
res.frwork.level = 1;
res = res_defaults(res, 'load'); 

% Plot data projections
plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', ...
    res.frwork.split.best, 'training+test', '2d_group', ...
    'gen.figure.ext', '.svg', ...
    'gen.figure.Position', [0 0 500 400], ...
    'gen.axes.Position', [0.1798 0.1560 0.7252 0.7690], ...
    'gen.axes.XLim', [-5 4.9], 'gen.axes.YLim', [-4.2 5], ...
    'gen.axes.FontSize', 22, 'gen.legend.FontSize', 22, ...
    'gen.legend.Location', 'best', ...
    'proj.scatter.SizeData', 120, ...
    'proj.scatter.MarkerFaceColor', [0.3 0.3 0.9;0.9 0.3 0.3], ...
    'proj.scatter.MarkerEdgeColor', 'k', 'proj.lsline', 'on', ...
    'proj.xlabel', 'Modality 1 latent variable', ...
    'proj.ylabel', 'Modality 2 latent variable');

% Plot X weights as stem plot
plot_weight(res, 'X', 'simul', res.frwork.split.best, 'stem', ...
    'gen.figure.ext', '.svg', ...
    'gen.figure.Position', [0 0 500 400], ...
    'gen.axes.Position', [0.1798 0.1560 0.7252 0.7690], ...
    'gen.axes.YLim', [-1.1 1.2], ...
    'gen.axes.YTick', [-1:0.5:1.2], ...
    'gen.axes.FontSize', 22, 'gen.legend.FontSize', 22, ...
    'gen.legend.Location', 'NorthEast', ...
    'simul.xlabel', 'Modality 1 variables', ...
    'simul.ylabel', 'Weight', 'simul.weight.norm', 'minmax');

% Plot Y weights as stem plot
plot_weight(res, 'Y', 'simul', res.frwork.split.best, 'stem', ...
    'gen.figure.ext', '.svg', ...
    'gen.figure.Position', [0 0 500 400], ...
    'gen.axes.Position', [0.1798 0.1560 0.7252 0.7690], ...
    'gen.axes.YLim', [-1.1 1.2], ...
    'gen.axes.YTick', [-1:0.5:1.2], ...
    'gen.axes.FontSize', 22, 'gen.legend.FontSize', 22, ...
    'gen.legend.Location', 'NorthEast', ...
    'simul.xlabel', 'Modality 2 variables', ...
    'simul.ylabel', 'Weight', 'simul.weight.norm', 'minmax');