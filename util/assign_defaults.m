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