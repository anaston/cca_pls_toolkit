function [isfile, filename] = exist_file(cfg, fname, var)
% exist_file
%
% # Syntax
%   [isfile, filename] = exist_file(cfg, fname, var)
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

% List file
[pathstr, name, ext] = fileparts(fname);
if isempty(cfg.env.fileend)
    filename = getfname(pathstr, ['^' name ext]);
else
    filename = getfname(pathstr, ['^' name '_\d+' ext]);
end

% Check if file exists   
isfile = ~isempty(filename);
if isfile
    filename = fullfile(pathstr, filename);
else
    filename = '';
end

% Additional check if variable exists in file without loading/putting it into memory
if isfile && exist('var', 'var')
    obj = matfile(filename{1});
    if ismember(var, who(obj))
        isfile = 1;
    else
        isfile = 0;
    end
end