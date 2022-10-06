function [trdata, tedata] = deflate_data(res, trdata, tedata, m, osplit)
% deflate_data
%
% # Syntax
%   [trdata, tedata] = deflate_data(res, trdata, tedata, m, osplit)
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

for i=2:res.frwork.level
    % Get splits from previous level
    reso = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', i-1), ...
        'res.mat'), 'res');

    % Get primal weight
    if strcmp(cfg.defl.name, 'pls-regression')
        w = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', ...
            i-1), 'model.mat'), 'wX');
    else
        w = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', ...
            i-1), 'model.mat'), ['w' m]);
    end

    if ismember(cfg.machine.name, {'pls' 'spls'})
        % Select weight
        if strcmp(cfg.defl.crit, 'none')
            w = w(reso.frwork.split.all==osplit,:)';
        else
            w = w(reso.frwork.split.all==reso.frwork.split.best,:)';
        end

        switch cfg.defl.name
            case 'pls-projection'
                % Deflation step
                trdata = deflation('pls-projection', trdata, m, w);
                if ~isempty(fieldnames(tedata))
                    tedata = deflation('pls-projection', tedata, m, w);
                end

            case 'pls-modeA'
                % Loading based on training data
                p = trdata.(m)' * (trdata.(m) * w) / ((trdata.(m) * w)' * (trdata.(m) * w));

                % Deflation step
                trdata = deflation('pls-modeA', trdata, m, w, p);
                if ~isempty(fieldnames(tedata))
                    tedata = deflation('pls-modeA', tedata, m, w, p);
                end

            case 'pls-regression'
                % Loading based on input training data
                p = trdata.(m)' * (trdata.X * w) / ((trdata.X * w)' * (trdata.X * w));

                % Deflation step
                trdata = deflation('pls-regression', trdata, m, w, p);
                if ~isempty(fieldnames(tedata))
                    tedata = deflation('pls-regression', tedata, m, w, p);
                end
        end

    else
        % Select weight
        if strcmp(cfg.defl.crit, 'none')
            split = osplit;
        else
            split = reso.frwork.split.best;
        end
        w = w(reso.frwork.split.all==split,:)';

        % Get hyperparameters
        param = loadmat(res, fullfile(res.dir.frwork, 'res', sprintf('level%d', ...
            i-1), 'param.mat'), 'param');
        t = param(reso.frwork.split.all==split).(['L2' lower(m)]);

        % Define feature index
        featid = get_featid(trdata, param(reso.frwork.split.all==split), m);

        if strcmp(cfg.defl.name, 'generalized')
            % Calculate weight in new feature space
            w = trdata.(['V' m])(:,featid)' * w;

            % Variance based on training data
            B = (1-t) * trdata.(['L' m])(featid) + repmat(t, sum(featid), 1);

            % Deflation step
            trdata = deflation('generalized', trdata, ['R' m], w, B, featid);
            if ~isempty(fieldnames(tedata))
                tedata = deflation('generalized', tedata, ['R' m], w, B, featid);
            end
        end
    end
end