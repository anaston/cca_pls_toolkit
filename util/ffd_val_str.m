function str = ffd_val_str(varargin)
% ffd_val_str
%
% # Syntax
%   str = ffd_val_str(varargin)
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

% Parse input into field-value pairs
S = parse_input([], varargin{:});

% Full factorial design of value combinations
dFF = fullfact(structfun(@numel, S));

% Create combinations in string format
str = cell(1, size(dFF, 1));
fn = fieldnames(S);
for i=1:size(dFF, 1)    
   for j=1:size(dFF, 2)
       if mod(S.(fn{j})(dFF(i,j)), 1) == 0 % try decimal format
            str{i}{j} = [fn{j} '_' sprintf('%d', S.(fn{j})(dFF(i,j)))];
       
       elseif strfind(fn{j}, 'L2') % specific short format for L2 regularization
          str{i}{j} = [fn{j} '_' sprintf('%.4f', log(1-S.(fn{j})(dFF(i,j))))]; 
       
       else % otherwise use short format
          str{i}{j} = [fn{j} '_' sprintf('%.4f', S.(fn{j})(dFF(i,j)))]; 
       end
   end
   str{i} = strjoin(str{i}, '_');
end