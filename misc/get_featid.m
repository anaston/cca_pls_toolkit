function featid = get_featid(data, param, mod)
% get_featid
%
% # Syntax
%   featid = get_featid(data, param, mod)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

if isfield(param, (['VAR' lower(mod)]))
    % Reduce dimensionality by explained variance
    featid = cumsum(data.(['L' mod])) / sum(data.(['L' mod])) <= param.(['VAR' lower(mod)]);
    
else
    % Keep all variance
    featid = true(size(data.(['L' mod])));
end

if isfield(param, (['PCA' lower(mod)]))
    if sum(featid) < param.(['PCA' lower(mod)])
        warning('Dimensionality of data %s is lower than number of PCA components', mod);
    else
        % Reduce dimensionality by number of PCA components
        featid(param.(['PCA' lower(mod)])+1:end) = false;
    end
end