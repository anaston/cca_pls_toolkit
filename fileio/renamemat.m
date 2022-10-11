function renamemat(cfg, fname)
% renamemat
%
% # Syntax
%   renamemat(cfg, fname)
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

% Parse fname
[pathstr, name, ext] = fileparts(fname);
filename = getfname_fe(cfg, pathstr, name, ext);
if ~isempty(filename)
    % Make sure we can load data
    loadmat(cfg, fullfile(pathstr, [name ext]));
    
    % Rename file
    filename = getfname_fe(cfg, pathstr, name, ext); % update in case some files have been deleted
    old_file = fullfile(pathstr, filename{1});
    new_file = fullfile(pathstr, [name '_1' ext]);
    if ~strcmp(old_file, new_file)
        movefile(old_file, new_file);
    end
    
    % Delete additional files if exist
    filename = getfname_fe(cfg, pathstr, name, ext); % update in case some files have been renamed
    for i=2:numel(filename)
        delete(fullfile(pathstr, filename{i}));
    end
end

% --------------------------- Private functions ---------------------------

function filename = getfname_fe(cfg, pathstr, name, ext)
% get filename irrespective of file end

if isempty(cfg.env.fileend)
    filename = getfname(pathstr, ['^' name ext]);
else
    filename = getfname(pathstr, ['^' name '_\d+' ext]);
end

if isempty(filename) && cfg.env.verbose == 1
    fprintf('File not found: %s\n', [name ext]);
end