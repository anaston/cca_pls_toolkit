function S = calc_exvar(cfg, trdata, tedata, S, metric, varargin)
% calc_exvar
%
% Syntax:
%   S = calc_exvar(cfg, trdata, tedata, S, metric, varargin)
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

if isempty(tedata)
    data = trdata;
else
    data = tedata;
end

for i=1:numel(metric)
    if any(isnan(S.wX)) || any(isnan(S.wY))
        S.(metric{i}) = NaN;
        continue
    end
        
    if strfind(metric{i}, 'covar')
        mod = metric{i}(end-1:end);
    else
        mod = metric{i}(end);
    end
    
    if strcmp(cfg.defl.name, 'generalized')
        [param, featid] = deal(varargin{:});

        for m=mod
            M = upper(m);

            % Deflation
            B = (1-param.(['L2' m])) * trdata.(['L' M])(featid.(m)) + repmat(param.(['L2' m]), sum(featid.(m)), 1);
            data2 = deflation('generalized', data, ['R' M], S.(['w' M]), B, featid.(m));

            % Explained variance before/after deflation
            L.(M) = trace(data.(['R' M])' * data.(['R' M]));
            L2.(M) = trace(data2.(['R' M])' * data2.(['R' M]));
        end

        if strfind(metric{i}, 'covar')
            % Explained covariance before/after deflation
            L.XY = trace(data.RX(:,featid.x)' * data.RY(:,featid.y) * data.RY(:,featid.y)' * data.RX(:,featid.x));
            L2.XY = trace(data2.RX(:,featid.x)' * data2.RY(:,featid.y) * data2.RY(:,featid.y)' * data2.RX(:,featid.x));
        end

    else
        for m=mod
            M = upper(m);

            switch cfg.defl.name
                case 'pls-projection'
                    % Deflation
                    data2 = deflation('pls-projection', data, M, S.(['w' M]));

                case 'pls-modeA'
                    % Loading based on input training data
                    p = trdata.(M)' * (trdata.(M) * S.(['w' M])) / ...
                        ((trdata.(M) * S.(['w' M]))' * (trdata.(M) * S.(['w' M])));

                    % Deflation
                    data2 = deflation('pls-modeA', data, M, S.(['w' M]), p);

                case 'pls-regression'
                    % Loading based on input training data
                    p = trdata.(M)' * (trdata.X * S.wX) / ...
                        ((trdata.X * S.wX)' * (trdata.X * S.wX));

                    % Deflation
                    data2 = deflation('pls-regression', data, M, S.wX, p);
            end

            % Explained variance before/after deflation
            [data.(['R' M]), L.(M)] = fastsvd(data.(M), 0, 0, 1, 'R', 'L');
            [data2.(['R' M]), L2.(M)] = fastsvd(data2.(M), 0, 0, 1, 'R', 'L');
            L.(M) = sum(L.(M));
            L2.(M) = sum(L2.(M));
        end

        if strfind(metric{i}, 'covar')
            % Explained covariance before/after deflation
            L.XY = trace(data.RX' * data.RY * data.RY' * data.RX);
            L2.XY = trace(data2.RX' * data2.RY * data2.RY' * data2.RX);
        end
    end

    % Explained variance/covariance
    if strfind(metric{i}, 'covar')
        S.(metric{i}) = (1 - L2.XY / L.XY) * 100;
    else
        S.(metric{i}) = (1 - L2.(M) / L.(M)) * 100;
    end
end