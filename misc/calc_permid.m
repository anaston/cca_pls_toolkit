function calc_permid(res, runtype)

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Initialize file
file = fullfile(res.dir.frwork, runtype, sprintf('permmat_%d.mat', res.stat.nperm));

% Quit if permutations already generated
if res.stat.nperm == 0 || res.frwork.level > 1 || exist_file(res, file)
    return
end

% Display options based on verbosity level
switch res.env.verbose
    case 1
        fprintf('Generating permutations...\n');
        tic
    case 2
        fprintf('\nGenerating permutations...\n');
    case 3
        fprintf('Generating permutations...\n');
end

% Add PALM to path
set_path('palm');

% Set seed for reproducibility
rng(cfg.env.seed.perm);

% Define exchangeability blocks (EB)
if cfg.data.block && ~isempty(cfg.data.EB.stat)
    load(fullfile(cfg.dir.project, 'data', 'EB.mat'));
    EB = EB(:,cfg.data.EB.stat);
else
    EB = [ones(cfg.data.nsubj, 1) (1:cfg.data.nsubj)'];
end

% Initialize training/test separation in EB
EB = [repmat(-1, cfg.data.nsubj, 1) EB];

% Create permutations respecting EB
[otrid, oteid] = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid', 'oteid');
permid = cell(1, res.frwork.split.nall);
for i=1:res.frwork.split.nall
    % EB at each iteration
    EBi = EB;
    
    % Training index
    trid = otrid(:,res.frwork.split.all(i));
    
    % Update EB
    if strcmp(cfg.stat.perm, 'train')
        EBi = EBi(trid,2:end); % subsample training indexes
        
    elseif strcmp(cfg.stat.perm, 'train+test')
        EBi(:,2) = EB(:,2) .* (trid+1); % add training/test separation
    end
    
    % Permute
    if ~exist_file(res, file)
        pset = palm_quickperms([], EBi, cfg.stat.nperm+1);
        permid{i} = pset(:,2:end); % neutral permutation is ignored
    else
        break
    end
end

% Save permutations
if ~isdir(fullfile(res.dir.frwork, runtype))
    mkdir(fullfile(res.dir.frwork, runtype))
end
savemat(res, file, 'permid', permid);

% Display options based on verbosity level
switch res.env.verbose
    case 1
        fprintf('done!\n');
        toc
    case 2
        fprintf('done!\n');
end