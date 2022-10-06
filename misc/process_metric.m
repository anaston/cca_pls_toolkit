function S = process_metric(cfg, S, runtype)
% process_metric
%
% Processes outputs of machines.
%
% # Syntax
%   S = process_metric(cfg, S, runtype)
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

for i=1:numel(cfg.data.mod)
    m = cfg.data.mod{i}; % shorthand variable
    
    % Calculate similarity of weights
    if ismember(['simw' lower(m)], cfg.machine.metric)
        type = strsplit(cfg.machine.simw, '-'); % type of similarity measure
        [~, sim_all] = calc_stability({S.(['w' m])}, type{:});
        if length(sim_all) > 1
            s = length(sim_all);
            sim_all = reshape(sim_all(~eye(s)), s-1, s); % remove diagonal entries
        end
        sim_all = num2cell(permute(sim_all, [3 2 1]), 3);
        [S(:).(['simw' lower(m)])] = deal(sim_all{:});
    end
    
    % Transpose weights for main models
    if strcmp(runtype, 'main')
        for j=1:size(S)
            S(j).(['w' m]) = S(j).(['w' m])';
            if ismember(['simw' lower(m)], cfg.machine.metric)
                S(j).(['simw' lower(m)]) = permute(S(j).(['simw' lower(m)]), [1 3 2]);
            end
        end
    end
end

% Remove fields from output
if ~strcmp(runtype, 'main')
    S = rmfield(S, {'wX' 'wY'});
end