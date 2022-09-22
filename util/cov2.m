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

% Check input dimensions
if size(A, 1) ~= size(B, 1)
   error('Size of matrices should match for covariance calculation'); 
end

% Compute covariance
c = bsxfun(@minus, A, mean(A))' * bsxfun(@minus, B, mean(B)) / (size(A, 1) - 1);