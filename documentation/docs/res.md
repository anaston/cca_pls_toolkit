Here you can find a description of all possible settings of the fields and subfields of `res`. First parameter always indicates the default option.

## Analysis

These fields are obtained during analysis and saved into `res*.mat`. Some of the fields are inherited from `cfg`. 

###  dir
Essential paths to your project, framework (subfields inherited from 
`cfg`, see [here](../cfg/#dir)) and the output folders of the
experiment such as grid search, permutations and main results.

*   **.project** [*path*]
  
    full path to your project, such as `'PATH/TO/YOUR/PROJECT'`
    
*   **.frwork** [*path*]
  
    full path to your framework, such as
    `'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME'`
    
*   **.grid** [*path*]
  
    full path to your grid search results, such as
    `'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/grid/level<id>'`
    
*   **.perm** [*path*]
  
    full path to your permutation testing results, such as
    `'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/perm/level<id>'`
    
*   **.res** [*path*]
  
    full path to your main results, such as
    `'PATH/TO/YOUR/PROJECT/framework/ANALYSIS_NAME/grid/level<id>'`
    
###  frwork
Results oriented details of framework with different subfields as in `cfg`.

*   **.level** [*int*]
  
    level of the multivariate associative effect in the iterative
    calculation process

*   **.nlevel** [*int*]

    maximum number of levels of the multivariate associative effect

    by default, the maximum number is limited by the rank of data $\mathbf{X}$ and $\mathbf{Y}$
    
*   **.split.all** [*int or numeric array*]
  
    all splits at the current level
    
*   **.split.nall** [*int*]
  
    number of all splits at the current level
    
*   **.split.best**
  
    best split based on the criterion defined by `cfg.defl.crit` (for details,
    see [here](../cfg/#defl))
    
###  stat
Results of statistical inference with some subfields inherited from `cfg`.
For further details on the type of statistical inferences, see [here](../background/#analysis-frameworks) in the Background page.

*   **.nperm** [*int*]
  
    number of permutations
    
*   **.pval** [*int or numeric array*]
  
    uncorrected p-values of the statistical inference within splits (one 
    p-value per split)
    
    of note, in case of _omnibus_ hypothesis the associative effect is
    significant if any of the p-values is smaller than the adjusted significance threshold
    
*   **.sig** [*boolean*]
  
    defines whether the associative effect is significant across splits
    
###  env
Computation environment with all subfields inherited from `cfg`. For further details see [here](../cfg/#env).

*   **.fileend** [*char --> '_1'*]
    
    suffix at the end of each file saved in the framework folder whilst running the experiment on a cluster

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

    the default value is taken from `res.env.fileend` (converted to int)

    value is passed as input to MATLAB's `rng` function

*   **.seed.perm**, [*char --> 'default'* or *int*]

    seed before training models in random order during permutation testing

    value is passed as input to MATLAB's `rng` function    

##  Visualization

These fields are for visualization. They are added to `res` only temporarily and they are not saved to `res*.mat`.

###  gen
General options for plotting. We recommend `'interactive'` file selection when new to plotting results to fully understand what files are needed for the specific plots. Later, especially when wishing to automatize plots, it might be convenient to use `'none'` file selection to avoid the interactive pop-up windows and the files can be provided by overwriting defaults if needed.

*   **.selectfile** [*'none', 'interactive'*]
  
    file selection using a wrapper function over the select_file function
    of [SPM](https://www.fil.ion.ucl.ac.uk/spm/software/download/)
    
*   **.weight.flip** [*boolean --> false*]
  
    defines whether wa want to flip the weights, i.e., change their sign
    
*   **.weight.type** [*'weight', 'correlation'*]
  
    defines the type of model weight we want to interpret
    
    `'weight'` refers to the true model weights read from `model*.mat`
    
    `'correlation'` refers to _loadings_ (PLS literature) or _structure correlations_ (CCA literature), i.e., the correlation between the input variables and the latent variables/projections
    
*   **.figure.ext** [*char --> '.png'*]

    defines the file extensions when saving a figure to disc

*   **.figure.Position** [*numeric array ---> []*]

    defines the position of the MATLAB figure, specified as a vector of the form [left bottom width height], for details, see MATLAB's [Figure Properties](https://uk.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html)
    
    by default, we use MATLAB's default settings

*   **.axes.Position** [*numeric array ---> []*]

    defines the position of the MATLAB axes, specified as a vector of the form [left bottom width height], for details, see MATLAB's [Axes Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)

    by default, we use MATLAB's default settings
 
*   **.axes.XLim, .axes.YLim** [*numeric array ---> []*]

    defines the x- and y-axis limits, specified as a two-element vector of the form [ymin ymax], for details, see MATLAB's [Axes Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)
    
    by default, we use MATLAB's automatic axis adjustment

*   **.axes.FontSize** [*int ---> []*]

    defines the fontsize for the axes in the figure, for details, see MATLAB's [Axes Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)
    
    by default, we use MATLAB's default settings

*   **.axes.FontName** [*char ---> []*]

    defines the fontname for the axes in the figure, for details, see MATLAB's [Axes Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)
    
    by default, we use MATLAB's default settings

*   **.axes.XTick, .axes.YTick** [*int ---> []*]

    defines the position of ticks on the x- and y-axis, for details, see MATLAB's [Axes Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)

    by default, we use MATLAB's default settings

*   **.axes.XScale, .axes.YScale** [*int ---> []*]

    defines the scale on the x- and y-axis, for details, see MATLAB's [Axes Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)

    by default, we use MATLAB's default settings

*   **.legend.FontSize** [*int ---> []*]

    defines the fontsize for the legend in the figure, for details, see MATLAB's [Legend Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.illustration.legend-properties.html)
    
    by default, we use MATLAB's default settings

*   **.legend.Location** [*char ---> []*]

    defines the location of the legend in the figure, for details, see MATLAB's [Legend Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.illustration.legend-properties.html)

###  data
Subfields inherited from `cfg`. For further details see [here](../cfg/#data).

*   **.X.fname, .Y.fname, .C.fname** [*filepath --> 'X.mat', 'Y.mat', 'C.mat'*]

    filename with full path to data $\mathbf{X}$, $\mathbf{Y}$, $\mathbf{C}$
 
###  param
Options for plotting hyperparameter optimization results from grid 
search. For the plotting function, see [plot_paropt](../plot_paropt).

*   **.view** [*numeric array ---> [-130 20]*]
  
    viewing angle of 3D plot to help assessment of global maximum
    
###  proj
Options for plotting projections of data (i.e., latent variables).
For the plotting function, see [`plot_proj`](../mfiles/plot_proj).

*   **.xlabel, .ylabel** [*char --> 'Brain latent variable', 'Behavioural latent variable'*]
  
    label for x- and y-axis

*   **.scatter.SizeData** [*int --> []*]

    marker size in scatter plot, for details see MATLAB's [Scatter Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.scatter-properties.html)

*   **.scatter.MarkerFaceColor** [*numeric array --> []*]

    face colour of the marker in scatter plot, specified as a vector of 3 RGB elements, for details see MATLAB's [Scatter Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.scatter-properties.html)

    note, that multiple RGB values can be provided if we want to colour-code multiple groups

*   **.scatter.MarkerEdgeColor** [*char --> []*]

    edge color of the marker in scatter plot, for details see MATLAB's [Scatter Properties](https://uk.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.scatter-properties.html)

*   **.lsline** [*'off', 'on'*]

    defines whether a least-squares line is overlayed on the scatter plot

*   **.file.label** [*filepath --> 'LabelsY.csv'*]
  
    label file with full path for additional colormap/group information
    
    label file and data file (see below) should be in correspondence, i.e., row _i_ in label file (without column heading) should correspond to column _i_ in data file
    
*   **.file.data** [*filepath --> 'Y.mat'*]
  
    data file with full path for additional colormap/group information
    
    label file and data file (see above) should be in correspondence, i.e., row _i_ in label file (without column heading) should correspond to column _i_ in data file
    
*   **.flip** [*boolean --> false*]
  
    defines whether wa want to flip the sign of projections
    
*   **.multi_level** [*boolean --> 0*]
  
    defines whether we want a [simple plot](../mfiles/plot_proj/#simple-plots) or a [multi-level plot](../mfiles/plot_proj/#multi-level-plots)
    
###  behav
Options for plotting behavioural weights. For the plotting function, see [`plot_weight`](../mfiles/plot_weight).

*   **.xlabel, .ylabel** [*char --> 'Behavioural variables', 'Weight'*]

    label for x- and y-axis

*   **.weight.filtzero** [*boolean --> 1*]
  
    post-process weights by removing weights with zero values
    
*   **.weight.numtop** [*int --> Inf*]
  
    post-process weights by selecting the top weights
    
    `'Inf'` refers to including all weights
    
*   **.weight.sorttype** [*'sign', '', 'abs'*]
  
    post-process weights by sorting them in descending order
    
    `'sign'` sorts both positive and negative weights in descending order 
    (i.e., as if they were two independent lists)
    
    `'abs'` sorts weights based on absolute value
    
    `''` refers to no sorting

*   **.weight.norm** [*'none', 'minmax', 'std', 'zscore'*]
  
    post-process weights by normalizing them

    `'none'` refers to no normalization

    `'minmax'` refers to normalization by absolute maximum value

    `'std'` refers to normalization by standard deviation

    `'zscore'` refers to normalization by zscore
    
*   **.file.label** [*filepath --> 'LabelsY.csv'*]
  
    label file with full path for data $\mathbf{Y}$
    
*   **.label.maxchar** [*int --> Inf*]
  
    maximum number of characters for label names in figure
    
    of note, use it when some of the labels are too long to display on the
    figure setting it to e.g., 50
    
###  conn
Options for plotting connectivity data e.g., from resting-state fMRI. For 
the general plotting function, see [`plot_weight`](../mfiles/plot_weight).

*   **.file.mask** [*filepath --> 'mask.mat'*]
  
    mask file with full path for connectivity data
    
    `mask` variable in the `mask.mat` file is a 2D logical array specifying the connections that are included in the brain data 
    
*   **.weight.filtzero** [*boolean --> 1*]
  
    post-process weights by removing weights with zero values
    
*   **.weight.numtop** [*int --> Inf*]
  
    post-process weights by selecting the top weights
    
    `'Inf'` refers to including all weights
    
*   **.weight.sorttype** [*'sign', '', 'abs'*]

    post-process weights by sorting them in descending order

    `'sign'` sorts both positive and negative weights in descending order
    (i.e., as if they were two independent lists)

    `'abs'` sorts weights based on absolute value

    `''` refers to no sorting

*   **.weight.type** [*'auto', 'strength'*]
  
    post-process weights by multiplying them by the sign of the population
    mean in the original data
    
    `'auto'` does no post-processing
    
    `'strength'` does post-processing
    
*   **.weight.sign** [*'all', 'positive', 'negative'*]
  
    post-process weights by selecting a subset of them (e.g., with positive
    or negative sign)
    
    `'all'` does no post-processing
    
*   **.module.disp** [*boolean --> 0*]
  
    defines whether to display module weights in command line
    
*   **.module.type** [*'average', 'sum'*]
  
    calculate the average or sum of weights within/between modules
    
*   **.module.norm** [*'none', 'global', 'max'*]
  
    normalize module weights
    
    `'none'` does no normalization
    
*   **.file.label** [*filepath --> 'LabelsX.csv'*]
  
    label file with full path for connectivity data
    
###  vbm
Options for plotting voxel-wise structural MRI data. For the general plotting function, see [`plot_weight`](../mfiles/plot_weight).

*   **.weight.numtop** [*int --> Inf*]

    post-process weights by selecting the top weights

    `'Inf'` refers to including all weights

*   **.weight.sorttype** [*'sign', '', 'abs'*]

    post-process weights by sorting them in descending order

    `'sign'` sorts both positive and negative weights in descending order
    (i.e., as if they were two independent lists)

    `'abs'` sorts weights based on absolute value

    `''` refers to no sorting

*   **.weight.norm** [*'none', 'minmax', 'std', 'zscore'*]

    post-process weights by normalizing them

    `'none'` refers to no normalization

    `'minmax'` refers to normalization by absolute maximum value

    `'std'` refers to normalization by standard deviation

    `'zscore'` refers to normalization by zscore

*   **.file.mask** [*filepath --> 'mask.nii'*]
  
    mask file with full path for VBM data
    
    `.nii` file includes a 3D image with booleans for the voxels that are included in the brain
    
*   **.file.MNI** [*filepath --> 'T1_1mm_brain.nii'*]
  
    source image with full path for normalization to MNI space
    
*   **.transM** [*numeric array --> eye(4)*]
  
    rigid body transformation matrix to reorient the weight image to MNI 
    space before normalization occurs
    
###  roi
Options for plotting region-wise structural MRI data. For the general plotting function, see [`plot_weight`](../mfiles/plot_weight).

*   **.weight.filtzero** [*boolean --> 1*]

    post-process weights by removing weights with zero values

*   **.weight.numtop** [*int --> Inf*]

    post-process weights by selecting the top weights

    `'Inf'` refers to including all weights

*   **.weight.sorttype** [*'sign', '', 'abs'*]

    post-process weights by sorting them in descending order

    `'sign'` sorts both positive and negative weights in descending order
    (i.e., as if they were two independent lists)

    `'abs'` sorts weights based on absolute value

    `''` refers to no sorting

*   **.out** [*numeric array --> []*]
  
    indexes of ROIs to remove from displaying on the figure
    
*   **.file.label** [*filepath --> 'LabelsX.csv'*]
  
    label file with full path for ROI data
    
###  simul
Options for plotting modality independent (e.g., simulated) weights. For the general plotting function, see [`plot_weight`](../mfiles/plot_weight).

*   **.xlabel, .ylabel** [*char --> 'Variables', 'Weight'*]

    label for x- and y-axis

*   **.weight.filtzero** [*boolean --> 1*]

    post-process weights by removing weights with zero values

*   **.weight.numtop** [*int --> Inf*]

    post-process weights by selecting the top weights

    `'Inf'` refers to including all weights

*   **.weight.sorttype** [*'sign', '', 'abs'*]

    post-process weights by sorting them in descending order

    `'sign'` sorts both positive and negative weights in descending order
    (i.e., as if they were two independent lists)

    `'abs'` sorts weights based on absolute value

    `''` refers to no sorting

*   **.weight.norm** [*'none', 'minmax', 'std', 'zscore'*]

    post-process weights by normalizing them

    `'none'` refers to no normalization

    `'minmax'` refers to normalization by absolute maximum value

    `'std'` refers to normalization by standard deviation

    `'zscore'` refers to normalization by zscore

*   **.weight.file.X,.weight.file.Y** [*filepath*]
  
    full path to the true weight files, so that the true weights can be overlaid on the stem plot

###  brainnet
Settings for [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) for 
automatic plotting of brain weights on a glass brain and saving it as 
bitmap image in file.

*   **.file.surf** [*filepath --> 'BrainMesh_ICBM152.nv'*]
  
    brain mesh (glass brain) file
    
    of note, full path is not necessary if file is in path or BrainNet Viewer is in `external` folder
    
*   **.file.options** [*filepath --> 'options.mat'*]
  
    options file with full path for BrainNet configuration
    

