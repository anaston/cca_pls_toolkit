function plot_weight_brain_module(res, weight, wfname)
% plot_weight_brain_module
%
% # Syntax
%   plot_weight_brain_module(res, weight, wfname)
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

% Load label file
labelfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select delimited label file for regions...', 'any', res.conn.file.label);
T = readtable(labelfname);

% Check if necessary fields available
if ~ismember('Region', T.Properties.VariableNames)
    error('The connectivity label file should contain the following columns: Region');
end

% Load mask
maskfname = select_file(res, fullfile(res.dir.project, 'data'), ...
    'Select mask file...', 'mat', res.conn.file.mask);
load(maskfname);
if sum(mask(:)) ~= numel(weight)
    error('Mask does not match the dimensionality of weight');
end

% Display message based on verbosity level
switch res.env.verbose
    case 1
        fprintf('Max weight: %.4f\n', max(abs(weight(:))));
    otherwise
        % display nothing at the moment
end

% Create connectivity matrix
conn_weight = zeros(size(mask));
conn_weight(mask==1) = weight; % fill up using linear indexing
nparcel = length(conn_weight);
if numel(T.Label) ~= nparcel
    error('Number of parcels does not match the dimensionality of the weight vector');
end

% Weights summarized by module
[module, ia, ireg] = unique(T.Region);
nmodules = numel(module);
mod_weight = zeros();
for i=1:nmodules
    for j=1:nmodules
        idi = i==ireg;
        idj = j==ireg;
        w = conn_weight(idi,idj);
        switch res.conn.module.type
            case 'average' % normalize by connections within/between modules
                if i == j
                    mod_weight(i,i) = sum(w(:)) / (sum(idi) * (sum(idi)-1) / 2); % average weight within module
                else
                    mod_weight(i,j) = sum(w(:)) / (sum(idi) * (sum(idj))); % average weight between modules
                end
                
            case 'sum' % no normalization for module size
                mod_weight(i,j) = sum(w(:));
                
%             case 'number' % number of connections THIS WILL NEED A 1-COLOUR BASED COLORMAP
%                 mod_weight(i,j) = sum(w(:)~=0);
        end
    end
end

% Global normalization of weights
switch res.conn.module.norm
    case 'global'
        mod_weight = mod_weight / sum(abs(mod_weight(:)));
        
    case 'max'
        mod_weight = mod_weight / max(abs(mod_weight(:)));
end

% if res.conn.module.logtrans
%     mod_weight(mod_weight>0) = lognorm(mod_weight(mod_weight>0));
%     mod_weight(mod_weight<0) = -(lognorm(-mod_weight(mod_weight<0)));
% end
if res.conn.module.disp
    mod_weight
end

% Plot module level connectivity
idin = 1:nmodules;
figure('Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% imagesc(modweight(idin,idin));
imagesc(mod_weight);
set(gca, 'FontSize', 50, 'YTick', 1:sum(idin), 'YTickLabel', module(idin), ...
    'XTick', 1:sum(idin), 'XTickLabel', module(idin), 'XTickLabelRotation', 45); % 'XTickLabelRotation', 90
cmap = [[zeros(1, 132) linspace(0, 1, 124)]; zeros(1, 256); [linspace(1, 0, 124) zeros(1, 132) ]]';
colormap(cmap); % apply the colormap
colorbar;
% if strcmp(res.conn.module.type, 'number')
%     caxis([0 1] * max(abs(mod_weight(:))));
% else
caxis([-1 1] * max(abs(mod_weight(:))));
% end
% caxis([-0.21 0.21]);
saveas(gcf, [wfname '.png']);

% --------------------------- Private functions ---------------------------

function data = lognorm(data)

data = log(data);
% data(isinf(data)) = NaN;
data = (data - min(data)) / (max(data) - min(data));
% data(isnan(data)) = 0;