function [u, v] = spls(cfg, data, param)
% spls
%
% Implementation for PLS and Sparse PLS
%
% # Syntax
%   [u, v] = spls(cfg, data, param)
%
% ---
% See also: [rcca](../rcca/), [fastsvd](../fastsvd/)
%
%_______________________________________________________________________
% Copyright (C) 2016, 2022 University College London

% Written by Joao Matos Monteiro (joao.monteiro@ucl.ac.uk)
% $Id$

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

% 28/02/2022 Modified by Agoston Mihalik (cca-pls-toolkit@cs.ucl.ac.uk)
%   Add cfg input and refactor code

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

% --------------------------- Private functions ---------------------------

function [up, failed] = iter_soft_threshold(cfg, w, c)

failed = false;

%--- update values
delta = 0;
up = soft_threshold(w, delta);
up = up./norm(up,2);

%--- check if it obeys the condition. If not, find delta that does.
if norm(up, 1) > c
    delta1 = delta;
    delta2  = delta1+1.1; % delta2 must be > 1
    
    % get first estimate of delta2
    flag = false;
    i = 0;
    max_delta = 0;
    while ~flag
        up = soft_threshold(w, delta2);
        up = up./norm(up,2);
        
        if sum(abs(up)) == 0 || isnan(sum(abs(up))) % if everthing is zero, the up/|up| will be 0/0 = nan
            delta2 = delta2/1.618; % They have to be diferent, otherwise it might not converge
        elseif norm(up, 1) > c
            delta1 = delta2;
            delta2 = delta2*2; % They have to be diferent, otherwise it might not converge
        elseif norm(up, 1) <= c
            flag = true;
        end
        
        if delta2>max_delta, max_delta = delta2;end
        
        if delta2 == 0
            if cfg.env.verbose == 1
                fprintf('Delta has to be zero\n');
            end
            failed = true;
            break
        end
        i = i+1;
        if i>1e4
            if cfg.env.verbose == 1
                fprintf('First delta estimation update did not converge\n');
            end
            delta1 = 0;
            delta2 = max_delta;
            break
        end
    end
    
    up = bisec(w, c, delta1, delta2);
    if isempty(up) || sum(isnan(up))>0
        if cfg.env.verbose == 1
            fprintf('Delta estimation unsuccessful\n');
        end
        failed = true;
    end
end


function out = soft_threshold(a,delta)
% Performs soft threshold (it does not normalize the output)
diff = abs(a)-delta;
diff(diff<0) = 0;
out = sign(a).*diff;


function out = bisec(K, c, x1,x2)
converge = false;
success = true;
tolerance = 1e-6;
while ~converge && success
    x = (x2 + x1) / 2;
    out = soft_threshold(K, x);
    out = out./norm(out,2);
    if sum(abs(out)) == 0
        x2 = x;
    elseif norm(out, 1) > c
        x1 = x;
    elseif norm(out, 1) < c
        x2 = x;
    end
    
    diff = abs(norm(out, 1) - c);
    if diff <= tolerance
        converge = true;
    elseif isnan(sum(diff))
        success = false;
        out = nan(size(K));
    end
end