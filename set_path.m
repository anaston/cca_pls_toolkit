function dir_toolkit = set_path(varargin)
% set_path
%
% Adds essential folders to the path to initialize the toolkit for an
% analysis. For visualization, it needs to be called with specific folders
% to add plotting and other toolbox folders to the path.
%
% # Syntax
%   dir_toolkit = set_path(varargin)
%
% # Inputs
% varargin:: char
%   folders passed as arguments will be added to the path
%
%   `set_path` looks for folders under the toolkit folder and under the 
%   `external` folder. In the latter case it is sufficient to use the
%   first few characters of the toolbox, e.g., `spm` instead of `spm12`.
%
% # Outputs
% dir_toolkit:: char
%   full path to the toolkit folder
%
% # Examples
%    % Example 1
%    set_path;
%    
%    % Example 2
%    set_path('plot');
%
%    % Example 3
%    set_path('plot', 'spm', 'brainnet');
%
% ---
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

dir_toolkit = fileparts(mfilename('fullpath'));
addpath(dir_toolkit);

% Add primary paths - essential for the basic functionality of the toolkit
addpath(fullfile(dir_toolkit, 'fileio'));
addpath(fullfile(dir_toolkit, 'misc'));
addpath(fullfile(dir_toolkit, 'machines'));
addpath(fullfile(dir_toolkit, 'util'));
addpath(fullfile(dir_toolkit, 'demo'));

% Add secondary paths - needed for particular behaviours (e.g. plotting certain figures)
external = getfname(fullfile(dir_toolkit, 'external'), '.*'); % all available external folders
for i=1:numel(varargin)
    idfolder = find(cellfun(@(x) ~isempty(regexpi(x,  varargin{i})), external), 1, 'last'); % take the last if multiple result!
    if ~isempty(idfolder)
        addpath(genpath(fullfile(dir_toolkit, 'external', external{idfolder})), '-end');
    else
        if ~ismember(varargin{i}, getfname(dir_toolkit, '.*'))
            warning('%s not found in the external folder.', varargin{i})
        else
           addpath(fullfile(dir_toolkit, varargin{i}), '-end') 
        end
    end
end

% Check SPM and BrainNet interference
allpath = strsplit(path, ':');
idbrainnet = find(cellfun(@(x) ~isempty(regexpi(x, 'BrainNet')), allpath));
idpalm = find(cellfun(@(x) ~isempty(regexpi(x, 'PALM')), allpath));
if exist('spm', 'file')
    idspm = find(cellfun(@(x) ~isempty(regexpi(x, spm('Ver'))), allpath));
    if ~isempty(idbrainnet)
        if max(idspm) > min(idbrainnet) % SPM should be higher in MATLAB search path than BrainNet
            rmpath(strjoin(allpath(idbrainnet), ':'));
            addpath(strjoin(allpath(idbrainnet), ':'), '-end');
            
        end
    end
    if ~isempty(idpalm)
        if max(idspm) > min(idpalm) % SPM should be higher in MATLAB search path than BrainNet
            rmpath(strjoin(allpath(idpalm), ':'));
            addpath(strjoin(allpath(idpalm), ':'), '-end');
        end
    end
end
