function fname = select_file(res, folder, str, ext, default)
% select_file
%
% Wrapper to select file interactively using SPM GUI or set default.
%
% # Syntax
%   fname = select_file(res, folder, str, ext, default)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

% Wrapper to select file interactively with SPM or use default
fname = [];
if strcmp(res.gen.selectfile, 'interactive')
    fname = spm_select(1, ext, str, {}, folder); % GUI to get file
end
if isempty(fname)
    fname = default;
end