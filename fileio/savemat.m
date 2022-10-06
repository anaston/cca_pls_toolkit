function savemat(res, fname, varargin)
% savemat
%
% Saves .mat data with flexible filename suffix.
%
% # Syntax
%   savemat(res, fname, varargin)
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

% Parse input
S = parse_input([], varargin{:});

% Parse fname
[pathstr, name, ext] = fileparts(fname);

if ~exist_file(res, fname)
    if res.env.save.compression
        % Save file with compression for memory-efficient storage
        save(fullfile(pathstr, [name res.env.fileend ext]), '-struct', 'S', '-v7.3');
    else
        % Save file without compression to speed up saving/loading >2G files
        save(fullfile(pathstr, [name res.env.fileend ext]), '-struct', 'S', '-v7.3', '-nocompression');
    end
%     end
elseif isfield(S, 'cfg')
    cfg = loadmat(res, fullfile(pathstr, 'cfg.mat'), 'cfg');
    if ~isequal(S.cfg, cfg)
       warning('cfg structures are not the same, be very cautious!');
       check_fields('cfg', {S.cfg cfg});
    end
end


% --------------------------- Private functions ---------------------------

function check_fields(varname, var, varargin)
%   check_fields goes through all fields and subfields of var{1} and var{2} iteratively
% and checks the discrepancy

dfields = fieldnames(var{1});

for i=1:numel(dfields)
    % Loop through subfields iteratively
    if isfield(var{2}, dfields{i})
        if isstruct(var{1}.(dfields{i}))
            check_fields(varname, {var{1}.(dfields{i}) var{2}.(dfields{i})}, dfields{i}, varargin{:});
            
        % Check if fields are the same
        elseif ~isequal(var{1}.(dfields{i}), var{2}.(dfields{i}))
            fprintf('%s.%s with different value\n', varname, strjoin([fliplr(varargin) dfields(i)], '.'))
        end
    else
        % Missing field
        fprintf('%s.%s missing\n', varname, strjoin([fliplr(varargin) dfields(i)], '.'))
    end
end