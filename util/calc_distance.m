function d = calc_distance(varargin)

d = NaN(size(varargin{1}));
for i=1:numel(varargin{1})
    d(i) = pdist([cellfun(@(x) x(i), varargin); ones(1, numel(varargin))]);
end

