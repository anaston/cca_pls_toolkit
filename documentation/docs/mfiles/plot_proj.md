<span style="font-size:2em;">__plot_proj__</span>

It plots the projections of the data (i.e., latent variables).

##  Syntax
      plot_proj(res, mod, level, sidvar, split, colour, func, varargin)
    
##  Inputs
*   **res** [*struct*]
    
    res structure containing information about results and plot specifications
    
*   **mod** [*cell array*]
    
    modality of data to be used for plotting (i.e., `{'X', 'Y'}`) 
    
*   **level** [*int or numeric array*]
    
    level of associative effect with same dimensionality as `mod` or 
    automatically extended (e.g., from int to numeric array)
    
*   **sidvar** [*'osplit', 'otrid', 'oteid', 'isplit', 'itrid',  'iteid'*]
    
    specifies subjects to be used for plotting
    
    first letter can be 'o' for outer or 'i' for inner split, followed by 
    either 'trid' for training, 'teid' for test or 'split' for both 
    training and test data
    
*   **split** [*int or numeric array*]
    
    index of data split to be used with same dimensionality as `mod` or 
    automatically extended (e.g., from int to numeric array)
    
*   **colour** [*'none', char*]
    
    `'none'` for scatterplot with same colour for all subjects or it can be
    used as a continuous colormap or for colouring different groups; there
    are three ways to define the colour
    
    specify a variable, which can be loaded from a data file (e.g., `Y.mat`)
    using the name of the variable defined in a label file (e.g., 
    `LabelsY.csv`)
    
    use `'training+test'` to colour-code the training and test sets
    
    use any other string with a `'+'` sign (e.g., 'MDD+HC') to define the 
    colour-code based on `group.mat`
    
*   **func** [*'2d', '2d_group', '2d_cmap'*]
    
    name of the specific plotting function (after plot_proj_* prefix) to
    be called
    
*   **varargin** [*name-value pairs*]
    
    additional options can be passed via name-value pairs with dot notation
    supported
    
##  Examples
###  Simple plots
Most often, we plot a brain latent variable vs. a behavioural latent variable
for a specific level (i.e., associative effect).

       % Plot data projections coloured by groups
       plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', res.frwork.split.best, ...
       'training+test', '2d_group', 'gen.axes.FontSize', 20, ...
       'gen.legend.FontSize', 20, 'gen.legend.Location', 'NorthWest', ... 
       'proj.scatter.SizeData', 120, 'proj.scatter.MarkerEdgeColor', 'k', ...
       'proj.scatter.MarkerFaceColor', [0.3 0.3 0.9; 0.9 0.3 0.3]);  
    
![projection_plot](../figures/plot_proj_simple.png)

###  Multi-level plots
To plot projections aggregated over multiple levels, all you need to 
specify is res.proj.multi_level = 1 and provide a 2D cell array of input 
variable 'mod'. Input variables 'level' and 'split' should have the same 
dimensionality or they will be extended automatically from 1-D or 2-D arrays
(e.g. level = repmat(level, size(mod))).

       % Plot data projections across levels (and averaged across modalities 
       % in a level after standardization)
       plot_proj(res, {'X' 'Y'; 'X' 'Y'}, [1 1; 2 2], 'osplit', res.frwork.split.best, ...
                 'none', '2d', 'proj.multi_label', 1);
    
---
See also: [plot_paropt](../plot_paropt), [plot_weight](../plot_weight/)

