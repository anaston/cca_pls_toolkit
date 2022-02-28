<span style="font-size:2em;">__update_dir__</span>

Updates the paths in `cfg` and all `res` files for the current computer.
It is needed to run when switching between computers e.g., moving data
from a cluster to a local computer.

##  Syntax
      update_dir(dir_frwork, fileend)
    
##  Inputs
*   **dir_frwork** [*char*]
    
    full path to the specific framework folder 
    
*   **fileend** [*char*]
    
    suffix at the end of the `res*.mat` file from `cfg.env.fileend`
    
##  Example
       % Example 1
       update_dir(<specific framework folder>, '_1');
    
---
See also: [cfg](../../cfg)

