function [S_avg, S_square, S] = calc_stability(W, type, subtype)
%   calc_stability calculates the stability/similarity across weights, see 
% Baldassare et al 2017
%
% In particular, it calculates the pairwise correlations for non-sparse
% weights and the pairwise relative overlaps for sparse weights.
%
% Input: W       = matrix of weight vectors as columns
%        type    = 'correlation' or 'overlap'
%        subtype = 'corrected'/'uncorrected' for type of overlap
%
% Output: S_avg = average pairwise stability/similarity per data split

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
if nw == 1
    [S_avg, S_square, S] = deal(NaN);
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

