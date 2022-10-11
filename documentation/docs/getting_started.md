## Installation

To install the CCA/PLS Toolkit, clone the repository from Github using the following command:

```Bash
git clone https://github.com/mlnl/cca_pls_toolkit
```

After the toolkit is downloaded, go to the folder containing the toolkit and open MATLAB. In general, we advise you to run all commands from this toolkit folder.

To initialize the toolkit, run the following line in the MATLAB command window:

```MATLAB
set_path;
```

## Dependencies

The neuroimaging community has great visualization and other tools, therefore we decided to use some of these available tools for specific purposes in the toolkit. Depending on the analysis and plots you would like to make you will need to download some of the toolboxes below. We recommend two ways of adding toolboxes to your path:

- you can just add the toolboxes to the path in their current location if you already have them on your computer,
- you can add the toolboxes in a dedicated folder (called `external`) inside the toolkit.

For easier management of the dependencies, all toolboxes are stored in a dedicated folder within the toolkit. To create this folder, run the following line in the MATLAB command window:

```MATLAB
mkdir external
```

Importantly, this `external` folder (and its content) is not added to `.gitignore` and thus it is not version controlled by git. On the one side, this is to accomodate the specific needs of users and only to use toolboxes that are essential for their specific analyses and plots. On the other side, this is to avoid that the toolkit gets unnecessarily large due to potentially large external toolboxes.

Here is a complete list of toolboxes that you might need for using the toolkit:

- [PALM](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/PALM) (__Permutation Analysis of Linear Models__, used for permutation testing)
- [SPM](https://www.fil.ion.ucl.ac.uk/spm/software/download/) (__Statistical Parametric Mapping__, used for opening files and reading/writing `.nii` files)
- [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) (used for brain data visualization)
- [AAL](https://www.gin.cnrs.fr/en/tools/aal/) (__Automated Anatomical Labelling__, used for region-of-interest (ROI) analyses)

To know which dependencies you will need for your specific analysis, please see the [Analysis](../analysis/#dependencies) and [Visualization](../visualization/#dependencies) pages.

Below, an example is provided to illustrate how to add toolboxes to the toolkit using PALM. For this, download PALM manually by the provided link, copy the `PALM` folder into your `external` folder, then finally add PALM to the MATLAB path using the following line in the MATLAB command window:

```MATLAB
set_path('PALM');
```



## Toolbox overview

The toolkit consists of two main parts:

1. Analysis
2. Visualization

The reason behind this division is that whereas an analysis can be run on a cluster without a need for a graphical output, the visualization usually takes place on a local computer with a need for a graphical output. Of course, if both the analysis and visualization are done on a local computer, the two can be easily combined as demonstrated in the examples.

### Analysis

The figure below illustrates the inputs and outputs of each analysis.

<p align="center">
   <img src="../figures/overview_analysis.png" width="531" height="71">
</p>


The __main inputs__ of the analysis are:

- `cfg` structure, which is a MATLAB variable created by the user for the configuration of all the analysis settings,
- `X.mat` and `Y.mat` files including the two modalities of input data (i.e., $\mathbf{X}$ and $\mathbf{Y}$ matrices).

Other input files can be also provided, for instance, `C.mat` file including the confounding variables of the analysis and `ÈB.mat` file including the (exchangeability) block structure of the data. 

For details on the `cfg` structure and the input data files, see [Analysis](../analysis).

The __main outputs__ of the analysis are:

- `results_table.txt` including the summary of the results,
- various `.mat` files including, for instance, information about the data splits, the results of hyperparameter optimization and the trained models (for details, see below).

Next, we discuss the folder structure of your analysis and list the specific folders where the main input and output files are stored.

<p align="center">
   <img src="../figures/folders.png" width="331" height="449">
</p>

As illustrated in the figure above, a project consists of a project folder with two subfolders:

- a `data` folder including the input data files,
- a `framework` folder including the results of the analyses with each analysis in a specific framework folder.

We need to create the project and `data` folders manually and place our input data files within the `data` folder (illustrated by a red box in the figure). To generate simulated data, see the [generate_data](../mfiles/generate_data) function.

All the other folders and output files will be created by the toolkit during analysis. Our specific framework folder will be generated by the toolkit based on your CCA/PLS model and framework choice. For instance, an SPLS analysis with a single holdout set (20% of the data) and 10 validation sets (20% of the optimization set) will generate the `spls_holdout1-0.20_subsamp10-0.20` folder. If you want to specify a custom name for this analysis, you can change `cfg.frwork.flag` from its default empty value, which will then append a flag to your specific framwork name. For instance, `cfg.frwork.flag = '_TEST'` will create the `spls_holdout1-0.20_subsamp10-0.20_TEST` folder. 

Each analysis will contain the following output files in the specific framework folder:

- `cfg*.mat` file including the `cfg` structure you created and filled up with other necessary default by [`cfg_defaults`](../mfiles/cfg_defaults), 
- `outmat*.mat` file including the training and test indexes of the outer splits of the data (i.e., optimization and holdout sets), 
- `inmat*.mat` file including the training and test indexes of the inner splits of the data (i.e., inner training and validation sets).

The other output files are stored in specific folders with each folder having one or multiple levels of results, where each level stands for an associative effect (e.g., first associative effect in folder `level1`, second associative effect in folder `level2`):

- `grid` folder including the results of the hyperparameter optimization in `grid*.mat`files,
- `load` folder with a `preproc` folder including the preprocessed (e.g., z-scored) data in `preproc*.mat` files and an `svd` folder including the Singular Value Decomposition (SVD) of the preprocessed data in `*svd*.mat` files (SVD is needed for the computational efficiency of the toolkit),
- `perm` folder including the results of the permutation testing in `perm*.mat` files, 
- `res` folder including the best (or fixed) hyperparameters in `param*.mat` file, the results of the main trained models in `model*.mat` file, additional results in `res*.mat` file and the summary of the results in `results_table.txt` file.

For additional details on the output data files, see [Analysis](../analysis).

### Visualization

The figure below illustrates the inputs and outputs of visualizing the results.

<p align="center">
   <img src="../figures/overview_visualization.png" width="489" height="66">
</p>


The __main inputs__ of the visualization are:

- `res` structure, which is a MATLAB variable loaded from `res*.mat` and appended with settings for visualization,
- `.mat` files either as outputs of the analysis or other files including data (e.g., `mask.mat` including a mask for connectivity data) or other settings for visualization (e.g., `options.mat` including [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) settings), 
- `.csv` files, which are label files including information about the variables in your $\mathbf{X}$ and $\mathbf{Y}$ matrices, 
- `.nv` file, which is a surface mesh file in [BrainNet Viewer](https://www.nitrc.org/projects/bnv/) used as a template to overlay your brain weights on, 
- `.nii` files, which can be an atlas file defining regions of interest (ROI) in the brain or a mask file for voxel-wise structural MRI data.  

The __main outputs__ of the visualization are:

- images of figures, in any requested standard file format, e.g., `.fig`, `.png`, `.svg`, 
- `.csv` files including information about the plotted results (e.g., ordered model weights).

For additional details on the `res` structure and the other input and output data files of visualization, see [Visualization](../visualization).

!!! info 

	We also highly recommend that you go through the defaults of [cfg](../cfg) and [res](../res) so that you understand thoroughly the analysis and visualization settings.

You can find a detailed documentation of each high-level function of the toolkit under the main menu Functions, for instance, see [cfg_defaults](../mfiles/cfg_defaults).

Finally, if you want to get started and run an experiment on your local computer, see [Demo](../full_demo) for a complete analysis and visualization. In addition, we provide three simple examples to generate and analyse [simulated data](../mfiles/demo_simulation), [simulated structural MRI data](../mfiles/demo_smri), and [simulated fMRI data](../mfiles/demo_fmri). 

Next, we briefly discuss how to run an analysis on a cluster.

## Running on a cluster

The toolkit can be run in multiple MATLAB instances, e.g., in a cluster environment. If you use __SGE__ or __SLURM__ scheduling systems, you simply need to send the same analysis to different nodes and the toolkit will take care of the rest. If you use a different scheduling system then a one-line modification of the `cfg_defaults` function is needed to account for your scheduling system and you are ready to go. Feel free to get in touch with us to help you set this up. 

Here is a brief description of what happens under the hood when the toolkit is running on different MATLAB instances. Although MATLAB can load the same `.mat` file from different MATLAB instances, it cannot save to the same `.mat` file . To work around this, the toolkit appends the unique ID of the computing node/job at the end of each `.mat` file (in a local environment, the ID is set to `_1` by default), so even if different jobs are saving the same content simultaneously, they will do it into different files. In addition, there are a handful of wrapper functions to save, search and load these `.mat` files and the following mechanisms are in place to share computational cost:

- jobs save computations to `.mat` files regularly on disc,
- there is a random seed before each time consuming operation in the toolkit (e.g., grid search and permutation testing), hence different jobs will most likely perform different computations,
- jobs can load `.mat` files computed by other jobs,
- jobs regularly check what `.mat` files are available and they only start a new computation if that has not yet been performed by another job,
- if two MATLAB instances are saving the same computation to a `.mat` file then they will write to different files due to their different job ID-s.

You might ask: doesn't this computational strategy create a lot of intermediate and some duplicate files? Indeed, that is the case, however, there is a [`cleanup_files`](../mfiles/cleanup_files) function that allows to remove all the intermediate and duplicate files after your analysis is done. Do not forget to use this as otherwise you might exceed your disc space or have difficulties to move your results around, e.g., from a cluster to a local computer.

An extra benefit of this computational strategy is that in case your analysis is aborted (e.g., you run out of allocated time on a cluster), you can always restart the same analysis and it will catch up with the computations where it was aborted.

