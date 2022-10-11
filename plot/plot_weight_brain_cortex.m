function plot_weight_brain_cortex(res, weight, wfname)
% plot_weight_brain_cortex
%
% # Syntax
%   plot_weight_brain_cortex(res, weight, wfname)
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

% Load mask
maskfname = select_file(res, fullfile(res.dir.project, 'data'), 'Select mask file...', 'nii', res.vbm.file.mask);
hdr_mask = spm_vol(maskfname);
img_mask = spm_read_vols(hdr_mask);
img_mask(isnan(img_mask)) = 0;

% Create image from weight
img = zeros(hdr_mask.dim);
img(img_mask~=0) = weight;
    
% Normalize weight
if strcmp(res.vbm.weight.norm, 'minmax')
    minmax = max(abs(weight));
    img = img / minmax;
elseif strcmp(res.vbm.weight.norm, 'std')
    img = img / std(weight);
end

% Write weight on disc
hdr = struct('dim', hdr_mask.dim, 'dt', [spm_type('float32') spm_platform('bigend')], ...
    'mat', hdr_mask.mat, 'pinfo', [1 0 0]', 'n', [1 1], 'descrip', 'Image'); % header settings are important!!
hdr.fname = [wfname '.nii'];
spm_write_vol(hdr, img);

% Normalize if weight is not in MNI space
if ~isequal(res.vbm.transM, eye(4))
    [pathstr, name, ext] = fileparts(wfname);
    normalize2MNI(res, res.vbm.file.MNI, [name '.nii'], res.vbm.transM)
    wfname = fullfile(pathstr, ['wr' name]); % rename file
end

% Plot with BrainNet
fname = init_brainnet(res);
if exist(fname.options, 'file')
    BrainNet_MapCfg(fname.surf, [wfname '.nii'], [wfname res.gen.figure.ext], fname.options);
else
    BrainNet_MapCfg(fname.surf, [wfname '.nii'], [wfname res.gen.figure.ext]);
end