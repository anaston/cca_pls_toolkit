function [Xtr, Ytr, Xte, Yte] = get_data(fullrank)
% get_data
%
% # Syntax
%   [Xtr, Ytr, Xte, Yte] = get_data(fullrank)
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

% Load data
load(fullfile('test', 'data', 'X.mat'));
load(fullfile('test', 'data', 'Y.mat'));

% Split data to training and test
Xtr = X(1:40,:);
Xte = X(41:50,:);
Ytr = Y(1:40,:);
Yte = Y(41:50,:);

% Mean center data
[Xtr, mnx] = mean_center_features(Xtr);
Xte = mean_center_features(Xte, mnx);
[Ytr, mny] = mean_center_features(Ytr);
Yte = mean_center_features(Yte, mny);

% Normalize data
[Xtr, scx] = norm_features(Xtr, [], 'std');
Xte = norm_features(Xte, scx, 'std');
[Ytr, scx] = norm_features(Ytr, [], 'std');
Yte = norm_features(Yte, scx, 'std');

% Reduce to full rank if requested
if fullrank
    Xtr = Xtr(:,1:10);
    Xte = Xte(:,1:10);
    Ytr = Ytr(:,1:10);
    Yte = Yte(:,1:10);
end