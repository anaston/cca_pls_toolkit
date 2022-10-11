function plot_weight_behav_text(res, weight, iweight, wfname)
% plot_weight_behav_text
%
% # Syntax
%   plot_weight_behav_text(res, weight, iweight, wfname)
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
    'Select delimited label file for behaviour...', 'any', res.behav.file.label);
T = readtable(labelfname);
if ~all(ismember({'Category' 'Label' 'Label_proc' 'Label_bold'}, T.Properties.VariableNames)) % check if necessary fields available
    error('The behavioural label file should contain the following columns: Label, Label_bold');
end

% Normalize weight
if strcmp(res.behav.weight.norm, 'minmax')
    minmax = max(abs(weight));
    weight = weight / minmax;
elseif strcmp(res.behav.weight.norm, 'std')
    weight = weight / std(weight);
end

% Create weight table
T.Weight = weight;
T = T(iweight,:); % reorder table based on the order of the weight
if ~isinf(res.behav.weight.numtop) || res.behav.weight.filtzero
    T(T.Weight==0,:) = []; % remove 0 weights
end

% Flip order of weights for easier plotting
T = flipud(T);

% Text size
textsize_norm = '\fontsize{8}';
textsize_bold = '\fontsize{10}';

% Number of lines
% nlines = [11; 1];
nlines = [sum(T.Weight < 0); sum(T.Weight > 0)];

% Get text pixel size using a dummy figure and text
figure('Position', [0 0 1000 200]);
set(gca, 'FontName','Times New Roman');
[M, id] = max(cellfun(@numel, T.Label_proc)); 
hd = text(100, 100, [textsize_norm T.Label_proc{id}], ...
    'Units', 'pixels'); % text width based on normal text font of longest label
textbbox = get(hd, 'Extent');
text_w = textbbox(3);
hd = text(100, 100, [textsize_bold '\bf' T.Label_proc{id}], ...
    'Units', 'pixels');  % text width based on bold text font
textbbox = get(hd, 'Extent');
text_h = textbbox(4);
close;

% Open figure (in pixel position!)
figure;
m_x = 50;
m_y = 30;
pos_x = [m_x; text_w; m_x/2];
pos_y = [m_y; nlines(1)*text_h; m_y/2; nlines(2)*text_h; m_y];
set(gcf, 'Position', [0 0 sum(pos_x) sum(pos_y)], 'PaperPositionMode', 'auto');

% Set axes (in relative position!)
pos_rx = cumsum(pos_x / sum(pos_x));
pos_ry = cumsum(pos_y / sum(pos_y));
ax{1} = axes('Position',[pos_rx(1) pos_ry(1) diff(pos_rx(1:2)) diff(pos_ry(1:2))], ...
    'Visible', 'off'); % axes in relative position! 
ax{2} = axes('Position',[pos_rx(1) pos_ry(3) diff(pos_rx(1:2)) diff(pos_ry(3:4))], ...
    'Visible', 'off');

% Format labels
labels = T{:,{'Label_proc' 'Label_bold'}};
labels = {labels(1:nlines(1),:) labels(nlines(1)+1:end,:)};

% Color map
cmap = [0.3 0.3 0.9; 0.9 0.3 0.3];

% Plot
for i=1:numel(ax)
    % Activate current axes
    axes(ax{i});
    
    % Current axes position in pixel
    pos = getpixelposition(ax{i});
    
    % Plot labels (in axes pixel position)
    for j=1:nlines(i)
        str = [textsize_norm labels{i}{j,1}];
        try
            substr = strsplit(labels{i}{j,2}, ' ');
            for s=1:numel(substr)
                [startid, endid] = regexp(str, substr{s});
                str = [str(1:startid-1) textsize_bold '\bf' substr{s} textsize_norm ...
                    '\rm' str(endid+1:end)];
            end
        catch
        end
        
        text(0, (j-1)*text_h, str, 'Color', cmap(i,:), ...
            'Units', 'pixels', 'HorizontalAlignment', 'left');
    end
    
    % Print arrows (in figure pixel position)
    if nlines(i) > 0
        if i == 1
            annotation('arrow', [pos_rx(1) pos_rx(1)]-0.018, [pos_ry(2) pos_ry(1)] - 0.012, ... % -0.02
                'Color', cmap(i,:));
            text(-12, (j-1)*text_h, sprintf('%.2f', max(T.Weight(1:nlines(1)))), ... % 'Color', cmap(i,:), ... % 5
                'Units', 'pixels', 'HorizontalAlignment', 'right');
            text(-12, 0, sprintf('%.2f', min(T.Weight(1:nlines(1)))), ... % 'Color', cmap(i,:), ... % 5
                'Units', 'pixels', 'HorizontalAlignment', 'right');
        elseif i == 2
            annotation('arrow', [pos_rx(1) pos_rx(1)]-0.018, [pos_ry(3) pos_ry(4)] - 0.014, ... % -0.015
                'Color', cmap(i,:));
            text(-12, 0, sprintf('%.2f', min(T.Weight(nlines(1)+1:end))), ... %
                'Units', 'pixels', 'HorizontalAlignment', 'right'); % 'Color', cmap(i,:), 
            text(-12, (j-1)*text_h, sprintf('%.2f', max(T.Weight(nlines(1)+1:end))), ... %
                'Units', 'pixels', 'HorizontalAlignment', 'right'); % 'Color', cmap(i,:),    T.Weight(nlines(1)+1:end)
        end
    end
    
end

% Save figure
saveas(gcf, [wfname '.svg']);