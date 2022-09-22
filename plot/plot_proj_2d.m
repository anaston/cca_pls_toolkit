function plot_proj_2d(res, P, fname)
% plot_proj_2d
%
% # Syntax
%   plot_proj_2d(res, P, fname)
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
% $Id$

% Create figure
if ~isempty(res.gen.figure.Position)
    figure('Position', res.gen.figure.Position);
else
    figure;
end

% Plot data
s = scatter(P(:,1), P(:,2));

% Update scatter properties
name_value = parse_struct(res.proj.scatter);
if ~isempty(res.proj.scatter.MarkerFaceColor) && ...
        size(res.proj.scatter.MarkerFaceColor, 1) > 1
    name_value{find(ismember(name_value(1:2:end), ...
        'MarkerFaceColor'))*2} = res.proj.scatter.MarkerFaceColor(1,:);
end
parse_input(s, name_value{:});

% Add least squares line if requested
if strcmp(res.proj.lsline, 'on') && ~isempty(res.proj.scatter.MarkerFaceColor)
    h = lsline;
    set(h, 'Color', res.proj.scatter.MarkerFaceColor(1,:), 'LineWidth', 1.2);
end

% Plot labels
xlabel(res.proj.xlabel);
ylabel(res.proj.ylabel);

% Update axes
name_value = parse_struct(res.gen.axes);
parse_input(gca, name_value{:});

% Save figure
saveas(gcf, [fname res.gen.figure.ext]);