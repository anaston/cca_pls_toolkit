function S = parse_input(S, varargin)
% parse_input 
% assigns Name-Value pairs in varargin to a structure with
% fields of 'Name' and value of 'Value'
%
% Notes:
% 1. dot delimited Name string can be used for nested structure
% 2. this function is the inverse operation of name_value = parse_struct(S)

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