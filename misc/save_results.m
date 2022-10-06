function res = save_results(res)
% save_results
%
% # Syntax
%   res = save_results(res)
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

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load true metrics
S = loadmat_struct(res, fullfile(res.dir.res, 'model.mat'));

% Save res
if res.stat.sig
    % Significant results
    switch cfg.defl.crit
        case {'correl' 'covar'}
            save_res_pos(res, S.(cfg.defl.crit), {'max'});

        case 'pval+correl'
            save_res_pos(res, [res.stat.pval S.correl], {'min' 'max'});

        case 'correl+simwxy'
            distance = calc_distance(S.correl, nanmean(cat(2, S.simwx, S.simwy), 2));
            save_res_pos(res, distance, {'min'});
    end
else
    % No significant results
    save_res_neg(res);
end

% Write results table
output = {'split', res.frwork.split.all, cfg.stat.crit, S.(cfg.stat.crit), ...
    'pval', res.stat.pval};
if ~strcmp(cfg.stat.crit, 'correl')
    output = [output {'correl', S.correl}];
end
if strcmp(cfg.machine.name, 'spls')
    output = [output {'nfeatx', S.wX, 'nfeaty', S.wY}];
else
    param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
    if strcmp(cfg.machine.name, 'rcca')
        output = [output {'l2x', cat(1, param.L2x), 'l2y', cat(1, param.L2y)}];
    else
        if isfield(param, 'PCAx') && isfield(param, 'PCAy')
            output = [output {'npcax', cat(1, param.PCAx), 'npcay', cat(1, param.PCAy)}];
        end
        if isfield(param, 'VARx') && isfield(param, 'VARy')
            output = [output {'varx', cat(1, param.VARx), 'vary', cat(1, param.VARy)}];
        end
    end
end
if isfield(cfg, 'defl') && ~isempty(strfind(cfg.defl.crit, 'sim'))
    output = [output {'dist', distance}];
end
write_results(res, 'results_table', output{:});


% --------------------------- Private functions ---------------------------

function write_results(res, fname, varargin)

% Create table
T = table();
for i=1:numel(varargin)
    if ~mod(i, 2)
        switch varargin{i-1}
            case {'split' 'npcax' 'npcay'}
                T.(varargin{i-1}) = varargin{i};
                
            case {'nfeatx' 'nfeaty'}
                T.(varargin{i-1}) = sum(varargin{i}~=0, 2);
                
            case {'dist' 'l2x' 'l2y' 'pval' 'correl' 'covar'}
                T.(varargin{i-1}) = arrayfun(@(x) sprintf('%.4f', x), ...
                    varargin{i}, 'un', 0);           
        end
    end
end

% Write results
writetable(T, fullfile(res.dir.res, [fname '.txt']), 'Delimiter', '\t');


function res = save_res_pos(res, varargin)

% Assign input
[metric, fun] = varargin{1:2};
num = size(metric, 2);
if num ~= numel(fun)
    error('number of elements in metric and fun should match')
end

% Best split using criterions in specific order
bestid = (1:res.frwork.split.nall)';
for i=1:num
    fh = str2func(fun{i});
    met = cat(1, metric(bestid,i));
    [M, I] = fh(met);
    bestid = bestid(met == M); % we want all solutions
end
if numel(bestid) ~= 1
    warning('Multiple best splits, first index chosen');
end
res.frwork.split.best = res.frwork.split.all(bestid);

savemat(res, fullfile(res.dir.res, 'res.mat'), 'res', res);

% Display message based on verbosity level
switch res.env.verbose
    case {1 2}
        fprintf('\nSignificant results found!\n\n');
    case 3
        fprintf('Significant results found!\n\n');
end


function save_res_neg(res)

savemat(res, fullfile(res.dir.res, 'res.mat'), 'res', res);

% Display message based on verbosity level
switch res.env.verbose
    case {1 2}
        fprintf('\nNo significant results found at this level!\n\n');
    case 3
        fprintf('No significant results found at this level!\n\n');
end