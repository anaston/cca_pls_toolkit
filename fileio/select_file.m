function fname = select_file(res, folder, str, ext, default)
% select_file
%   Some description here

% Wrapper to select file interactively with SPM or use default
fname = [];
if strcmp(res.gen.selectfile, 'interactive')
    fname = spm_select(1, ext, str, {}, folder); % GUI to get file
end
if isempty(fname)
    fname = default;
end