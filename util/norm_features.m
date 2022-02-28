function [mat, varargout] = norm_features(mat, scaling, norm_fun)
% FORMAT mat = norm_features(mat, norm_fun)
%
% Function to normalise the features
%   Inputs:
%           mat       - data matrix: Number of subjects x Features
%           norm_fun  - (string) function to be used for normalisation
%                       default = 'norm' (L2-norm)
%                       Other options: 'norm1' (L1-norm), any other
%                       function that performs column-wise operations (e.g.
%                       'std', 'sum', etc.)
%
%   Outputs:
%           varargout
%
%   Version: 2016-01-18
%__________________________________________________________________________

% Written by Joao Matos Monteiro
% Email: joao.monteiro@ucl.ac.uk
%
% Adapted by Agoston Mihalik (a.mihalik@ucl.ac.uk):
% 2019-03-18
%   computation with function handle
%   use precomputed scaling factor or return the currently used one
%   bug fix for NaN values
% 2019-06-13
%   loop added for memory efficiency
% 2019-07-29
%   Normalization is not affected by NaN in the data
%

% Calculate scaling
if ~exist('scaling', 'var') || isempty(scaling)
    scaling = zeros(1, size(mat, 2)); % preallocation
    
    for i=1:size(mat, 2) % we loop through for memory efficiency and due to NaNs
        id = ~isnan(mat(:,i));
        if nargin < 2 || strcmp(norm_fun, 'norm')
            % The norm function behaves in a different way
            scaling(i) = sqrt(sum(mat(id,i).^2));
        elseif strcmp(norm_fun, 'norm1')
            scaling(i) = sum(abs(mat(id,i)));
        else
            % General case for functions that perform operations column-wise (e.g.
            % 'std' or 'sum')
            fun_handle = str2func(norm_fun);
            scaling(i) = fun_handle(mat(id,i));
        end
    end
    
    % Replace badly scaled features with 0
    scaling(scaling < 1e-5) = 0;
    
    varargout{1} = scaling;
end

% Perform scaling
mat = bsxfun(@rdivide, mat, scaling);

% When using 'std' (e.g), a matrix can have a column with std = 0,
% which results in NaN. Change all NaN to zero
if any(scaling == 0)
    mat(:,scaling == 0) = 0;
end