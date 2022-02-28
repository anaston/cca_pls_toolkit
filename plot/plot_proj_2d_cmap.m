function plot_proj_2d_cmap(res, P, fname, grp, lg)
% plot_proj_2d_cmap
%
% Syntax:  plot_proj_2d_cmap(res, P, fname, grp, lg)

% Create figure
if ~isempty(res.gen.figure.Position)
    figure('Position', res.gen.figure.Position);
else
    figure;
end

% Add colormap
set_path('cbrewer');
if exist('cbrewer', 'file')
    cmap = cbrewer('seq', 'Purples', 64);
    colormap(cmap);
end

% Plot data
s = scatter(P(:,1), P(:,2), [], grp, 'filled');

% Update scatter properties
name_value = parse_struct(res.proj.scatter);
parse_input(s, name_value{:});

% Add colorbar
pos = get(gca, 'Position');
c = colorbar;
ylabel(c, lg);
set(gca, 'Position', pos); % reposition axes as it has been misplaced by colorbar

% Plot labels
xlabel(res.proj.xlabel);
ylabel(res.proj.ylabel);

% Update axes
name_value = parse_struct(res.gen.axes);
parse_input(gca, name_value{:});

% Save figure
saveas(gcf, [fname res.gen.figure.ext]);