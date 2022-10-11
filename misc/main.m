function main(res)
% main
%
% # Syntax
%   main(res)
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

%----- 1. Initialize results

if ~isfield(res.frwork, 'level')
    % Initialize results
    res = res_defaults([], 'init', 'frwork.level', 1, 'dir.frwork', res.dir.frwork, ...
        'env.fileend', res.env.fileend, 'env.seed', res.env.seed, ...
        'frwork.nlevel', res.frwork.nlevel, 'env.verbose', res.env.verbose);
else
    % Update results
    res = res_defaults(res, 'init');
end

% Display progress
fprintf('Associative effect %d\n', res.frwork.level);

%----- 2. Calculate data splits

% Calculate outer train-test
calc_splits(res, 'out');

% Calculate inner train-test (for hyperparameter optimization)
calc_splits(res, 'in');

%----- 3. Run models

% Calculate grid search over hyper-parameters
run_model(res, 'gridsearch');

% Run main model
run_model(res, 'main');

% Initialize permutations
calc_permid(res, 'perm');
            
% Run permutation tests
run_model(res, 'permutation');

%----- 4. Calculate stats and save results

% Calculate statistical inference
res = stat_inference(res);

% Save results
res = save_results(res);

%----- 5. Run analysis on next level

if res.frwork.level == res.frwork.nlevel
    % Terminate analysis
    return

elseif res.stat.nperm == 0 || res.stat.sig
    % Run analysis iteratively
    res.frwork.level = res.frwork.level + 1;
    main(res);
end
