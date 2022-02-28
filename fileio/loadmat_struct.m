function S = loadmat_struct(res, fname, varargin)
% loadmat
%   Some description here

% Parse fname
[pathstr, name, ext] = fileparts(fname);
if isempty(res.env.fileend)
    filename = getfname(pathstr, ['^' name ext]);
else
    filename = getfname(pathstr, ['^' name '_\d+' ext]);
end

timestamp = clock;

while ~isempty(filename)
    % Try loading data
    try
        S = load(fullfile(pathstr, filename{1}), varargin{:});
        break;
    catch
        % Keep looping if file is temporarily unavailable
        if etime(clock, timestamp) < 60
            pause(10*rand); % wait a bit
            continue;
        else
            delete(fullfile(pathstr, filename{1}));
            if res.env.verbose == 1
                fprintf('File corrupt: %s\n', fullfile(pathstr, filename{1}));
            end
            filename(1) = [];
        end
    end
end