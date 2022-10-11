function run_model(res, runtype)
% run_model
%
% # Syntax
%   run_model(res, runtype)
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

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');
    
% Update runtype if needed
if strcmp(cfg.frwork.name, 'holdout_perm') && strcmp(runtype, 'gridsearch')
    runtype = 'gridsearch_perm';
end

switch runtype
    case 'gridsearch'
        % Get default parameters and quit if no grid search
        param = get_hyperparam(res, 'default');
        if numel(param) == 1
            return
        end
        
        while ~exist_file(res, fullfile(res.dir.grid, 'allgrid.mat'))
            % Display progress based on verbosity level
            switch res.env.verbose
                case 1
                    fprintf('\nRunning hyperparameter optimization\n\n');
                    tic;
                case 2
                    fprintf('\nRunning hyperparameter optimization\n');
                case 3
                    fprintf('Running hyperparameter optimization...');
            end

            % Create folder for grid search results 
            if ~isdir(res.dir.grid)
                mkdir(res.dir.grid)
            end
            
            % Set seed for reproducibility
            rng(res.env.seed.model);
            
            % Initialize files
            p = reshape(fieldnames(param), 1, []); % make sure it is a row vector
            in = [p; cellfun(@(x) cfg.machine.param.(x), p, 'un', 0)];
            file = cellfun(@(x) fullfile(res.dir.grid, ['grid_' x '.mat']), ...
                ffd_val_str('split', res.frwork.split.all, in{:}), 'un', 0);
            file = reshape(file, res.frwork.split.nall, []);
            
            % Loop over iterations in random order
            iteri = randperm(res.frwork.split.nall);
            for i=1:numel(iteri)

                iterj = randperm(size(file, 2));
                for j=1:numel(iterj)
                    if ~exist_file(res, file{iteri(i),iterj(j)})
                        % Display progress based on verbosity level
                        switch res.env.verbose
                            case 1
                                fprintf('\nhyperparameter id: %d (out of %d), split id: %d (out of %d)\n', ...
                                    j, numel(param), i, res.frwork.split.nall);
                                tic;
                            case 2
                                fprintf('hyperparameter id: %d (out of %d), split id: %d (out of %d)...', ...
                                    j, numel(param), i, res.frwork.split.nall);
                        end
                        
                        % Initialize machine outputs
                        fields = [{'wX' 'wY'} cfg.machine.metric(~contains(cfg.machine.metric, 'sim'))];
                        S = cell2struct(cell(numel(fields), cfg.frwork.split.nin), fields);
                        
                        for m=1:cfg.frwork.split.nin
                            % Load data and split to training and test sets
                            clear trdata tedata
                            [trdata, ~, tedata, ~, featid] = load_data(res, {'X' 'Y'}, ...
                                'isplit', [res.frwork.split.all(iteri(i)), m], param(iterj(j)));
                            
                            % Run machine
                            S(m) = run_machine(cfg, trdata, tedata, featid, param(iterj(j)));
                        end
                        S = process_metric(cfg, S, 'gridsearch');
                        
                        % Write metric to disk
                        name_value = parse_struct(S, 2);
                        savemat(res, file{iteri(i),iterj(j)}, name_value{:});
                        
                        if exist_file(res, fullfile(res.dir.grid, 'allgrid.mat'))
                            break
                        end

                        % Display progress based on verbosity level
                        switch res.env.verbose
                            case 1
                                fprintf('\nhyperparameter id: %d (out of %d), split id: %d (out of %d) done!\n', ...
                                    j, numel(param), i, res.frwork.split.nall);
                                toc
                            case 2
                                fprintf(' done!\n');
                        end
                    end
                end
                
            end
            
            % Display progress based on verbosity level
            switch res.env.verbose
                case 1
                    fprintf('Hyperparameter optimization done!\n');
                    toc
                case 2
                    fprintf('Hyperparameter optimization done!\n');
                case 3
                    fprintf(' done!\n');
            end

            % Compile files
            compile_files(res, file);
        end
        
                    
    case 'main'
        % Create folder for main results 
        if ~isdir(res.dir.res)
            mkdir(res.dir.res)
        end
        
        % Load and save parameters
        param = get_hyperparam(res, 'default');
        if numel(param) == 1
            param = repmat(param, res.frwork.split.nall, 1);
        elseif isfield(res.dir, 'grid')
            param = get_hyperparam(res, 'grid');
        end
        savemat(res, fullfile(res.dir.res, 'param.mat'), 'param', param);
                
        % Initialize file and machine outputs
        file = fullfile(res.dir.res, 'model.mat');
        fields = [{'wX' 'wY'} cfg.machine.metric(~contains(cfg.machine.metric, 'sim'))];
        S = cell2struct(cell(numel(fields), res.frwork.split.nall), fields);
                    
        if ~exist_file(res, file)
            % Display options based on verbosity level
            switch res.env.verbose
                case 1
                    fprintf('\nTraining main models\n\n');
                    tic
                case 2
                    fprintf('\nTraining main models...');
                case 3
                    fprintf('Training main models...');
            end
            
            for n=1:res.frwork.split.nall
                % Load data and split to training and test sets
                clear trdata tedata
                [trdata, ~, tedata, ~, featid] = load_data(res, {'X' 'Y'}, 'osplit', ...
                    res.frwork.split.all(n), param(n));
                
                % Run machine
                S(n) = run_machine(cfg, trdata, tedata, featid, param(n));
            end
            S = process_metric(cfg, S, 'main');
            
            % Save results
            name_value = parse_struct(S, 1);
            savemat(res, file, name_value{:});

            % Display options based on verbosity level
            switch res.env.verbose
                case 1
                    fprintf('Training main models done!\n');
                    toc
                case {2 3}
                    fprintf(' done!\n');
            end
        end
                    
    case 'permutation'
        % Quit if no permutations needed or maximum statistics at level > 1
        if res.stat.nperm == 0 || (strcmp(cfg.frwork.name, 'permutation') ...
                && res.frwork.level > 1)
            return
        end
        
        % Create folder for permutation test results 
        if ~isdir(res.dir.perm)
            mkdir(res.dir.perm)
        end
        
        while ~exist_file(res, fullfile(res.dir.perm, 'allperm.mat'))
            % Display options based on verbosity level
            switch res.env.verbose
                case 1
                    fprintf('\nRunning permutation tests\n\n');
                    tic;
                case 2
                    fprintf('\nRunning permutation tests\n');
                case 3
                    fprintf('Running permutation tests...');
            end

            % Load parameters
            param = loadmat(res, fullfile(res.dir.res, 'param.mat'), 'param');
            
            % Initialize files
            file = arrayfun(@(x) fullfile(res.dir.perm, sprintf('perm_%05d.mat', x)), ...
                1:cfg.stat.nperm, 'un', 0);
            
            % Set seed for reproducibility
            rng(res.env.seed.model);
            
            % Run permutation test
            iter = randperm(numel(file));
            for it=1:numel(iter)
                if ~exist_file(res, file{iter(it)})
                    % Display progress based on verbosity level
                    switch res.env.verbose
                        case 1
                            fprintf('\npermutation id: %d (out of %d)...\n', it, numel(file));
                            tic
                        case 2
                            fprintf('permutation id: %d (out of %d)...', it, numel(file));
                    end
                    
                    % Initialize machine outputs
                    fields = [{'wX' 'wY'} cfg.machine.metric(~contains(cfg.machine.metric, 'sim'))];
                    S = cell2struct(cell(numel(fields), res.frwork.split.nall), fields);
                        
                    for n=1:res.frwork.split.nall
                        % Load data and split to training and test sets
                        clear trdata tedata
                        [trdata, ~, tedata, ~, featid] = load_data(res, {'X' 'Y'}, 'osplit', ...
                            res.frwork.split.all(n), param(n));
                        
                        % Permute data
                        [trdata, tedata] = permute_data(res, trdata, tedata, ...
                            res.frwork.split.all(n), iter(it));
                        
                        % Run machine
                        S(n) = run_machine(cfg, trdata, tedata, featid, param(n));
                    end
                    S = process_metric(cfg, S, 'permutation');
                    
                    % Write metric to disk
                    name_value = parse_struct(S, 1);
                    savemat(res, fullfile(res.dir.perm, sprintf('perm_%05d.mat', iter(it))), name_value{:});
                    
                    % Update missing files
                    if exist_file(res, fullfile(res.dir.perm, 'allperm.mat'))
                        break
                    end
                    
                    % Display progress based on verbosity level
                    switch res.env.verbose
                        case 1
                            fprintf('\npermutation id: %d (out of %d) done!\n', it, numel(file));
                            toc
                        case 2
                            fprintf(' done!\n');
                    end                    
                end
            end
            
            % Display progress based on verbosity level
            switch res.env.verbose
                case 1
                    fprintf('Permutation test done!\n');
                    toc
                case 2
                    fprintf('Permutation test done!\n');
                case 3
                    fprintf(' done!\n');
            end
            
            % Compile files
            compile_files(res, file);
        end
end    