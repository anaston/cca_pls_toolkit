<span style="font-size:2em;">__generate_data__</span>

Generates data via a sparse latent variable model based on 
[Witten et al. 2009](https://doi.org/10.2202/1544-6115.1470). The 
generated data has two modalities with `nexamples` samples and `nfeatx` 
and `nfeaty` variables, respectively. The `activex` and `activey` inputs
define the number of variables in the two data modalities that are 
associated with a Gaussian latent variable.

##  Syntax
      generate_data(nexamples, nfeatx, nfeaty, activex, activey, noise)
    
##  Inputs
*   **nexamples** [*int*]
    
    number of examples in generated data
    
*   **nfeatx** [*int*]
    
    number of features in generated data $\mathbf{X}$
    
*   **nfeaty** [*int*]
    
    number of features in generated data $\mathbf{Y}$
    
*   **activex** [*int*]
    
    number of active features in generated data $\mathbf{X}$
    associated with the latent variable
    
*   **activey** [*int*]
    
    number of active features in generated data $\mathbf{Y}$
    associated with the latent variable
    
*   **noise** [*float*]
    
    noise level in the generative model
    
##  Outputs
*   **X** [*2D numeric array*]
    
    generated data $\mathbf{X}$ with `nexamples` rows and `nfeatx`
    columns
    
*   **Y** [*2D numeric array*]
    
    generated data $\mathbf{Y}$ with `nexamples` rows and `nfeaty`
    columns
    
*   **wX** [*numeric array*]
    
    true weights used to generate data $\mathbf{X}$ from the latent 
    variable, which has `activex` non-zero values
    
*   **wY** [*numeric array*]
    
    true weights used to generate data $\mathbf{Y}$ from the latent 
    variable, which has `activey` non-zero values
    
##  Examples
      % Example 1
      [X, Y, wX, wY] = generate_data(1000, 100, 100, 10, 10, 1);
    
---
Author: James Chapman

