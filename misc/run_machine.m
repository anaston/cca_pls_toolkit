function S = run_machine(cfg, trdata, tedata, featid, param)
% run_machine
%
% # Syntax
%   S = run_machine(cfg, trdata, tedata, featid, param)
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

%----- Model training

% Run machine
switch cfg.machine.name
    case {'pls' 'spls'}
        % PLS/SPLS solved by power method
        [S.wX, S.wY] = spls(cfg, trdata, param);
        
    case {'cca' 'rcca'}
        % CCA/RCCA/PLS/PCA-CCA solved by standard eigenvalue problem
        [S.wX, S.wY] = rcca(trdata, featid, param);
end

%---- Model diagnostics

% Compute projections for training data
if ismember(cfg.machine.name, {'pls' 'spls'})
    trdata.PX = calc_proj(trdata.X, S.wX);
    trdata.PY = calc_proj(trdata.Y, S.wY);
else
    trdata.PY = calc_proj(trdata.RY(:,featid.y), S.wY);
    trdata.PX = calc_proj(trdata.RX(:,featid.x), S.wX);
end

% Compute training metrics
if ismember('trcorrel', cfg.machine.metric)
    % Correlation
    S.trcorrel = corr(trdata.PX, trdata.PY); 
end
if ismember('trcovar', cfg.machine.metric)
    % Covariance
    S.trcovar = cov2(trdata.PX, trdata.PY);
end
isexvar = contains(cfg.machine.metric, 'trex');
if any(isexvar)
    % Explained variance
    if strcmp(cfg.defl.name, 'generalized')
        S = calc_exvar(cfg, trdata, [], S, cfg.machine.metric(isexvar), param, featid);
    else
        S = calc_exvar(cfg, trdata, [], S, cfg.machine.metric(isexvar));
    end    
end  
cfg.machine.metric(isexvar) = [];

%---- Model evaluation

if ismember(cfg.machine.name, {'pls' 'spls'})
    tedata.PX = calc_proj(tedata.X, S.wX);
    tedata.PY = calc_proj(tedata.Y, S.wY);
else
    tedata.PX = calc_proj(tedata.RX(:,featid.x), S.wX);
    tedata.PY = calc_proj(tedata.RY(:,featid.y), S.wY);
end

% Compute test metrics
if ismember('correl', cfg.machine.metric)
    % Correlation
    S.correl = corr(tedata.PX, tedata.PY); % , 'Type', 'Spearman'
end
if ismember('covar', cfg.machine.metric)
    % Covariance
    S.covar = cov2(tedata.PX, tedata.PY);
end
isexvar = contains(cfg.machine.metric, 'ex');
if any(isexvar)
    % Explained variance
    if strcmp(cfg.defl.name, 'generalized')
        S = calc_exvar(cfg, trdata, tedata, S, cfg.machine.metric(isexvar), param, featid);
    else
        S = calc_exvar(cfg, trdata, tedata, S, cfg.machine.metric(isexvar));
    end    
end 

%---- Auxiliary steps

% Calculate primal weights
if ismember(cfg.machine.name, {'cca' 'rcca'})
    S.wX = trdata.VX(:,featid.x) * S.wX;
    S.wY = trdata.VY(:,featid.y) * S.wY;
end

% Record unsuccessful convergence for SPLS
if ismember('unsuc', cfg.machine.metric)
    S.unsuc = isnan(S.correl);
end