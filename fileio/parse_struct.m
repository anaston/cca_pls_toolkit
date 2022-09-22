function name_value = parse_struct(S, dim, fields)
% parse_input
%
% Decomposes structure with fields and values into a cell array with 
% 'Name' and 'Value' pairs
%
% Note:
% This function is the inverse operation of parse_input
%
% # Syntax
%   S = parse_input(S, varargin)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$
    
if ~exist('fields', 'var')
    fields = fieldnames(S);
end

% Check input dimensionality
if ~exist('dim', 'var')
    dim = 1;
end
if numel(S) > 1 && size(S(1).(fields{1}), dim) ~= 1
    error('The current implementation assumes a structure array with 1D data.')
end

name_value = cell(2, numel(fields));
for i=1:numel(fields)
    if ~isempty(cat(dim, S(:).(fields{i})))
        name_value{1,i} = fields{i};
        name_value{2,i} = cat(dim, S(:).(fields{i}));
    end
end
name_value(:,all(cellfun(@isempty, name_value), 1)) = [];
name_value = reshape(name_value, 1, []);
