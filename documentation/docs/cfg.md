Here you can find a description of all possible settings of the fields and subfields of `cfg`. First parameter always indicates the default option.

###  dir
Essential paths to your project, framework and processed data. The project folder should include a `data` folder where all the input data are stored.

*   **.project** [*path*]
  
    full path to your project, such as `'PATH/TO/YOUR/PROJECT'`
    
*   **.frwork** [*path*]
  
    full path to your specific framework, such as
    `'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME'`
    
    analysis name is generated from machine name and framework settings, for instance, an SPLS analysis with a single holdout set (20% of the data) and 10 validation sets (20% of the optimization set) and `cfg.frwork.flag = '_TEST'` will generate the `spls_holdout1-0.20_subsamp10-0.20_TEST` folder
    
*   **.load** [*path*]
  
    full path to your processed data, such as 
    `'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/load'`
    
    it possibly includes a `preproc` folder with the results of the preprocessing (e.g., mean, std of the features and the beta coefficients from the deconfounding) and an `svd` folder with the SVD results for computational efficiency of [CCA](../background/#canonical-correlation-analysis-cca), [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) and [RCCA](../background/#regularized-cca-rcca)
    
###  machine
Algorithm to be used, its settings and information about hyperparameter 
optimization. Please make sure that you are familiar with the
hyperparameter settings of the chosen algorithm, e.g. range and scale of
hyperparameter values for grid search or number of PCA components. We strongly encourage to use [RCCA](../background/#regularized-cca-rcca), [SPLS](../background/#sparse-pls-spls) or [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca). For a discussion, see [Mihalik et al. 2022](https://doi.org/10.1016/j.bpsc.2022.07.012).

*   **.name** [*'cca', 'rcca', 'pls', 'spls'*]
  
    name of the algorithm
    
    [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) analysis is defined by `cfg.machine.name = cca` and `cfg.machine.param = {'PCAx' 'PCAy'}`

    [RCCA](../background/#regularized-cca-rcca) finds a smooth solution between CCA and PLS using L2-norm regularization (see `cfg.machine.param.L2x` and `cfg.machine.param.L2y` below)
    
*   **.metric** [*cell array*]
  
    metrics to evaluate the CCA/PLS algorithm

    note that each metric provided here will be saved on disc during hyperparameter optimization, training the main model and permutation testing, so they can be used for diagnostics later either they are used as criterion to evaluate a model or not

    options for each cell: `'trcorrel'` (in-sample correlation), `'correl'` (out-of-sample correlation measuring the generalizability of the model), `'trcovar'` (in-sample covariance), `'covar'` (out-of-sample covariance measuring the generalizability of the model), `'trexvarx'` (in-sample percent explained variance by $\mathbf{w}_x$), `'exvarx'` (out-of-sample percent explained variance by $\mathbf{w}_x$),  `'trexvary'` (in-sample percent explained variance by $\mathbf{w}_y$), `'exvary'` (out-of-sample percent explained variance by $\mathbf{w}_y$), `'simwx'` (similarity of $\mathbf{w}_x$ across training sets measuring the stability of the model), `'simwy'` (similarity of $\mathbf{w}_y$ across training sets measuring the stability of the model), `'unsuc'` (number of unsuccessful convergence in SPLS, should be a small number in general, for details, see `cfg.machine.spls.maxiter`)
    
*   **.param.crit** [*'correl', 'correl+simwxy'*]
  
    criterion to select the best hyperparameter

    in general, we recommend using `'correl'` (measuring the generalizability of the model) or `'correl+simwxy'` (measuring the stability and the generalizability of the model) for [SPLS](../background/#sparse-pls-spls)
    
    `'correl+simwxy'` calculates a 2-dimensional Euclidean distance from {1,1} based on out-of-sample correlation and the average similarity of $\mathbf{w}_x$ and $\mathbf{w}_y$ (i.e., it measures the deviation from perfect out-of-sample generalizability and perfect model stability, for details, see [Mihalik et al. 2020](https://doi.org/10.1016/j.biopsych.2019.12.001))
    
*   **.param.name** [*cell array*]
  
    name of the hyperparameters in the CCA/PLS model

    in each name, the first characters refers to the type of hyperparameter and the last character refers to the data modality, e.g., L1x for L1 regularization of $\mathbf{w}_x$
    
    potential settings: `{'L1x', 'L1y'}` for L1 regularization in [SPLS](../background/#sparse-pls-spls), `{'L2x', 'L2y'}` for L2 regularization in [RCCA](../background/#regularized-cca-rcca), `{'PCAx', 'PCAy'}` for number of PCA components in [PCA_CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca)

    an alternative to setting the number of PCA components is setting the explained variance by the PCA components using `{'VARx', 'VARy'}` in [PCA_CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca)
    
*   **.param.type** [*'factorial', 'matched'*]
  
    defines whether the grid search of hyperparameters should be based on a factorial combination of all hyperparameter values in the two data modalities (i.e., 100 combinations for 10 hyperparameter values in both data modalities) or the combination of hyperparameter values based on matching their indices (i.e., first index in one data modality is paired with first index in the other data modality)
    
*   **.param.L1x, .param.L1y** [*int or numeric array*]
  
    amount of L1 regularization for $\mathbf{w}_x$ and $\mathbf{w}_y$ (see $c_x$ and $c_y$ in [SPLS](../background/#sparse-pls-spls))
    
    if not provided, the function generates a logarithmically scaled numeric array based on the following equation, for instance, for $\mathbf{w}_x$:
$$
c_x = logspace(a, b, n)
$$
where $c_x$ is the hyperparameter (i.e., `cfg.machine.param.L1x`), $a$ is the start of the logarithmic range (i.e., `log(cfg.machine.param.rangeL1x(1))`), $b$ is the end of the logarithmic range (i.e., `log(cfg.machine.param.rangeL1x(2))`) and $n$ is the number of values between $a$ and $b$ (i.e., `cfg.machine.param.nL1x`)
    
*   **.param.rangeL1x, .param.rangeL1y** [*numeric array*]
  
    range of the hyperparameters for L1 regularization of $\mathbf{w}_x$ and $\mathbf{w}_y$
    
    the default range is between 1 and the square root of the number of features

    if a given value is outside of this default range then L1 regularization is not active and [PLS](../background/#partial-least-squares-pls) is used instead of [SPLS](../background/#sparse-pls-spls)
    
*   **.param.nL1x, .param.nL1y** [*int --> 10*]
  
    number of values in the range of hyperparameters for L1 regularization of $\mathbf{w}_x$ and $\mathbf{w}_y$ (for details, see `cfg.machine.param.L1x` and `cfg.machine.param.L1y` above)
    
*   **.param.L2x, .param.L2y** [*int*]
  
    amount of L2 regularization for $\mathbf{w}_x$ and $\mathbf{w}_y$ (see $c_x$ and $c_y$ in [RCCA](../background/#regularized-cca-rcca))
    
    [RCCA](../background/#regularized-cca-rcca) is equivalent to [CCA](../background/#canonical-correlation-analysis-cca) if both values are set to $0$
    
    [RCCA](../background/#regularized-cca-rcca) is equivalent to [PLS](../background/#partial-least-squares-pls) if both values are set to $1$
    
    if not provided, the function generates a logarithmically scaled numeric array based on the following equation, for instance, for $\mathbf{w}_x$:
$$
c_x = 1 - logspace(a, b, n)
$$
where $c_x$ is the hyperparameter (i.e., `cfg.machine.param.L2x`), $a$ is the start of the logarithmic range (i.e., `-log(cfg.machine.param.rangeL2x(1))`), $b$ is the end of the logarithmic range (i.e, `-log(cfg.machine.param.rangeL2x(2))`) and $n$ is the number of values between $a$ and $b$ (i.e., `cfg.machine.param.nL2x`) 

*   **.param.rangeL2x, .param.rangeL2y** [*numeric array*]
  
    range of hyperparameters for L2 regularization of $\mathbf{w}_x$ and $\mathbf{w}_y$

    the default range is between 1 and the squared number of features
    
*   **.param.nL2x, .param.nL2y** [*int*]
  
    number of values in the range of hyperparameters for L2 regularization of $\mathbf{w}_x$ and $\mathbf{w}_y$ (for details, see `cfg.machine.param.L2x` and `cfg.machine.param.L2y` above)
    
*   **.param.PCAx, .param.PCAy** [*int*]
  
    number of principal components kept during the SVD step of [CCA](../background/#canonical-correlation-analysis-cca), [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) or [RCCA](../background/#regularized-cca-rcca)

    if not provided, the function generates a logarithmically scaled numeric array based on the following equation, for instance, for $\mathbf{X}$:
$$
c_x = logspace(a, b, n)
$$
where $c_x$ is the hyperparameter (i.e., `cfg.machine.param.PCAx`), $a$ is the start of the logarithmic range (i.e., `log(cfg.machine.param.rangePCAx(1))`), $b$ is the end of the logarithmic range (i.e, `log(cfg.machine.param.rangePCAx(2))`) and $n$ is the number of values between $a$ and $b$ (i.e., `cfg.machine.param.nPCAx`)

*   **.param.rangePCAx, .param.rangePCAy** [*numeric array*]

    range of hyperparameters for number of principal components of data $\mathbf{X}$ and $\mathbf{Y}$

    the default range is between 1 and the rank of the training data

*   **.param.nPCAx, .param.nPCAy** [*int*]

    number of values in the range of hyperparameters for principal components of $\mathbf{X}$ and $\mathbf{Y}$ (for details, see `cfg.machine.param.PCAx` and `cfg.machine.param.PCAy` above)
    
*   **.param.VARx, .param.VARy** [*int*]
  
    variance of data kept in the principal components during the SVD step of [CCA](../background/#canonical-correlation-analysis-cca), [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) or [RCCA](../background/#regularized-cca-rcca) 
    
    note that if variance is not sufficiently large, only very few (even 0 or 1) variables might be only kept
 
    if not provided, the function generates a linearly scaled numeric array based on the following equation, for instance, for $\mathbf{X}$:
$$
c_x = linspace(a, b, n)
$$
where $c_x$ is the hyperparameter (i.e., `cfg.machine.param.VARx`), $a$ is the start of the linear range (i.e., `cfg.machine.param.rangeVARx(1))`), $b$ is the end of the linear range (i.e, `cfg.machine.param.rangeVARx(2))`) and $n$ is the number of values between $a$ and $b$ (i.e., `cfg.machine.param.nVARx`)
    
*   **.param.rangeVARx, .param.rangeVARy** [*numeric array*]

    range of hyperparameters for explained variance in principal components of data $\mathbf{X}$ and $\mathbf{Y}$

    the default range is between 0.1 and 1

*   **.param.nVARx, .param.nVARy** [*int*]

    number of values in the range of hyperparameters for explained variance in principal components of $\mathbf{X}$ and $\mathbf{Y}$ (for details, see `cfg.machine.param.VARx` and `cfg.machine.param.VARy` above)
    
*   **.svd.tol** [*int --> 1e-10*]
  
    eigenvalues smaller than tolerance are removed during the SVD step of [CCA](../background/#canonical-correlation-analysis-cca), [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) or [RCCA](../background/#regularized-cca-rcca)
    
*   **.svd.varx** [*float*]
  
    variance of $\mathbf{X}$ kept during the SVD step of [CCA](../background/#canonical-correlation-analysis-cca), [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) or [RCCA](../background/#regularized-cca-rcca)

    default is 1 for [CCA](../background/#canonical-correlation-analysis-cca) and 0.99 for [RCCA](../background/#regularized-cca-rcca) 

    note that if variance is not sufficiently large, only very few (even 0 or 1) variables might be only kept

*   **.svd.vary** [*float*]
  
    variance of $\mathbf{Y}$ kept during the SVD step of [CCA](../background/#canonical-correlation-analysis-cca), [PCA-CCA](../background/#cca-with-pca-dimensionality-reduction-pca-cca) or [RCCA](../background/#regularized-cca-rcca)

    default is 1 for [CCA](../background/#canonical-correlation-analysis-cca) and 0.99 for [RCCA](../background/#regularized-cca-rcca)

    note that if variance is not sufficiently large, only very few (even 0 or 1) variables might be only kept, i.e., for models with 1 output variable `cfg.machine.svd.vary = 1` should be used

*   **.spls.tol** [*int --> 1e-5*]
  
    tolerance during SPLS convergence (for details, see [Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011))
    
*   **.spls.maxiter** [*int --> 100*]
  
    maximum number of iterations during SPLS convergence (for details, see [Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011))

*   **.simw** [*char*]

    defines the type of similarity measure to assess the stability of model weights across splits

    `'correlation-Pearson'` calculates absolute Pearson correlation between each pair of weights

    `'overlap-corrected'` and `'overlap-uncorrected'` calculate the overlap between each pair of sparse weigths in [SPLS](../background/#sparse-pls-spls) (for details, see [Baldassarre et al. 2017](https://www.frontiersin.org/articles/10.3389/fnins.2017.00062/full), [Mihalik et al. 2020](https://doi.org/10.1016/j.biopsych.2019.12.001)).

###  frwork
Details of framework with two main approaches. In the predictive (or machine learning) framework, the model is fitted on a training set and evaluated on a holdout set, and the statistical inference is based on out-of-sample correlation. In the descriptive framework, the model is fitted on the entire data, thus the statistical inference is based on in-sample correlation. The default values will change depending on the type of the framework. For further details on frameworks, see [Analysis frameworks](../background/#analysis-frameworks) and [Mihalik et al. 2022](https://doi.org/10.1016/j.bpsc.2022.07.012).

*   **.name** [*'holdout', 'permutation'*]
  
    type of the framework

    note that `permutation` refers for the descriptive framework, even though both frameworks use permutation testing for statistical inference
    
*   **.flag** [*char*]
  
    a short name to be appended to your analysis name which will then 
    define the framework folder, see `cfg.dir.frwork`
    
*   **.nlevel** [*int*]

    number of associative effects to be searched for

*   **.split.nout** [*int*]
  
    number of outer splits/folds
    
*   **.split.propout** [*float --> 0.2*]
  
    proportion of holdout/test set in `'holdout'` framework
    
    higher value is recommended for samples n<500 (e.g., 0.2-0.5), and 
    lower value (e.g., 0.1) should be sufficient for samples n>1000 
    
    set to 0 in `'permutation'` framework
    
*   **.split.nin** [*int*]
  
    number of inner splits/folds
    
*   **.split.propin** [*float --> 0.2*]
  
    proportion of validation set in `'holdout'` framework
    
###  defl
Deflation methods and strategies (for an introduction, see [here](../background/#deflation-methods) in the Background page). In case we use multiple outer splits of the data, it is of interest which split to use as the basis for deflation.
At the moment, we support the strategy of using the weights of the best data split (e.g., based on highest out-of-sample correlation) and deflate all other splits with it based on [Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011).

*   **.name** [*'generalized', 'pls-projection', 'pls-modeA', 'pls-regression'*]
  
    type of deflation
    
*   **.crit** [*'correl', 'pval+correl', 'correl+simwxy', 'correl+simwx+simwy', 'none'*]
  
    criterion to define best (i.e. most representative) data split to be 
    used for deflation
    
    if 'none' set then each split is deflated by itself (i.e. they are 
    treated independently) 
    
###  stat
Statistical inference. Testing the generalizability of the models (i.e., using out-of-sample correlations) is one of our key recommendations. Furthermore, we advise to check the robustness (i.e., how many data splits are significant) and the stability (i.e., similarity of the weights) of the model instead of purely relying on a p-value. In the multiple-holdout framework, we support only statistical inference based on omnibus hypothesis proposed by [Monteiro et al
2016](https://doi.org/10.1016/j.jneumeth.2016.06.011).

*   **.nperm** [*int*]
  
    number of permutations

*   **.alpha** [*float --> 0.05*]

    threshold for significance testing

    note, that in the omnibus hypothesis approach, the threshold is adjusted by Bonferroni correction using the number of holdout sets 
    
*   **.crit** [*'correl', 'covar'*]
  
    statistical inference within splits (i.e., one permutation test for each 
    data split) based on given criterion
    
*   **.perm** [*'train', 'train+test'*]

    defines whether only the training examples or both the training and test examples are shuffled during permutation

    note, that the shuffling is performed within training and test sets, i.e., there is no leakage from training to test data    

###  data
Details of the data and its properties including modalities, dimensionality and exchangeability block structure. The preprocessing strategy and the 
filenames with full path are also defined here. We highlight that when the data comes in a preprocessed format (e.g., imputed, z-scored), inference using holdout framework might be invalid (i.e., p-values inflated).

*   **.block** [*boolean*]
  
    defines if there is a block structure in the data, i.e., examples are not 
    independent of each other 
    
*   **.nsubj** [*int*]
  
    number of subjects/examples
    
*   **.conf** [*boolean --> False*]

    defines if at least one of the data modalities should be deconfounded

*   **.preproc** [*cell array --> {'impute', 'zscore'}*]
  
    data preprocessing strategy including missing value imputation (`'impute'`),
    z-scoring (`'zscore'`) and potentially deconfounding (`'deconf'`)

    `'deconf'` is automatically added if `cfg.data.conf` is True
    
    of note, data preprocessing is calculated on training data and applied
    to test data if 'holdout' framework used 
    
*   **.mod** [*cell array*]
  
    data modalaties to be used (e.g.` {'X' 'Y'}`)
    
*   **.X.fname, .Y.fname, .C.fname** [*filepath --> 'X.mat', 'Y.mat', 'C.mat'*]
  
    filename with full path to data $\mathbf{X}$, $\mathbf{Y}$, $\mathbf{C}$
    
*   **.X.impute, .Y.impute, .C.impute** [*'median'*]
  
    strategy to impute missing values
    
*   **.X.deconf, .Y.deconf** [*standard, none*]
  
    type of deconfounding

    `'standard'` refers to regressing out confounds (i.e., removing confounds using regression)
    
    `'none'` could be used if deconfounding is needed for the other modality
    but not the one where 'none' is set
    
*   **.X.nfeat, .Y.nfeat** [*int*]
  
    number of features/variables in data $\mathbf{X}$, $\mathbf{Y}$

*   **.EB.split** [*int or numeric array*]
  
    indexes of columns in EB matrix to use for defining exchangeability
    blocks for data partitioning
    
    if multi-level blocks are provided, most likely you need to provide 2 
    columns here as e.g., no cross-over across different family types 
    (column 2) but shuffling across families (column 3) within same family 
    type are allowed, in other words, families should be in the same data
    split (training or test)
    
*   **.EB.stat** [*int or numeric array*]
  
    indexes of columns in EB matrix to use for defining exchangeability
    blocks for restricted permutations

###  env
Computation environment can be either local or cluster. In the latter 
case, we currently support __SGE__ or __SLURM__ scheduling systems (for details, see [here](../getting_started/#running-on-a-cluster) in the Getting Started page).

*   **.comp** [*'local', 'cluster'*]
  
    computation environment
    
*   **.commit** [*char*]
  
    SHA hash of the latest commit in git (i.e., toolkit vesion) for
    reproducibility
    
*   **.OS** [*'mac', 'unix', 'pc'*]
  
    operating system (OS)
    
    this information is used when transferring files between OS and
    updating paths (see `cfg.dir` fields and [`update_dir`](../mfiles/update_dir) function)
    
*   **.fileend** [*char --> '_1'*]
  
    suffix at the end of each file saved in the framework folder whilst
    running the experiment on a cluster
    
    for file storage efficiency and easier data transfer, we suggest to use the [`cleanup_files`](../mfiles/cleanup_files) function after an experiment is completed to delete all intermediate and duplicate files
    
*   **.save.compression** [*boolean --> 1*]
  
    defines if files are saved with or without compression
    
    of note, loading an uncompressed file can be faster for very large data
    files

*   **.verbose** [*int --> 2*]

    level of verbosity to display information in the command line during the experiment

    `1`: detailed information with including elapsed time between time sensitive operations
    
    `2`: detailed information without elapsed time
    
    `3`: minimal information

*   **.seed.split**, [*char --> 'default'* or *int*]

    seed before random data splitting

    value is passed as input to MATLAB's `rng` function

*   **.seed.model**, [*int* or *char*]

    seed before training models in random order during hyperparameter optimization

    the default value is taken from `cfg.env.fileend` (converted to int)

    value is passed as input to MATLAB's `rng` function

*   **.seed.perm**, [*char --> 'default'* or *int*]

    seed before training models in random order during permutation testing

    value is passed as input to MATLAB's `rng` function
