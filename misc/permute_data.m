function [trdata, tedata] = permute_data(res, trdata, tedata, osplit, iperm)

% Load cfg
cfg = loadmat(res, fullfile(res.dir.frwork, 'cfg.mat'), 'cfg');

% Load training and test indexes
[otrid, oteid] = loadmat(res, fullfile(res.dir.frwork, 'outmat.mat'), 'otrid', 'oteid');
trid = otrid(:,osplit);
teid = oteid(:,osplit);

% Subjects permutations index
permid = loadmat(res, fullfile(res.dir.frwork, 'perm', sprintf('permmat_%d.mat', ...
    res.stat.nperm)), 'permid');
sid = permid{res.frwork.split.all==osplit}(:,iperm);

if strfind(cfg.stat.perm, 'train')
    % Subject orders within training set
    if strcmp(cfg.stat.perm, 'train+test')
        [~, trsid] = sort(sid(trid));
        [~, trsid] = sort(trsid);
    else
        trsid = sid;
    end

    % Permute training subjects
    switch cfg.machine.name
        case {'pls' 'spls'}
            trdata.Y = trdata.Y(trsid,:);

        case {'cca' 'rcca'}
            trdata.RY = trdata.RY(trsid,:);
    end
end

if strfind(cfg.stat.perm, 'test')
    % Subject orders within test set
    [~, tesid] = sort(sid(teid));
    [~, tesid] = sort(tesid);
    
    % Permute test subjects
    switch cfg.machine.name
        case {'pls' 'spls'}
            tedata.Y = tedata.Y(tesid,:);
            
        case {'cca' 'rcca'}
            tedata.RY = tedata.RY(tesid,:);
    end
end
