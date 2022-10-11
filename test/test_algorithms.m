function test_algorithms
% test_algorithms
%
% # Syntax
%   test_algorithms
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

%----- Test CCA algorithm

fprintf('\nTesting CCA analysis on full-rank data...\n');

% Get full-rank data
[trdata.X, trdata.Y] = get_data(1);

% CCA with MATLAB's built-in canoncorr.m function
[wx1, wy1] = canoncorr(trdata.X, trdata.Y);

% Prepare data for toolkit's rcca.m function
[trdata.VX, trdata.RX, trdata.LX] = fastsvd(trdata.X, 0, 0, 1, 'V', 'R', 'L');
[trdata.VY, trdata.RY, trdata.LY] = fastsvd(trdata.Y, 0, 0, 1, 'V', 'R', 'L');

% CCA with toolkit' rcca.m function - first associative effect
featid = struct('x', true(size(trdata.LX)), 'y', true(size(trdata.LY)));
param = struct('L2x', 0, 'L2y', 0);
[wx2, wy2] = rcca(trdata, featid, param);

% CCA with toolkit' rcca.m function - deflation and second associative effect
trdata = deflation('generalized', trdata, 'RX', wx2, trdata.LX, featid.x);
trdata = deflation('generalized', trdata, 'RY', wy2, trdata.LY, featid.y);
[wx2(:,2), wy2(:,2)] = rcca(trdata, featid, param);

% Get weights in input space
wx2 = trdata.VX * wx2;
wy2 = trdata.VY * wy2;

% Compare weights
tol = 1e-10;
check = false(1, 2);
for i=1:2
    if wx1(:,i)' * wx2(:,i) < 0 % sign flipping needed
        wx2(:,i) = -wx2(:,i);
        wy2(:,i) = -wy2(:,i);
    end
    if norm(wx1(:,i)/norm(wx1(:,i)) - wx2(:,i)/norm(wx2(:,i))) < tol && ...
            norm(wy1(:,i)/norm(wy1(:,i)) - wy2(:,i)/norm(wy2(:,i))) < tol
        check(i) = true;
    end
end
if all(check)
    fprintf('CCA analysis ok using rcca.m\n');
else
    fprintf('Bug in rcca.m or deflation.m!\n');
end

clear all;

%----- Test PLS algorithm

fprintf('\nTesting PLS analysis on rank-deficient data...\n');

% Get rank-deficient data
[trdata.X, trdata.Y] = get_data(0);

% PLS with MATLAB's built-in plsregress.m function - first associative effect
[~, ~, px1, py1] = plsregress(trdata.X, trdata.Y, 1);

% Prepare data for toolkit's rcca.m function
[trdata.VX, trdata.RX, trdata.LX] = fastsvd(trdata.X, 0, 0, 1, 'V', 'R', 'L');
[trdata.VY, trdata.RY, trdata.LY] = fastsvd(trdata.Y, 0, 0, 1, 'V', 'R', 'L');

% PLS with toolkit's rcca.m function - first associative effect
featid = struct('x', true(size(trdata.LX)), 'y', true(size(trdata.LY)));
param = struct('L2x', 1, 'L2y', 1);
[wx2, wy2] = rcca(trdata, featid, param);
px2 = trdata.RX * wx2;
py2 = trdata.RY * wy2;

% Compare scores
tol = 1e-10;
if px1' * px2 < 0  % sign flipping needed
    px2 = -px2;
    py2 = -py2;
end
if norm(px1/norm(px1) - px2/norm(px2)) < tol && ...
        norm(py1/norm(py1) - py2/norm(py2)) < tol
    fprintf('PLS analysis ok using rcca.m\n');
else
    fprintf('Bug in rcca.m algorithm!\n');
end

% PLS with pls2.m function (see below)
px3 = pls2(trdata.X, trdata.Y, 2, 1e-5);

% PLS with toolkit's spls.m function - first associative effect
cfg = struct('machine', struct('spls', struct('tol', 1e-5, 'maxiter', 100)));
param = struct('L1x', 0, 'L1y', 0);
[wx4, ~] = spls(cfg, trdata, param);
px4 = trdata.X * wx4;

% PLS with toolkit's spls.m function - deflation and second associative effect
p = trdata.X' * (trdata.X * wx4) / ((trdata.X * wx4)' * (trdata.X * wx4)); % loading
trdata = deflation('pls-regression', trdata, 'X', wx4, p);
[wx4(:,2), ~] = spls(cfg, trdata, param);
px4(:,2) = trdata.X * wx4(:,2);

% Compare scores
tol = 1e-3;
check = false(1, 2);
for i=1:2
    if px3(:,i)' * px4(:,i) < 0 % sign flipping needed
        px4(:,i) = -px4(:,i);
    end
    if norm(px3(:,i)/norm(px3(:,i)) - px4(:,i)/norm(px4(:,i))) < tol
        check(i) = true;
    end
end
if all(check)
    fprintf('PLS analysis ok using spls.m\n');
else
    fprintf('Bug in spls.m or deflation.m!\n');
end


% -------------------------- Auxiliary function --------------------------

function t = pls2(X, Y, ncomp, tol)
% This iterative pls regression method is based on the sample code in 
% Shawe-Taylor & Cristiniani (2004): Kernel Methods for Pattern Analysis.
% Cambridge University Press

for i=1:ncomp
    YX = Y'*X;
    u(:,i) = YX(1,:)'/norm(YX(1,:));
    if size(Y,2) > 1
        uold = u(:,i) + 1;
        while norm(u(:,i) - uold) > tol
            uold = u(:,i);
            tu = YX'*YX*u(:,i);
            u(:,i) = tu/norm(tu);
        end
    end
    t(:,i) = X*u(:,i);
    p(:,i) = X'*t(:,i)/(t(:,i)'*t(:,i));
    X = X - t(:,i)*p(:,i)';
end