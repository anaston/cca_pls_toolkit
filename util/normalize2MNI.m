function normalize2MNI(res, template, weight, transM)

% Handle path to template
[template_path, name, ext] = fileparts(template);
template = [name ext];

% Initialize matlab batch jobs
matlabbatch = {struct()};

% Reorient image
matlabbatch{end}.spm.util.reorient.srcfiles = {fullfile(template_path, template); ...
    fullfile(res.dir.res, weight)};
matlabbatch{end}.spm.util.reorient.transform.transM = transM;
matlabbatch{end}.spm.util.reorient.prefix = 'r';

% Estimate normalization to MNI space using segmentation
if ~exist(fullfile(template_path, ['y_r' template]), 'file')
    matlabbatch{end+1}.spm.spatial.preproc.channel.vols(1) = {fullfile(template_path, ['r' template])};
    matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{end}.spm.spatial.preproc.channel.write = [0 0];
    ngaus = [1 1 2 3 4 2];
    for i=1:numel(ngaus)
        matlabbatch{end}.spm.spatial.preproc.tissue(i).tpm = {fullfile(fileparts(which('spm')), ...
            'tpm', ['TPM.nii,' num2str(i)])};
        matlabbatch{end}.spm.spatial.preproc.tissue(i).ngaus = ngaus(i);
        matlabbatch{end}.spm.spatial.preproc.tissue(i).native = [0 0];
        matlabbatch{end}.spm.spatial.preproc.tissue(i).warped = [0 0];
    end
    matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{end}.spm.spatial.preproc.warp.write = [0 1];
else
    fprintf('Segmentation skipped as normalization file already exists.\n\n');
end

% Apply normalization to MNI space
matlabbatch{end+1}.spm.spatial.normalise.write.subj.def(1) = {fullfile(template_path, ['y_r' template])};
matlabbatch{end}.spm.spatial.normalise.write.subj.resample(1) = {fullfile(res.dir.res, ['r' weight])};
matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{end}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix = 'w';

% Run spm job
spm('defaults', 'fMRI');
spm_jobman('run', matlabbatch);