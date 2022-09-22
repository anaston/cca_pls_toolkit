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