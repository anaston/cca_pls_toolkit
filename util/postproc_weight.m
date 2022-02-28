function [weight, iweight] = postproc_weight(res, weight, modtype)

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