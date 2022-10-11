function plot_proj_2d_group(res, P, fname, grp, lg)
% plot_proj_2d_group
%
% # Syntax
%   plot_proj_2d_group(res, P, fname, grp, lg)
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

% Input checks
ug = unique(grp);
if numel(ug) ~= numel(lg)
    error('Number of groups should match the number of legends.')
end
% if numel(ug) > size(res.proj.scatter.MarkerFaceColor, 1)
%     error('Number of groups should match the number of colours.')
% end

% Create figure
if ~isempty(res.gen.figure.Position)
    figure('Position', res.gen.figure.Position);
else
    figure;
end
hold on;

% Plot data
for i=1:numel(ug)
    % Get subset of data
    p = P(grp==ug(i),:);

    % Plot data
    s = scatter(p(:,1), p(:,2));

    % Update scatter properties
    name_value = parse_struct(res.proj.scatter);
    if ~isempty(res.proj.scatter.MarkerFaceColor) && ...
            size(res.proj.scatter.MarkerFaceColor, 1) > 1
        name_value{find(ismember(name_value(1:2:end), ...
            'MarkerFaceColor'))*2} = res.proj.scatter.MarkerFaceColor(i,:);
    end
    parse_input(s, name_value{:});

    % Display message based on verbosity level
    switch res.env.verbose
        case 1
            fprintf('Correlation between latent variables for group %d: %.4f\n', ...
                i, corr(p(:,1), p(:,2)));
        otherwise
            % display nothing at the moment
    end
end

% Add least squares line if requested
if strcmp(res.proj.lsline, 'on') && ~isempty(res.proj.scatter.MarkerFaceColor)
    h = lsline;
    for i=1:numel(h)
        set(h(numel(h)+1-i), 'Color', res.proj.scatter.MarkerFaceColor(i,:), ...
            'LineWidth', 1.2); % lsline plots objects in reverse order!
    end
end
hold off;

% Plot labels
xlabel(res.proj.xlabel);
ylabel(res.proj.ylabel);

% Update legend and axes properties
name_value = parse_struct(res.gen.legend);
if ~isempty(lg{1})
    legend(lg, name_value{:});
end
name_value = parse_struct(res.gen.axes);
parse_input(gca, name_value{:});

% Save figure
saveas(gcf, [fname res.gen.figure.ext]);