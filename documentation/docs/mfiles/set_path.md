<span style="font-size:2em;">__set_path__</span>

Adds essential folders to the path to initialize the toolkit for an
analysis. For visualization, it needs to be called with specific folders
to add plotting and other toolbox folders to the path.

##  Syntax
      dir_toolkit = set_path(varargin)
    
##  Inputs
*   **varargin** [*char*]
    
    folders passed as arguments will be added to the path
    
    `set_path` looks for folders under the toolkit folder and under the 
    `external` folder. In the latter case it is sufficient to use the
    first few characters of the toolbox, e.g., `spm` instead of `spm12`.
    
##  Outputs
*   **dir_toolkit** [*char*]
    
    full path to the toolkit folder
    
##  Examples
       % Example 1
       set_path;
    
       % Example 2
       set_path('plot');
    
       % Example 3
       set_path('plot', 'spm', 'brainnet');
    
---
