function data = impute_mat(cfg, data, trid, mod)

if any(isnan(data.(mod)(:)))
    % Display message based on verbosity level
    switch cfg.env.verbose
        case 1
            fprintf('Proportion of missing elements in %s: %.2f%%\n', mod, ...
                numel(find(isnan(data.(mod)))) / numel(data.(mod)) * 100)
        otherwise
            % display nothing at the moment
    end
else
    return
end

if strcmp(cfg.data.(mod).impute, 'median')
    % Replace all NaN with median of respective column
    for i=1:size(data.(mod), 2)
        data.(mod)(isnan(data.(mod)(:,i)),i) = nanmedian(data.(mod)(trid,i));
    end
else
    if any(isnan(data.(mod)(:))) && ismember(mod, {'X' 'C'})
        error('%s matrix shouldn''t contain NaN or it should be imputed', mod);
    end
end



