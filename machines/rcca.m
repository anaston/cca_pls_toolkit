function [wX, wY] = rcca(data, featid, param)
% rcca
%
% Implementation for Regularized CCA
%
% Syntax:  [wX, wY] = rcca(data, featid, param)
%
% # Inputs
% input1:: Description
% input2:: Description
% input3:: Description
%
% # Outputs
% output1:: Description
% output2:: Description
%
% # Example
%    Line 1 of example
%    Line 2 of example
%    Line 3 of example
%
%
% See also: [spls](../spls/)
%
% Author: Agoston Mihalik
%
% Website: http://www.mlnl.cs.ucl.ac.uk/

% Calculate covariance/cross-covariance matrices
BYY = (1-param.L2y) * data.LY(featid.y) + repmat(param.L2y, sum(featid.y), 1);
BXX = (1-param.L2x) * data.LX(featid.x) + repmat(param.L2x, sum(featid.x), 1);
RXY = data.RX(:,featid.x)' * data.RY(:,featid.y);

% Solve standard eigenvalue problem
[wY, lambda] = eigs(diag(1./sqrt(BYY)) * RXY' * diag(1./BXX) * RXY * diag(1./sqrt(BYY)), 1);
lambda = real(sqrt(lambda));

% Compute weights
wY = diag(1./sqrt(BYY)) * wY;
wX = diag(1./BXX) * RXY * wY / lambda;