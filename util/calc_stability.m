function [S_avg, S_square, S] = calc_stability(W, nsplits, type, subtype)
% calc_stability
%
% Calculates the stability/similarity across weights (see Baldassare et al.
% 2017).
%
% Syntax:
%   [S_avg, S_square, S] = calc_stability(W, nsplits, type, subtype)
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

% 11/10/2022 Modified by Agoston Mihalik (am3022@cam.ac.uk)
%   Bug fix: output NaN in correct shape if all (or all but one) splits 
%       have NaN weights (e.g. due to SPLS not converging)

if strcmp(type, 'overlap') && ~exist('subtype', 'var')
    subtype = 'corrected'; % default option
end

% Handle NaN and/or single-column input
if iscell(W)
    idnan = cellfun(@(x) any(isnan(x)), W);
    W(idnan) = []; % remove NaN
    W = cat(2, W{:});
else
    idnan = any(isnan(W), 1);
    W(:,idnan) = []; % remove NaN
end
nw = size(W, 2);
if nw < 2
    % Create NaN in correct shape
    S_avg = NaN(1, nsplits);
    S_square = NaN(nsplits, nsplits);
    if nsplits < 3
        S = NaN;
    else
        S = NaN(1, nsplits*(nsplits-1)/2);
    end
    return
end

% Calculate expected ranking if requested
if strcmp(type, 'expected-ranking')
    R = zeros(size(W));
    for i=1:nw
       [~, R(W(:,i)~=0,i)] = sort(W(W(:,i)~=0,i), 'ascend'); 
    end
    ER = mean(R, 2);
    S_avg = NaN(1, nw);
    for i=1:nw
        S_avg(i) = ranking_pairwise(R(:,i), ER);
    end
    return
end

% Get indexes of pairwise comparisons
[I, J] = find(tril(ones(nw), -1));

% Calcalute all pairwise stabilities/similarities
S = zeros(1, numel(J));
for el=1:numel(J)
    switch type
        case 'correlation'
            S(el) = abs(correlation_pairwise(W(:,I(el)), W(:,J(el)), subtype));
            
        case 'overlap'
            S(el) = overlap_pairwise(W(:,I(el)), W(:,J(el)), subtype); 
    end
end

% Average overlap
S_square = NaN(length(idnan));
S_square(~idnan,~idnan) = squareform(S);
S_avg = nanmean(S_square) * nw / (nw-1); % correction for diagonal
S_square = S_square + eye(length(idnan)); % max similarity in diagonal!!


% --------------------------- Private functions ---------------------------

function S = ranking_pairwise(w1, w2)

S = w1' * w2 / (norm(w1) * norm(w2)); 


function S = correlation_pairwise(w1, w2, type)

S = corr(w1, w2, 'Type', type);


function S = overlap_pairwise(w1, w2, type)

% Expected overlap
E = 0;
if strcmp(type, 'corrected')
    E = size(w1, 1) * sparsity(w1, 'relative') * sparsity(w2, 'relative');
end

% Overlap
S = (sparsity(all([w1 w2], 2)) - E) / max([sparsity(w1) sparsity(w2)]);


function sp = sparsity(vec, type)

% Sparsity
sp = sum(vec ~= 0);

% Relative sparsity
if exist('type', 'var') && strcmp(type, 'relative')
    sp = sp / numel(vec);
end

