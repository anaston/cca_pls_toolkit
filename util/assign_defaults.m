function S = assign_defaults(S, default)
% assign_defaults
%
% It goes through all fields and subfields of S iteratively and sets them 
% if not existing.
%
% Syntax:
%   S = assign_defaults(S, default)
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

dfields = fieldnames(default);

for i=1:numel(dfields)
    % Assign field from default if it does not exist in cfg
    if ~isfield(S, dfields{i})
        S.(dfields{i}) = default.(dfields{i});
        
    % Loop through subfields iteratively
    elseif isstruct(default.(dfields{i}))
        S.(dfields{i}) = assign_defaults(S.(dfields{i}), default.(dfields{i}));
    end
end