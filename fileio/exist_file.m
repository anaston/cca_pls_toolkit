function [isfile, filename] = exist_file(cfg, fname, var)
% exist_file
%   Some description here

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