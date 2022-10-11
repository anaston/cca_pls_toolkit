function c = cov2(A, B)
% cov2
%
% Custom function for computing covariance to replace MATLAB's built-in cov 
% function. It supports only same number of columns.
%
% Syntax:
%   c = cov2(A, B)
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

% Check input dimensions
if size(A, 1) ~= size(B, 1)
   error('Size of matrices should match for covariance calculation'); 
end

% Compute covariance
c = bsxfun(@minus, A, mean(A))' * bsxfun(@minus, B, mean(B)) / (size(A, 1) - 1);