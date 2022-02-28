<span style="font-size:2em;">__res_defaults__</span>

Set defaults in your results (`res`) structure including information about
the results and settings for plotting. Use this function to update and 
add all necessary defaults to your `res`. If you have defined anything in 
`res` before calling the function, it won't overwrite those values. The 
path to the framework folder should be always defined in your `res` or 
passed as varargin, otherwise the function throws an error. All the other 
fields are optional and can be filled up by `res_defaults`.

This function can be also called to load an existing `res*.mat` file. 

##  Syntax
      res = res_defaults(res, mode, varargin)
    
##  Inputs
*   **res** [*struct*]
    
    results structure (more information below)
    
*   **mode** [*'init', 'load', 'projection', 'simul', 'behav', 'conn', 'vbm', 'roi', 'brainnet'*]
    
    mode of calling res_defaults, either referring to initialization ('init'),
    loading ('load'), type of plot ('projection', 'simul', 'behav', 'conn', 
    'vbm', 'roi') or settings for toolbox ('brainnet') 
    
*   **varargin** [*name-value pairs*]
    
    additional parameters can be set via name-value pairs with dot notation 
    supported (e.g., 'behav.weight.numtop', 20)
    
##  Outputs
*   **res** [*struct*]
    
    result structure that has been updated with defaults
    
##  Examples
      % Example 1
      res.dir.frwork = 'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME';
      res.frwork.level = 1;
      res.env.fileend = '_1';
      res = res_defaults(res, 'load');
    
      % Example 2
      res = res_defaults([], 'load', 'dir.frwork', ...
                         'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME');
    
      % Example 3
      res = res_defaults([], 'load', 'dir.frwork', ...
                         'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME');
      res = res_defaults(res, 'behav');
    
---
See also: [res](../../res), [cfg_defaults](../cfg_defaults/)

