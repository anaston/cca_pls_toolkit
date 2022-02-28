function preproc_files %(cfg)

set_path;

load(fullfile('/Users/amihalik/Documents/projects/Taiane_ABIDE/projects/ohbm', ...
    'framework/pca_cca_holdout10-0.20_subsamp20-0.20_stb/cfg_1.mat'));

if strcmp(cfg.env.comp, 'cluster') && ~isempty(getenv('SGE_TASK_ID'))
    cfg.env.fileend = ['_' num2str(getenv('SGE_TASK_ID'))];
else
    cfg.env.fileend = '_1';
end
fprintf('%s\n', cfg.env.fileend)

% Load original data (and reorder if needed)
tmp = load(fullfile(cfg.dir.project, 'data', 'X.mat'));
data.X = tmp.X;
tmp = load(fullfile(cfg.dir.project, 'data', 'Y.mat'));
data.Y = tmp.Y;
if isfield(cfg.data, 'C')
    tmp = load(fullfile(cfg.dir.project, 'data', 'C.mat'));
    data.C = tmp.C;
    if ~any(arrayfun(@(x) isequal(ones(size(data.C, 1), 1), data.C(:,x)), 1:size(data.C, 2)))
        data.C = [ones(size(data.C, 1), 1) data.C]; % add bias term to confound if needed
    end
end

% Load splits
otrid = loadmat(cfg, fullfile(cfg.dir.frwork, 'outmat.mat'), 'otrid');
itrid = loadmat(cfg, fullfile(cfg.dir.frwork, 'inmat.mat'), 'itrid');

n = cfg.frwork.split.nout * (1 + cfg.frwork.split.nin);
k = 0;

rng('shuffle');

% Loop over iterations
iteri = randperm(cfg.frwork.split.nout);
            
% Loop over splits
for i=1:numel(iteri)
    % Preproc files for outer splits
    fname = sprintf('preproc_split_%d.mat', iteri(i));
    if ~exist_file(cfg, fullfile(cfg.dir.frwork, fname))
        preproc_data(cfg, data, otrid(:,iteri(i)), fullfile(cfg.dir.frwork, fname));
        k = k + 1;
        fprintf('%d (out of %d)\n', k , n);
    end
    
    iterj = randperm(cfg.frwork.split.nin);
    
    % Preproc files for inner splits
    for j=1:numel(iterj)
        fname = sprintf('preproc_split_%d_subsample_%d.mat', iteri(i), iterj(j));
        if ~exist_file(cfg, fullfile(cfg.dir.frwork, fname))
            preproc_data(cfg, data, itrid(:,iteri(i),iterj(j)), fullfile(cfg.dir.frwork, fname));
            k = k + 1;
            fprintf('%d (out of %d)\n', k , n);
        end
    end
end
