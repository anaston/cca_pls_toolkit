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

% Wrapper to select file interactively with SPM or use default
fname = [];
if strcmp(res.gen.selectfile, 'interactive')
    fname = spm_select(1, ext, str, {}, folder); % GUI to get file
end
if isempty(fname)
    fname = default;
end