function fix_fileend(cfg)

%----- Clean up data folder
movefile(fullfile(cfg.dir.data, 'inmat.mat'), fullfile(cfg.dir.data, 'inmat_1.mat'));
movefile(fullfile(cfg.dir.data, 'outmat.mat'), fullfile(cfg.dir.data, 'outmat_1.mat'));

%----- Clean up grid folder
if strcmp(cfg.frwork.name, 'holdout')
    movefile(fullfile(cfg.dir.grid, 'allgrid.mat'), fullfile(cfg.dir.grid, 'allgrid_1.mat'));
elseif strcmp(cfg.frwork.name, 'holdout_perm')
    movefile(fullfile(cfg.dir.grid, 'allgrid.mat'), fullfile(cfg.dir.grid, 'allgrid_1.mat'));
    movefile(fullfile(cfg.dir.grid, 'distances.mat'), fullfile(cfg.dir.grid, 'distances_1.mat'));
    movefile(fullfile(cfg.dir.grid, 'pvals.mat'), fullfile(cfg.dir.grid, 'allgrid_1.mat'));
    movefile(fullfile(cfg.dir.grid, sprintf('permid_N%d.mat', cfg.frwork.split.nin)), ...
        fullfile(cfg.dir.grid, sprintf('permid_N%d_1.mat', cfg.frwork.split.nin)));
end

%----- Clean up perm folder
movefile(fullfile(cfg.dir.perm, 'allperm.mat'), fullfile(cfg.dir.perm, 'allperm_1.mat'));
movefile(fullfile(cfg.dir.perm, sprintf('permid_N%d.mat', cfg.nperm)), fullfile(cfg.dir.perm, sprintf('permid_N%d_1.mat', cfg.nperm)));

%----- Clean up res folder
movefile(fullfile(cfg.dir.res, 'model.mat'), fullfile(cfg.dir.res, 'model_1.mat'));
movefile(fullfile(cfg.dir.res, 'param.mat'), fullfile(cfg.dir.res, 'param_1.mat'));
try
    movefile(fullfile(cfg.dir.res, 'results.mat'), fullfile(cfg.dir.res, 'results_1.mat'));
catch
end
movefile(fullfile(cfg.dir.res, 'cfg.mat'), fullfile(cfg.dir.res, 'cfg_1.mat'));

%----- Empty fileend field
cfg.env.fileend = '_1';
save(fullfile(cfg.dir.res, 'cfg_1.mat'), 'cfg')