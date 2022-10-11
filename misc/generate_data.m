function [X, Y, wX, wY] = generate_data(nexamples, nfeatx, nfeaty, activex, activey, noise)
% generate_data
%
% Generates data via a sparse latent variable model based on 
% [Witten et al. 2009](https://doi.org/10.2202/1544-6115.1470). The 
% generated data has two modalities with `nexamples` samples and `nfeatx` 
% and `nfeaty` variables, respectively. The `activex` and `activey` inputs
% define the number of variables in the two data modalities that are 
% associated with a Gaussian latent variable.
%
% # Syntax
%   [X, Y, wX, wY] = generate_data(nexamples, nfeatx, nfeaty, activex, activey, noise)
%
% # Inputs
% nexamples:: int
%   number of examples in generated data
% nfeatx:: int
%   number of features in generated data $\mathbf{X}$
% nfeaty:: int
%   number of features in generated data $\mathbf{Y}$
% activex:: int
%   number of active features in generated data $\mathbf{X}$
%   associated with the latent variable
% activey:: int
%   number of active features in generated data $\mathbf{Y}$
%   associated with the latent variable
% noise:: float
%   noise level in the generative model
%
% # Outputs
% X:: 2D numeric array
%   generated data $\mathbf{X}$ with `nexamples` rows and `nfeatx`
%   columns
% Y:: 2D numeric array
%   generated data $\mathbf{Y}$ with `nexamples` rows and `nfeaty`
%   columns
% wX:: numeric array
%   true weights used to generate data $\mathbf{X}$ from the latent 
%   variable, which has `activex` non-zero values
% wY:: numeric array
%   true weights used to generate data $\mathbf{Y}$ from the latent 
%   variable, which has `activey` non-zero values
%
% # Examples
%
%   % Example 1
%   [X, Y, wX, wY] = generate_data(1000, 100, 100, 10, 10, 1);
%
% ---
%
%_______________________________________________________________________
% Copyright (C) 2022 University College London

% Written by James Chapman (cca-pls-toolkit@cs.ucl.ac.uk)
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

z = normrnd(0,1,nexamples,1); %generate a random gaussian latent variable
wX=rand(1,nfeatx); %now generate some random weights that project from the latent variable space to the data space
wY=rand(1,nfeaty);
mask_x=zeros(1,nfeatx); %we mask off some of the variables so that only active_x and active_y are nonzero
mask_y=zeros(1,nfeaty);
mask_x(1:end,1:activex)=1;
mask_x=mask_x(randperm(length(mask_x))); %permute them
mask_y(1:end,1:activey)=1;
mask_y=mask_y(randperm(length(mask_y)));
wX=wX.*mask_x; %project to the data space by multiplying latent variable with weights
wY=wY.*mask_y;
X=z*wX;
Y=z*wY;
X=X+normrnd(0,noise,nexamples,nfeatx); %add some gaussian noise
Y=Y+normrnd(0,noise,nexamples,nfeaty);