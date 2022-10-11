function data = impute_mat(cfg, data, trid, mod)
% impute_mat
%
% # Syntax
%   data = impute_mat(cfg, data, trid, mod)
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

if any(isnan(data.(mod)(:)))
    % Display message based on verbosity level
    switch cfg.env.verbose
        case 1
            fprintf('Proportion of missing elements in %s: %.2f%%\n', mod, ...
                numel(find(isnan(data.(mod)))) / numel(data.(mod)) * 100)
        otherwise
            % display nothing at the moment
    end
else
    return
end

if strcmp(cfg.data.(mod).impute, 'median')
    % Replace all NaN with median of respective column
    for i=1:size(data.(mod), 2)
        data.(mod)(isnan(data.(mod)(:,i)),i) = nanmedian(data.(mod)(trid,i));
    end
else
    if any(isnan(data.(mod)(:))) && ismember(mod, {'X' 'C'})
        error('%s matrix shouldn''t contain NaN or it should be imputed', mod);
    end
end



