!!! info "Dependencies"

	There is only one necessary dependency (PALM Toolbox) to run CCA/PLS analyses. In short, the PALM toolbox allows to use restricted permutations based on the exchangeability block structure of the data (i.e., which examples are	allowed to be exchanged or not). The exchangeability block structure is also used for stratified partitioning of the data (i.e., some examples are kept in 	the same data splits). For further information on exchangeability blocks, see the section [Data](#data) or [Winkler et al 2015](https://doi.org/10.1016/j.neuroimage.2015.05.092) and the [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM). 


## Overview

As illustrated in the figure below, the analysis can be divided into eight operations.

<p align="center">
   <img src="../figures/flowchart.png" width="415" height="284">
</p>


Here we describe these operations and the contents of the output files they create:

1. __Initialization__: setting and saving the analysis configuration into `cfg*.mat` file including a `cfg` structure. For details on `cfg`, see the section [Configuration for analysis](#configuration-for-analysis).
2. __Data splitting__: creating training and test sets of the data and saving outputs into `outmat*.mat` and `inmat*.mat` files. The `outmat*.mat` file includes:

	- `otrid`: 2D logical array defining the training sets of the outer data splits (rows corresponding to examples and columns corresponding to the outer splits),
	- `oteid`: 2D logical array defining the test sets of the outer data splits (rows corresponding to examples and columns corresponding to the outer splits).

	The `inmat*.mat` file includess:

	- `itrid`: 3D logical array defining the training sets of the inner data splits (rows corresponding to examples, columns corresponding to the outer splits, and 3rd dimension corresponding to the inner splits),
	- `iteid`: 3D logical array defining the test sets of the inner data splits (rows corresponding to examples, columns corresponding to the outer splits, and 3rd dimension corresponding to the inner splits).

3. __Preprocessing__:

	- imputing, z-scoring and deconfounding the data and saving outputs into `preproc*.mat`. There are separate `preproc*.mat` files for each data modality, outer and inner splits. For instance, `preprocx_split_1_subsample_1*.mat` saves resulst of the preprocessing for the first outer and inner split of the data modality $\mathbf{X}$. Depending on the preprocessing strategy, this file can include up to three variables:
	
		- `mu`: numeric array storing the mean values of the features,
		- `sigma`: numeric array storing the standard deviations of the features,
		- `beta`: 2D numeric array storing the regression coefficients from deconfounding (rows corresponding to confounds, columns corresponding to features).  

	- Singular Value Decomposition (SVD) of the data and saving outputs into `*svd*.mat`. There are separate `*svd*.mat` files for each data modality, training and test set of the outer and inner splits. For instance, `tr_svdx_split_1_subsample_1*.mat` saves the SVD results of the training set of the first outer and inner split of data modality $\mathbf{X}$. The `tr_svd*.mat` files include:
		- `VX` (or `VY`): 2D numeric array storing the right singular vectors for data modality $\mathbf{X}$ (or $\mathbf{Y}$) (rows corresponding to examples, columns corresponding to singular vectors),
		- `RX` (or `RY`): 2D numeric array storing the principal components for data modality $\mathbf{X}$ (or $\mathbf{Y}$) (rows corresponding to examples, columns correponding to principal components),
		- `LX` (or `LY`): numeric array storing the squared singular values for data modality $\mathbf{X}$ (or $\mathbf{Y}$).

		The `te_svd*.mat` files include:

		- `RX` (or `RY`): 2D numeric array storing the test data transformed into principal component space for data modality $\mathbf{X}$ (or $\mathbf{Y}$) (rows corresponding to examples, columns corresponding to principal components).

4. __Grid search__: hyperparameter optimization using a grid search and saving outputs into `grid*.mat`. Before cleaning up the intermediate files of the analysis (see [cleanup_files](../mfiles/cleanup_files)), there are separate `grid*.mat` files for each hyperparameter combination and outer split. For instance, `grid_split_1_L1x_1_L1y_1*.mat` saves the results of the first outer split for the hyperparameter combination $c_x=c_y=1$ (for details, see [here](../background/#sparse-pls-spls)). After cleaning up, all grid search results will be compiled into `allgrid*.mat`. This file includes all the metrics that are used for evaluating the CCA/PLS model in the inner splits (for details, see `cfg.machine.metric` [here](../cfg/#machine)), for instance:

	- `correl`: 2D numeric array storing the out-of-sample correlations in the validations sets (rows corresponding to outers splits and hyperparameters, columns corresponding to inner splits),
	- `simwx`: 3D numeric array storing the similarity of $\mathbf{w}_x$ between the traingin sets of the inner splits (rows corresponding to outers splits and hyperparameters, columns corresponding to inner splits, 3rd dimension corresponding to pairwise comparisons),
	- `simwy`: 3D numeric array storing the similarity of $\mathbf{w}_y$ between the training sets of the inner splits (rows corresponding to outers splits and hyperparameters, columns corresponding to inner splits, 3rd dimension corresponding to pairwise comparisons).

5. __Training/testing__:
	
	- setting hyperparameters and saving these into `param*.mat`. This file includes:
		- `param`: a structure array with each structure storing the best (or fixed) hyperparameter combination for a particular outer split.

	- fitting models on optimization sets (i.e., outer split), assessing the model weights on holdout sets and saving outputs into `model*.mat`. This file includes the model weights, $\mathbf{w}_x$ and $\mathbf{w}_y$ and all the metrics that are used for evaluating the CCA/PLS model in the outer splits (for details, see `cfg.machine.metric` [here](../cfg/#machine)), for instance:

		- `wX` and `wY`: 2D numeric arrays storing the models weights (rows corresponding to outer splits, columns corresponding to features),
		- `correl`: numeric array storing the out-of-sample correlations in the holdout sets,
		- `simwx`: 2D numeric array storing the similarity of $\mathbf{w}_x$ between the training sets of the outer splits (rows corresponding to outer splits, columns corresponding to pairwise comparisons),
		- `simwy`: 2D numeric array storing the similarity of $\mathbf{w}_y$ between the training sets of the outer splits (rows corresponding to outer splits, columns corresponding to pairwise comparisons).

6. __Permutation test__: permutation testing and saving outputs into `perm*.mat`. Before cleaning up the intermediate files of the analysis (see [cleanup_files](../mfiles/cleanup_files)), there are separate `perm*.mat` files for each permutation. For instance, `perm_0001*.mat` saves the results of the first permutation. After cleaning up, all permutation results will be compiled into `perm*.mat`. This file includes all the metrics that are used for evaluating the CCA/PLS model in the outer splits (for details, see `cfg.machine.metric` [here](../cfg/#machine)), for instance:
	
	- `correl`: 2D numeric array storing the out-of-sample correlations (rows corresponding to outer splits, columns corresponding to permutations),
	- `simwx`: 3D numeric array storing the similarity of $\mathbf{w}_x$ between the training sets of the outer splits (rows corresponding to outer splits, columns corresponding to permutations, 3rd dimension corresponding to pairwise comparisons),
	- `simwy`: 3D numeric array storing the similarity of $\mathbf{w}_y$ between the training sets of the outer splits (rows corresponding to outer splits, columns corresponding to permutations, 3rd dimension corresponding to pairwise comparisons).

	In addition, `permmat*.mat` file includes:

	- `permid`: cell array with each cell storing a 2D numeric array to define the indexes of the permuted examples for a particular outer split (rows corresponding to examples, columns corresponding to permutations).
 
7. __Saving results__: evaluating significance of results and saving outputs into `res*.mat` as well as the summary of results into `results_table.txt`. The `res*.mat` file includes the `res` structure with the following fields obtained during the analysis:
	
	- `dir`: paths to your project, analysis and main outputs,
	- `frwork`: results oriented details of the framework,
	- `stat`: detailed results of significance testing,
	- `env`: details of the computation environment.

	To get a more detailed description of the fields and subfields of `res`, please see [here](../res).

	Below is an example of a `results_table.txt` of an SPLS analysis:

	| split | correl |  pval  | nfeatx | nfeaty |
	| :---: | :----: | :----: | :----: | :----: |
	|   1   | 0.4355 | 0.0010 |   12   |   9    |
	|   2   | 0.3963 | 0.0010 |   12   |   12   |
	|   3   | 0.3564 | 0.0010 |   33   |   58   |
	|   4   | 0.3517 | 0.0010 |   29   |   4    |
	|   5   | 0.4748 | 0.0010 |   11   |   10   |

	The column headings refer to:

	- `split`: outer data splits,
	- `correl`: out-of-sample correlation in the holdout sets,
	- `pval`: p-value within each data split,
	- `nfeatx` and `nfeaty`: the number of non-zero features in $\mathbf{w}_x$ and $\mathbf{w}_y$, respectively.

	In PCA-RCCA and RCCA analysess, the column headings display the hyperparameter values (i.e., amount of L2-norm regularization or number of principal components).
	
8. __Deflation__: deflation of the data and repeating steps 4-8. for each associative effect. This operation doesn't save any output files.



## Configuration for analysis

All details of a CCA/PLS analysis are defined in a single configuration variable. This variable is a simple MATLAB structure called `cfg`, which includes the following main fields: 

- `dir`: paths to your project, analysis and the outputs of preprocessing,
- `machine`: name and other details of the CCA/PLS model, e.g., hyperparameter settings,
- `frwork`: details of the framework, e.g., number of data splits,
- `defl`: name and details of the deflation method,
- `stat`: details of the statistical inference, e.g., number of permutations,
- `data`: details of the data e.g., dimensionality,
- `env`: details of the computation environment, e.g., local computer or cluster.

Use the `cfg_defaults` function to initialize and update all necessary settings to your `cfg`. To get a more detailed description of the fields and subfields of `cfg`, please see [here](../cfg).

Please find an example of how to set these variables below:

```matlab
% Project folder
cfg.dir.project = '/PATH/TO/PROJECT/';

% Machine settings
cfg.machine.name = 'spls';
cfg.machine.param.crit = 'correl+simwxy';

% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 1;

% Deflation settings
cfg.defl.name = 'pls-modeA';

% Environment settings
cfg.env.comp = 'local';

% Statistical inference settings
cfg.stat.nperm = 1000;
   
% Update cfg with defaults
cfg = cfg_defaults(cfg);
```



## Data

The input data used in a CCA/PLS analysis must be stored in a dedicated folder called `data` within the project directory (see the `demo` folder of the toolkit as an example structure and the details on the Getting Started page [here](../getting_started/#analysis)). 

The $\mathbf{X}$ and $\mathbf{Y}$ matrices should be stored in a specific format inside two `.mat` files:

- `X.mat` including a 2D numeric array called `X`, which stores one of the data modalities,
- `Y.mat` including a 2D numeric array called `Y`, which stores the other data modality.

In both cases, rows correspond to examples (e.g., subjects in a group level analysis) and columns correspond to features (e.g., behavioural measures or brain measures of voxel-wise, connectivity or region-of-interest data).

In addition, you can provide other input data matrices, which should be in a similar format:

- `C.mat` including a 2D numeric array called `C`, which stores the confounding variables of the analysis (rows corresponding to examples, columns corresponding to confounds),
- `EB.mat` including a 2D numeric array called `EB`, which defines the exchangeability block structure of the data (rows corresponding to examples, columns corresponding to the exchangeability blocks).

The `EB` matrix can be used for stratified partitioning of the data and/or using restricted permutations. For instance, you can use this to provide the genetic dependencies of your data (e.g., twins, family structure) or different cohorts (e.g., healthy vs. depressed sample). For details on how to create the `EB` matrix, see [Winkler et al 2015](https://doi.org/10.1016/j.neuroimage.2015.05.092) and the [PALM toolbox](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM).

