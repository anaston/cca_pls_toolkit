function data = concat_data(trdata, tedata, modality, trid, teid)

% Check input
for f=1:numel(modality)
    if size(trdata.(modality{f}), 2) ~= size(tedata.(modality{f}), 2)
        error('Dimensions of training and test data do not match.')
    end
end
if size(trid, 1) ~= size(teid, 1)
   error('Dimensions of training and test indexes do not match.') 
end

% Concatenate train and test data
for f=1:numel(modality)
   % Initialize field
   data.(modality{f}) = NaN(size(trid, 1), size(trdata.(modality{f}), 2));
   
   % Training data
   data.(modality{f})(trid,:) = trdata.(modality{f});
    
   % Test data
   data.(modality{f})(teid,:) = tedata.(modality{f});
end
