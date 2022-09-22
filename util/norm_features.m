function [mat, varargout] = norm_features(mat, scaling, norm_fun)
% norm_features
%
% Normalizes features.
%
% # Syntax
%   [mat, varargout] = norm_features(mat, scaling, norm_fun)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Joao Monteiro, Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

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