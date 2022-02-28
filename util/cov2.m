function c = cov2(A, B)
%  Custom function for computing covariance as built-in matlab function 
% supports only same number of columns

% Check input dimensions
if size(A, 1) ~= size(B, 1)
   error('Size of matrices should match for covariance calculation'); 
end

% Compute covariance
c = bsxfun(@minus, A, mean(A))' * bsxfun(@minus, B, mean(B)) / (size(A, 1) - 1);