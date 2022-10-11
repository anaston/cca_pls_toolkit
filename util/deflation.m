function data = deflation(defl, data, m, w, varargin)
% deflation
%
% Various deflations for standard and regularized CCA/PLS.
%
% # Syntax
%   data = deflation(defl, data, m, w, varargin)
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

switch defl
    case 'generalized'
        % Generalized deflation for CCA/RCCA
        % ---------------------------------
        % 1. symmetric deflation, i.e. X, Y interchangeable
        % 2. both X and Y are deflated
        % 3. subcase of the generalized deflation with the following
        %    choice of Bxx, Byy in the input space:
        %     - Bxx = (1-tx) * X' * X / (n-1) + tx * I
        %     - Byy = (1-ty) * Y' * Y / (n-1) + ty * I
        %       where X, Y refer to the original X, Y data and the
        %       hyperparameters (tx, ty) define regularized CCA which
        %       smooths between CCA (tx=ty=0) and PLS (tx=ty=1)
        % 4. for RAM/time-efficiency, the input space is mapped into a
        %    new feature space defined by the principal components of X
        %    and Y. Consequently, Bxx and Byy are:
        %     - Bxx = (1-tx) * SX' * SX / (n-1) + tx * I
        %     - Byy = (1-ty) * SY' * SY / (n-1) + ty * I
        %       where X = UX * SX * VX' and Y = UY * SY * VY' and the
        %       hyperparameters are as above

        % Variance based on training data
        B = varargin{1};        
        
        % Feature id
        featid = varargin{2};

        % Deflation step
        data.(m)(:,featid) = data.(m)(:,featid) - (data.(m)(:,featid) * w) * (w' * diag(B));

    case 'pls-projection'
        % Projection deflation for PLS/SPLS
        % ---------------------------------
        % 1. symmetric deflation, i.e. X, Y interchangeable
        % 2. both X and Y data are deflated
        % 3. subcase of the generalized deflation with the following
        %    choice of Bxx, Byy:
        %      - Bxx = I and Byy = I
        % 4. orthogonalizes u[i], v[i] to u[j], v[j] where i != j
        % 5. equivalent to Hotelling 's deflation if non-sparse (i.e. u, v
        %    are true singular vectors)

        % Deflation step
        data.(m) = data.(m) - (data.(m) * w) * w';

    case 'pls-modeA'
        % Mode-A deflation for PLS/SPLS correlation (PLSC)
        % ------------------------------------------------
        % 1. symmetric deflation, i.e. X, Y interchangeable
        % 2. both X and Y are deflated
        % 3. orthogonalizes Xu[i], Yv[i] to Xu[j], Yv[j] where i != j and
        %    it holds even when u, v are sparse
        % 4. orthogonalizes u[i], v[i] to u[j], v[j] where i != j if
        %    u, v non-sparse
        % 5. used both in SPLS (Le Cao et al 2008, 2009) and PLS (Wegelin 2000)
        % 6. equivalent to PLS regression deflation in case of X
        % 7. equivalent to PLS projection deflation if X'*X = I and Y'*Y = I
        
        % Loading based on training data
        p = varargin{1};
        
        % Deflation step
        data.(m) = data.(m) - (data.(m) * w) * p';

    case 'pls-regression'
        % Regression deflation for PLS/SPLS regression (PLSR)
        % ---------------------------------------------------
        % 1. asymmetric deflation, predicts Y from X
        % 2. only X is deflated, deflation of Y is not necessary or
        %    needs to be done using loading of X (Shawe-Taylor, Cristiani 2004)
        % 3. equivalent to PLS mode-A deflation of X, for properties see
        %    there

        % Loading based on input training data
        p = varargin{1};
        
        % Deflation step
        data.(m) = data.(m) - (data.X * w) * p';
end