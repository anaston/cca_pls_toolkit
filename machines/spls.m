function [u, v] = spls(cfg, data, param)
% spls
%
% Implementation for Sparse PLS
%
% Syntax:  [u, v] = spls(cfg, data, param)
%
% ---
% See also: [rcca](../rcca/),  [fastsvd](../fastsvd/)
%
% Author: Joao Monteiro, Agoston Mihalik

% Initialize variables
diff = Inf;
i = 0;
success = true;
data.XY = data.X' * data.Y;        
v = fastsvd(data.XY, 1, 0, 1, 'V');
    
while diff > cfg.machine.spls.tol && success    
    % Compute X weight
    u(:,2) = data.XY * v(:,1);
    u(:,2) = u(:,2) / norm(u(:,2));
    
    % Apply soft thresholding to obey constraint
    if param.L1x >= 1 && param.L1x <= sqrt(size(u, 1))
        [u(:,2), failed_sparsity] = iter_soft_threshold(cfg, u(:,2), param.L1x);
        if failed_sparsity
            if cfg.env.verbose == 1
                fprintf('There was a problem with the delta estimation of the L1 regularization of wX\n');
            end
            u(:,2) = NaN(size(u, 1), 1);
            break
        end
    end
    
    % Compute Y weight
    v(:,2) = data.XY' * u(:,2);
    v(:,2) = v(:,2) / norm(v(:,2));
    
    % Apply soft thresholding to obey constraint
    if param.L1y >= 1 && param.L1y <= sqrt(size(v, 1))
        [v(:,2), failed_sparsity] = iter_soft_threshold(cfg, v(:,2), param.L1y);
        if failed_sparsity
            if cfg.env.verbose == 1
                fprintf('There was a problem with the delta estimation of the L1 regularization of wY\n');
            end
            v(:,1) = NaN(size(v, 1), 1);
            break
        end
    end
    
    % Check convergence
    diff = max(norm(u(:,2) - u(:,1)), norm(v(:,2) - v(:,1)));
    if i >= cfg.machine.spls.maxiter
        if cfg.env.verbose == 1
            fprintf('Maximum number of iterations reached\n');
        end
        success = false;
    end
    i = i+1;
    
    % Update weights
    u(:,1) = u(:,2);
    v(:,1) = v(:,2);
end

%--- Add converged weight vectors to output
u = u(:,2);
v = v(:,1); % index is due to the break statement