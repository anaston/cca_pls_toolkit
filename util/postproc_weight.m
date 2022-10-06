function [weight, iweight] = postproc_weight(res, weight, modtype)
% postproc_weight
%
% # Syntax
%   [weight, iweight] = postproc_weight(res, weight, modtype)
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

% Sort weights if requested
if strcmp(res.(modtype).weight.sorttype, '')
    iweight = 1:numel(weight); % we keep original order
elseif strcmp(res.(modtype).weight.sorttype, 'abs')
    [~, iweight] = sort(abs(weight), 'descend');
elseif strcmp(res.(modtype).weight.sorttype, 'sign')
    [~, iweight] = sort(weight, 'descend');
end

% Keep only top weights if requested
if ~isinf(res.(modtype).weight.numtop)
    if strcmp(res.(modtype).weight.sorttype, 'abs') && sum(weight~=0) >= res.(modtype).weight.numtop
        weight(iweight(res.(modtype).weight.numtop+1:end)) = 0;
    elseif strcmp(res.(modtype).weight.sorttype, 'sign')
        numnonneg = [sum(weight>0) sum(weight<0)];
        if any(numnonneg >= res.(modtype).weight.numtop)
            numnonneg(numnonneg>=res.(modtype).weight.numtop) = res.(modtype).weight.numtop;
            weight(iweight(numnonneg(1)+1:end-numnonneg(2))) = 0;
        end
    end
end

% Keep only positive/negative weights if requested
if isfield(res.(modtype).weight, 'sign')
    if strcmp(res.(modtype).weight.sign, 'positive')
        weight(weight<0) = 0;
    elseif strcmp(res.(modtype).weight.sign, 'negative')
        weight(weight>0) = 0;
    end
end