function [wX, wY] = rcca(data, featid, param)
% rcca
%
% Implementation for PCA-CCA, CCA and Regularized CCA and PLS
%
% # Syntax
%   [wX, wY] = rcca(data, featid, param)
%
% ---
% See also: [spls](../spls/), [fastsvd](../fastsvd/)
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

% Calculate covariance/cross-covariance matrices
BYY = (1-param.L2y) * data.LY(featid.y) + repmat(param.L2y, sum(featid.y), 1);
BXX = (1-param.L2x) * data.LX(featid.x) + repmat(param.L2x, sum(featid.x), 1);
RXY = data.RX(:,featid.x)' * data.RY(:,featid.y);

% Solve standard eigenvalue problem
[wY, lambda] = eigs(diag(1./sqrt(BYY)) * RXY' * diag(1./BXX) * RXY * diag(1./sqrt(BYY)), 1);
lambda = real(sqrt(lambda));

% Compute weights
wY = diag(1./sqrt(BYY)) * wY;
wX = diag(1./BXX) * RXY * wY / lambda;