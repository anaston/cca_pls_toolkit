function P = calc_proj(data, weight, method)
% calc_proj
%
% # Syntax
%   P = calc_proj(data, weight, method)
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

if exist('method', 'var') && strcmp(method, 'isnan')
    % Compute projection with missing data
    P = NaN(size(data, 1), size(weight, 2));
    for i = 1:size(weight, 2)
        P(:,i) = nansum(bsxfun(@times, data, weight(:,i)'), 2);
    end
% elseif exist('method', 'var') && strcmp(method, 'scaled')
%     % Compute projection without missing data and scaling by the number of
%     % features
%     P = data * weight / sum(weight~=0);
else
    % Compute projection without missing data
    P = data * weight;
end