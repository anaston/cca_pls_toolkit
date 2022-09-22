function [mat, varargout] = mean_center_features(mat, mu)
% mean_center_features
%
% Mean centers features.
% 
% # Syntax
%   [mat, varargout] = mean_center_features(mat, mu)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

if ~exist('mu', 'var')
    mu = nanmean(mat, 1);
    varargout{1} = mu;
end

mat = bsxfun(@minus, mat, mu);

