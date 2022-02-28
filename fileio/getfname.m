function fname = getfname(folder, expression)
% getfname
% fname = getfname(folder, expression)
%   getfname  lists all the file/folder names to a cell array that match the 
% character pattern specified by the regular expression
%
%   Input:
%       folder     = folder name in which we want to list files/subfolders
%       expression = character pattern specified by regular expression
%   Output:
%       fname = cell array of file/folder names

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
