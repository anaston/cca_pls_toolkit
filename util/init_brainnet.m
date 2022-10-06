function fname = init_brainnet(res, varargin)
% init_brainnet
%
% # Syntax
%   fname = init_brainnet(res, varargin)
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

% Parse inputs
S = parse_input([], varargin{:});

% Set path for Brainnet
set_path('brainnet');

% Set defaults for Brainnet
res = res_defaults(res, 'brainnet'); 

% Make custom Brainnet folder
dir_brainnet = fullfile(res.dir.project, 'data', 'BrainNet');
if ~isdir(dir_brainnet)
    mkdir(dir_brainnet); 
end

% Brainnet mesh/surface file
fname.surf = select_file(res, pwd, 'Select brain mesh file...', '\.nv$', which(res.brainnet.file.surf));

% Brainnet options file
fname.options = select_file(res, dir_brainnet, 'Select options file...', 'mat', res.brainnet.file.options);

% Brainnet edge file
if isfield(S, 'wfname') && isfield(S, 'weight')
    [pathstr, fname.edge, ext] = fileparts(S.wfname);
    fname.edge = fullfile(dir_brainnet, [fname.edge, '.edge']);
    dlmwrite(fname.edge, S.weight, 'Delimiter', '\t'); % edge file weight*2*pi
end

% Brainnet node file
if isfield(S, 'labelfname') && isfield(S, 'T')
    [pathstr, fname.node, ext] = fileparts(S.labelfname);
    fname.node = fullfile(dir_brainnet, [fname.node, '.node']);
    % Check fields (color, size, MNI space) >> to be implemented
    writetable(S.T(:,{'X' 'Y' 'Z' 'Color' 'Size'}), 'tmp.txt', 'delimiter', '\t', 'WriteVariableNames', 0);
    movefile('tmp.txt', fname.node); % node file
end