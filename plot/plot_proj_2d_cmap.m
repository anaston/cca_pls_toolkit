function plot_proj_2d_cmap(res, P, fname, grp, lg)
% plot_proj_2d_cmap
%
% # Syntax
%   plot_proj_2d_cmap(res, P, fname, grp, lg)
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