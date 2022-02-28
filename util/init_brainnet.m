function fname = init_brainnet(res, varargin)

% Parse inputs
S = parse_input([], varargin{:});

% Set path for Brainnet
set_path('brainnet');

% Set defaults for Brainnet
res = res_defaults(res, 'brainnet'); 

% Make custom Brainnet folder
dir_brainnet = fullfile(res.dir.project, 'data', 'BrainNet');
if ~isdir(dir_brainnet)
    mkdir(dir_brainnet); 
end

% Brainnet mesh/surface file
fname.surf = select_file(res, pwd, 'Select brain mesh file...', '\.nv$', which(res.brainnet.file.surf));

% Brainnet options file
fname.options = select_file(res, dir_brainnet, 'Select options file...', 'mat', res.brainnet.file.options);

% Brainnet edge file
if isfield(S, 'wfname') && isfield(S, 'weight')
    [pathstr, fname.edge, ext] = fileparts(S.wfname);
    fname.edge = fullfile(dir_brainnet, [fname.edge, '.edge']);
    dlmwrite(fname.edge, S.weight, 'Delimiter', '\t'); % edge file weight*2*pi
end

% Brainnet node file
if isfield(S, 'labelfname') && isfield(S, 'T')
    [pathstr, fname.node, ext] = fileparts(S.labelfname);
    fname.node = fullfile(dir_brainnet, [fname.node, '.node']);
    % Check fields (color, size, MNI space) >> to be implemented
    writetable(S.T(:,{'X' 'Y' 'Z' 'Color' 'Size'}), 'tmp.txt', 'delimiter', '\t', 'WriteVariableNames', 0);
    movefile('tmp.txt', fname.node); % node file
end