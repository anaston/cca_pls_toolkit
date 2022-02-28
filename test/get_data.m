function [Xtr, Ytr, Xte, Yte] = get_data(fullrank)

% Load data
load(fullfile('test', 'data', 'X.mat'));
load(fullfile('test', 'data', 'Y.mat'));

% Split data to training and test
Xtr = X(1:40,:);
Xte = X(41:50,:);
Ytr = Y(1:40,:);
Yte = Y(41:50,:);

% Mean center data
[Xtr, mnx] = mean_center_features(Xtr);
Xte = mean_center_features(Xte, mnx);
[Ytr, mny] = mean_center_features(Ytr);
Yte = mean_center_features(Yte, mny);

% Normalize data
[Xtr, scx] = norm_features(Xtr, [], 'std');
Xte = norm_features(Xte, scx, 'std');
[Ytr, scx] = norm_features(Ytr, [], 'std');
Yte = norm_features(Yte, scx, 'std');

% Reduce to full rank if requested
if fullrank
    Xtr = Xtr(:,1:10);
    Xte = Xte(:,1:10);
    Ytr = Ytr(:,1:10);
    Yte = Yte(:,1:10);
end