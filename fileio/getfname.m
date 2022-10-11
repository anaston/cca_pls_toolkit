function fname = getfname(folder, expression)
% getfname
%
% It lists all the file/folder names to a cell array that match the 
% character pattern specified by the regular expression.
%
% # Syntax
%   fname = getfname(folder, expression)
%
% # Inputs
% folder:: char
%   folder name in which we want to list files/subfolders
% expression:: char
%   character pattern specified by regular expression
%
% # Outputs
% fname:: cell array
%   cell array of file/folder names
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

% List all files in the folder
files = dir(folder);
nfiles = numel(files);

% Find files that match regular expression
startid = cell(nfiles, 1);
for i=1:nfiles
    startid{i} = regexp(files(i).name, expression);
end
fname = {files.name}';
fname = fname(~cellfun(@isempty, startid));
