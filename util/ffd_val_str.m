function str = ffd_val_str(varargin)

% Parse input into field-value pairs
S = parse_input([], varargin{:});

% Full factorial design of value combinations
dFF = fullfact(structfun(@numel, S));

% Create combinations in string format
str = cell(1, size(dFF, 1));
fn = fieldnames(S);
for i=1:size(dFF, 1)    
   for j=1:size(dFF, 2)
       if mod(S.(fn{j})(dFF(i,j)), 1) == 0 % try decimal format
            str{i}{j} = [fn{j} '_' sprintf('%d', S.(fn{j})(dFF(i,j)))];
       
       elseif strfind(fn{j}, 'L2') % specific short format for L2 regularization
          str{i}{j} = [fn{j} '_' sprintf('%.4f', log(1-S.(fn{j})(dFF(i,j))))]; 
       
       else % otherwise use short format
          str{i}{j} = [fn{j} '_' sprintf('%.4f', S.(fn{j})(dFF(i,j)))]; 
       end
   end
   str{i} = strjoin(str{i}, '_');
end