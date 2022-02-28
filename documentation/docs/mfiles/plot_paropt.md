<span style="font-size:2em;">__plot_paropt__</span>

It plots the grid search results of the hyperparameter optimization. 

##  Syntax
      plot_paropt(res, split, metrics, varargin)
    
##  Inputs
*   **res** [*struct*]
    
    res structure containing information about results and plot specifications
    
*   **split** [*int*]
    
    index of data split to be used
    
*   **metrics** [*'trcorrel', 'correl', 'trcovar', 'covar', 'trexvarx', 'exvarx', 'trexvary', 'exvary', 'simwx', 'simwy', 'simwxy', 'correl+simwxy'*]
    
    metrics to be plotted as a function of hyperparameter grid, each metric 
    in a separate subplot
    
*   **varargin** [*name-value pairs*]
    
    additional options can be passed via name-value pairs with dot notation
    supported
    
##  Examples
       % Plot hyperparameter surface for grid search results
       plot_paropt(res, 1, {'correl', 'simwx', 'simwy'}, ...
       'gen.figure.Position', [500 600 1200 400], 'gen.axes.FontSize', 20, ...
       'gen.axes.XScale', 'log', 'gen.axes.YScale', 'log');
    
![hyperparameter_surface](../figures/example_simul_paropt.png)

---
See also: [plot_proj](../plot_proj), [plot_weight](../plot_weight)

