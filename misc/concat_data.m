function data = concat_data(trdata, tedata, modality, trid, teid)
% concat_data
%
% # Syntax
%   data = concat_data(trdata, tedata, modality, trid, teid)
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

% Check input
for f=1:numel(modality)
    if size(trdata.(modality{f}), 2) ~= size(tedata.(modality{f}), 2)
        error('Dimensions of training and test data do not match.')
    end
end
if size(trid, 1) ~= size(teid, 1)
   error('Dimensions of training and test indexes do not match.') 
end

% Concatenate train and test data
for f=1:numel(modality)
   % Initialize field
   data.(modality{f}) = NaN(size(trid, 1), size(trdata.(modality{f}), 2));
   
   % Training data
   data.(modality{f})(trid,:) = trdata.(modality{f});
    
   % Test data
   data.(modality{f})(teid,:) = tedata.(modality{f});
end
