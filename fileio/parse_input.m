function S = parse_input(S, varargin)
% parse_input
%
% Assigns Name-Value pairs in varargin to a structure with fields of
% 'Name' and value of 'Value'
%
% Notes:
% 1. dot delimited Name string can be used for nested structure
% 2. this function is the inverse operation of parse_struct
%
% # Syntax
%   S = parse_input(S, varargin)
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

% Initialize structure
if isempty(S)
    S = struct();
elseif ~isstruct(S) && ~ishandle(S)
    error('parse_input accepts only structure input as first argument');
end

if mod(numel(varargin), 2)
    error('parse_input accepts only Name-Value pairs');
else
    for i=1:2:numel(varargin)
        tags = strsplit(varargin{i}, '.');
        subs = struct('type', '.', 'subs', tags);
        if istable(varargin{i+1}) % exception for tables
            S.(varargin{i}) = varargin{i+1};
        else
            S = subsasgn(S, subs, varargin{i+1});
        end
    end
end