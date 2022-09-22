function [res, metric, permdist] = stat_inference(res)
% stat_inference
%
% # Syntax
%   [res, metric, permdist] = stat_inference(res)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

% Quit if no permutations needed
if res.stat.nperm == 0
    res.stat.sig = 0;
    return
end
        
%----- Loading

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load permuted metrics
if strcmp(cfg.frwork.name, 'permutation') % first effect for maximum statistics
    S_perm = loadmat_struct(res, fullfile(res.dir.frwork, 'perm', 'level1', 'allperm.mat'));

else % current effect
    S_perm = loadmat_struct(res, fullfile(res.dir.perm, 'allperm.mat'));
end

% Load true metrics
S = loadmat_struct(res, fullfile(res.dir.res, 'model.mat'));

% Calculate p-value within each data split
res.stat.pval = zeros(res.frwork.split.nall, 1);
for i=1:res.frwork.split.nall
    res.stat.pval(i) = calc_pval(S_perm.(cfg.stat.crit)(i,:), ...
        S.(cfg.stat.crit)(i), 'max');
end
metric = S.(cfg.stat.crit);
permdist = S_perm.(cfg.stat.crit);

% Bonferroni correction across data splits
res.stat.sig = any(res.stat.pval < (cfg.stat.alpha / res.frwork.split.nall));


% --------------------------- Private functions ---------------------------

function pval = calc_pval(perm_dist, true_val, flag)

if strcmp(flag, 'max')
    pval = (1 + nansum(perm_dist >= true_val)) / (numel(perm_dist) - ...
        numel(find(isnan(perm_dist))) + 1);
    
elseif strcmp(flag, 'min')
    pval = (1 + nansum(perm_dist <= true_val)) / (numel(perm_dist) - ...
        numel(find(isnan(perm_dist))) + 1);
end