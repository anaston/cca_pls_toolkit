function update_dir(dir_frwork, fileend)
% update_dir
%
% Updates the paths in `cfg` and all `res` files for the current computer.
% It is needed to run when switching between computers e.g., moving data
% from a cluster to a local computer.
%
% # Syntax
%   update_dir(dir_frwork, fileend)
%
% # Inputs
% dir_frwork:: char
%   full path to the specific framework folder 
% fileend:: char
%   suffix at the end of the `res*.mat` file from `cfg.env.fileend`
%
% # Example
%    % Example 1
%    update_dir(<specific framework folder>, '_1');
%
% --- 
% See also: [cfg](../../cfg)
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

if ismember(dir_frwork(end), {'/' '\'})
    dir_frwork(end) = [];
end
    
% Results folder
res_dir = fullfile(dir_frwork, 'res');

% Update path in cfg file
cfg.env.fileend = fileend;
if exist_file(cfg, fullfile(dir_frwork, 'cfg.mat'))
    [~, files] = exist_file(cfg, fullfile(dir_frwork, 'cfg.mat'));
end
if ~exist('files', 'var')
    error('No cfg files found, check the project folder and the framework')
end
update_path(files, dir_frwork, 'cfg')

% Update path in res files
files = {};
lv = 1;
while exist_file(cfg, fullfile(res_dir, sprintf('level%d', lv), 'res.mat'))
    [~, fname] = exist_file(cfg, fullfile(res_dir, sprintf('level%d', lv), 'res.mat'));
    files(end+1) = fname(1);
    lv = lv + 1;
end
update_path(files, dir_frwork, 'res')


% --------------------------- Private functions ---------------------------

function update_path(fnames, dir_frwork, varname)

for i=1:numel(fnames)
    S = load(fnames{i});
    S.(varname) = change_path(S.(varname), dir_frwork);
    save(fnames{i}, '-struct', 'S');
end


function cfg = change_path(cfg, dir_frwork)

[filepath, ~, ext] = fileparts(dir_frwork);

% Update cfg.frwork.flag
if isfield(cfg, 'frwork') && isfield(cfg.frwork, 'flag') && contains(ext, '_')
    cfg.frwork.flag = ext(strfind(ext, '_'):end);
end

% Update cfg.dir.project
dir_project_old = cfg.dir.project;
if ismember(dir_project_old(end), {'/' '\'})
    dir_project_old(end) = []; % strip path if needed
end

if isfield(cfg.dir, 'project')
    [cfg.dir.project, name, ext] = fileparts(filepath);
end

% Replace all other fields of cfg.dir
fn = fieldnames(cfg.dir);
id = ismember(fn, 'frwork');
fn = fn([find(~id); find(id)]);
if isfield(cfg.dir, 'frwork')
    for f=1:numel(fn)
        if ismember(cfg.dir.(fn{f})(end), {'/' '\'})
            cfg.dir.(fn{f})(end) = []; % strip path if needed
        end
        cfg.dir.(fn{f}) = strrep(cfg.dir.(fn{f}), cfg.dir.frwork, dir_frwork);
        cfg.dir.(fn{f}) = strjoin(strsplit(cfg.dir.(fn{f}), {'\' '/'}, ...
            'CollapseDelimiters', true), filesep); % update file separator
    end
else
    error('frwork field should be included in cfg')
end

% Update cfg.data files
try
    cfg.data.X.fname = strrep(cfg.data.X.fname, dir_project_old, cfg.dir.project);
    cfg.data.Y.fname = strrep(cfg.data.Y.fname, dir_project_old, cfg.dir.project);
    if isfield(cfg.data, 'C')
        cfg.data.C.fname = strrep(cfg.data.C.fname, dir_project_old, cfg.dir.project);
    end
catch % a default option for backward compatibility
    if isfield(cfg, 'data')
        cfg.data.X.fname = fullfile(cfg.dir.project, 'data', 'X.mat');
        cfg.data.Y.fname = fullfile(cfg.dir.project, 'data', 'Y.mat');
        if isfield(cfg.data, 'C')
            cfg.data.C.fname = fullfile(cfg.dir.project, 'data', 'C.mat');
        end
    end
end