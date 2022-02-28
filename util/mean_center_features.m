function [mat, varargout] = mean_center_features(mat, mu)
% FORMAT mat = mean_center_features(mat)
%
% Function to mean center the features
%   Inputs:
%           mat - data matrix: Number of subjects x Features
%
%   Outputs:
%           varargout
%
%   Version: 2018-09-03
%__________________________________________________________________________

% Written by Agoston Mihalik
% Email: a.mihalik@ucl.ac.uk
%
% 2019-03-18 Agoston Mihalik return mean used for mean centering

if ~exist('mu', 'var')
    mu = nanmean(mat, 1);
    varargout{1} = mu;
end

mat = bsxfun(@minus, mat, mu);

