function S = loadmat_struct(res, fname, varargin)
% loadmat_struct
%
% # Syntax
%   S = loadmat_struct(res, fname, varargin)
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
if isempty(res.env.fileend)
    filename = getfname(pathstr, ['^' name ext]);
else
    filename = getfname(pathstr, ['^' name '_\d+' ext]);
end

timestamp = clock;

while ~isempty(filename)
    % Try loading data
    try
        S = load(fullfile(pathstr, filename{1}), varargin{:});
        break;
    catch
        % Keep looping if file is temporarily unavailable
        if etime(clock, timestamp) < 60
            pause(10*rand); % wait a bit
            continue;
        else
            delete(fullfile(pathstr, filename{1}));
            if res.env.verbose == 1
                fprintf('File corrupt: %s\n', fullfile(pathstr, filename{1}));
            end
            filename(1) = [];
        end
    end
end