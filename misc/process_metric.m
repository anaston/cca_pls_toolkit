function S = process_metric(cfg, S, runtype)
%   Process outputs of machines

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