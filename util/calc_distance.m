function d = calc_distance(varargin)
% calc_distance
%
% Syntax:
%   d = calc_distance(varargin)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

d = NaN(size(varargin{1}));
for i=1:numel(varargin{1})
    d(i) = pdist([cellfun(@(x) x(i), varargin); ones(1, numel(varargin))]);
end

