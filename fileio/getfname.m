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
