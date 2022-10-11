function fix_fileend(cfg)
% fix_fileend
%
% # Syntax
%   fix_fileend(cfg)
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

%----- Clean up data folder
movefile(fullfile(cfg.dir.data, 'inmat.mat'), fullfile(cfg.dir.data, 'inmat_1.mat'));
movefile(fullfile(cfg.dir.data, 'outmat.mat'), fullfile(cfg.dir.data, 'outmat_1.mat'));

%----- Clean up grid folder
if strcmp(cfg.frwork.name, 'holdout')
    movefile(fullfile(cfg.dir.grid, 'allgrid.mat'), fullfile(cfg.dir.grid, 'allgrid_1.mat'));
elseif strcmp(cfg.frwork.name, 'holdout_perm')
    movefile(fullfile(cfg.dir.grid, 'allgrid.mat'), fullfile(cfg.dir.grid, 'allgrid_1.mat'));
    movefile(fullfile(cfg.dir.grid, 'distances.mat'), fullfile(cfg.dir.grid, 'distances_1.mat'));
    movefile(fullfile(cfg.dir.grid, 'pvals.mat'), fullfile(cfg.dir.grid, 'allgrid_1.mat'));
    movefile(fullfile(cfg.dir.grid, sprintf('permid_N%d.mat', cfg.frwork.split.nin)), ...
        fullfile(cfg.dir.grid, sprintf('permid_N%d_1.mat', cfg.frwork.split.nin)));
end

%----- Clean up perm folder
movefile(fullfile(cfg.dir.perm, 'allperm.mat'), fullfile(cfg.dir.perm, 'allperm_1.mat'));
movefile(fullfile(cfg.dir.perm, sprintf('permid_N%d.mat', cfg.nperm)), fullfile(cfg.dir.perm, sprintf('permid_N%d_1.mat', cfg.nperm)));

%----- Clean up res folder
movefile(fullfile(cfg.dir.res, 'model.mat'), fullfile(cfg.dir.res, 'model_1.mat'));
movefile(fullfile(cfg.dir.res, 'param.mat'), fullfile(cfg.dir.res, 'param_1.mat'));
try
    movefile(fullfile(cfg.dir.res, 'results.mat'), fullfile(cfg.dir.res, 'results_1.mat'));
catch
end
movefile(fullfile(cfg.dir.res, 'cfg.mat'), fullfile(cfg.dir.res, 'cfg_1.mat'));

%----- Empty fileend field
cfg.env.fileend = '_1';
save(fullfile(cfg.dir.res, 'cfg_1.mat'), 'cfg')