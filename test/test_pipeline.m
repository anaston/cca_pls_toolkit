function test_pipeline

% Set path for analysis
set_path;

% Project folder
cfg.dir.project = 'test';

% Machine settings
cfg.machine.name = 'spls';
cfg.machine.metric = {'correl'};
cfg.machine.param.nL1x = 5;
cfg.machine.param.nL1y = 5;

% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 1;
cfg.frwork.flag = '';

% Deflation settings
cfg.defl.name = 'pls-modeA';

% Environment settings
cfg.env.comp = 'local';

% % Number of permutations
cfg.stat.nperm = 100;
   
% Update cfg with defaults
cfg = cfg_defaults(cfg);

% Run analysis
main(cfg);

% Clean up analysis files to save disc space
cleanup_files(cfg);

% Compare results with reference
tol = 1e-10;
check = false(3, 2);
for i=1:2
    % Grid search
    S_ref = load(fullfile(cfg.dir.frwork, 'grid', ['level' num2str(i)], 'allgrid_1.mat'));
    S = load(fullfile('test', 'framework', 'spls_holdout1-0.20_subsamp5-0.20_REF', ...
        'grid', ['level' num2str(i)], 'allgrid_1.mat'));
    if norm(S_ref.correl - S.correl) < tol
        check(1,i) = true;
    end

    % Permutations
    S_ref = load(fullfile(cfg.dir.frwork, 'perm', ['level' num2str(i)], 'allperm_1.mat'));
    S = load(fullfile('test', 'framework', 'spls_holdout1-0.20_subsamp5-0.20_REF', ...
        'perm', ['level' num2str(i)], 'allperm_1.mat'));
    if norm(S_ref.correl - S.correl) < tol
        check(2,i) = true;
    end

    % Main results
    S_ref = load(fullfile(cfg.dir.frwork, 'res', ['level' num2str(i)], 'model_1.mat'));
    S = load(fullfile('test', 'framework', 'spls_holdout1-0.20_subsamp5-0.20_REF', ...
        'res', ['level' num2str(i)], 'model_1.mat'));
    if norm(S_ref.correl - S.correl) < tol && ...
            norm(S_ref.wX - S.wX) < tol && norm(S_ref.wY - S.wY) < tol
        check(3,i) = true;
    end
end
if all(check(:))
    fprintf('\nBasic analysis pipeline ok\n');
else
    fprintf('\nPotential bug in basic analysis pipeline!\n')
end