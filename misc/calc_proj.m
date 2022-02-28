function P = calc_proj(data, weight, method)

if exist('method', 'var') && strcmp(method, 'isnan')
    % Compute projection with missing data
    P = NaN(size(data, 1), size(weight, 2));
    for i = 1:size(weight, 2)
        P(:,i) = nansum(bsxfun(@times, data, weight(:,i)'), 2);
    end
% elseif exist('method', 'var') && strcmp(method, 'scaled')
%     % Compute projection without missing data and scaling by the number of
%     % features
%     P = data * weight / sum(weight~=0);
else
    % Compute projection without missing data
    P = data * weight;
end