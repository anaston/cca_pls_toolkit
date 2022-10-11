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