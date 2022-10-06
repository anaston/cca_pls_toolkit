function data = preproc_data(res, data, mod, fname, trid)
% preproc_data
%
% # Syntax
%   data = preproc_data(res, data, mod, fname, trid)
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

% TODO: add Gaussianization as option
%       code might be simplified and made more transparent + efficient

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Loop through preprocessing in order (without imputation)
cfg.data.(mod).preproc(ismember(cfg.data.(mod).preproc, 'impute')) = [];
preproc = cfg.data.(mod).preproc;
for i=1:numel(preproc)
    if strcmp(preproc{i}, 'zscore')
        % Z-score based on mu, sigma in training data
        if exist('trid', 'var') && ~exist_file(cfg, fname)
            [data.(mod), mu, sigma] = zscore(data.(mod));
            
        else
            [mu, sigma] = loadmat(cfg, fname, 'mu', 'sigma');
            data.(mod) = mean_center_features(data.(mod), mu);
            data.(mod) = norm_features(data.(mod), sigma);
        end
        
    elseif strcmp(preproc{i}, 'deconf')
        if strcmp(cfg.data.(mod).deconf, 'standard')
            % Estimate deconfounding variables using standard method
            if exist('trid', 'var') && ~exist_file(cfg, fname)
                beta = deconfound(data.(mod), data.C);
            else
                beta = loadmat(cfg, fname, 'beta');
            end
            
            % Perform deconfounding
            data.(mod) = deconfound(data.(mod), data.C, beta);
        elseif ~strcmp(cfg.data.(mod).deconf, 'none')
            error('Only standard deconfounding is supported at the moment.')
        end
    end
end

% Save file
if ~exist_file(cfg, fname)
    if ismember('zscore', cfg.data.(mod).preproc)
        if ismember('deconf', cfg.data.(mod).preproc)
            switch cfg.data.(mod).deconf
                case 'standard'
                    savemat(res, fname, 'mu', mu, 'sigma', sigma, 'beta', beta);

                case 'none'
                    savemat(res, fname, 'mu', mu, 'sigma', sigma);
            end
        else
            savemat(res, fname, 'mu', mu, 'sigma', sigma);
        end
        
    elseif ~strcmp(cfg.frwork.name, 'permutation')
        error('Z-scoring and/or doconfounding should be used in this framework.');
    end
end


% --------------------------- Private functions ---------------------------

function varargout = deconfound(data, C, beta)
% Deconfound matrix - mean centering implicitly included!

if ~exist('beta', 'var')
    % Estimate beta coefficients
    if any(isnan(data(:)))
        % Loop through each column due to missing values
        beta = NaN(size(C, 2), size(data, 2));
        for i=1:size(data, 2)
            beta(:,i) = pinv(C(~isnan(data(:,i)),:)) * data(~isnan(data(:,i)),i);
        end
    else
        % More time efficient
        beta = pinv(C) * data;
    end
    varargout{1} = beta;
else
    % Match beta coefficients if needed
    [nreg1, nfeat] = size(beta);
    nreg2 = size(C, 2);
    if nreg2 > nreg1
        beta = [beta; zeros(nreg2-nreg1, nfeat)];
        warning('Beta coefficients padded in training data.')
    elseif nreg1 > nreg2
        error('More beta coefficients in training data.')
    end
    
    % Regress out deconfounding matrix - trade-off between RAM and time efficiency
    batchid = [1:100:size(data, 1) size(data, 1)+1];
    for i=1:numel(batchid)-1
        rowid = batchid(i):batchid(i+1)-1;
        data(rowid,:) = data(rowid,:) - C(rowid,:) * beta;
    end
    varargout{1} = data;
end