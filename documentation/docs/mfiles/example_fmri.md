<span style="font-size:2em;">__example_fmri__</span>

This is a demo for simulated fMRI connectivity data. We will discuss step
by step how to generate data, run an analysis as well as how to visualize
the results. Copy and paste the code chunks into a function to create 
your own experiment or copy the function from the `examples` folder of 
the toolkit.

##  Generate data
First, we generate the simulated data using the 
[`generate_data`](../generate_data) function of the toolkit. We 
will use 1000 examples and 100 features in both data modalities. We set 
the signal to be sparse with 10% of the features in each modality that 
are relevant to capture the association across modalities. The noise 
parameter of the model is set to 1. For further details on the generative 
model, see [Mihalik et al. 2022](https://doi.org/10.1016/j.bpsc.2022.07.012).

```matlab
%----- Generate data

% Data folder
data_dir = fullfile(fileparts(mfilename('fullpath')), 'example_fmri', 'data');

if ~exist(fullfile(data_dir, 'X.mat'), 'file') || ...
~exist(fullfile(data_dir, 'Y.mat'), 'file')

        % Generate simulated fMRI connectivity data
        [X, Y, wX, wY] = generate_data(1000, 100, 100, 10, 10, 1);
    
        % Save simulated data and true model weights
        if ~isfolder('data_dir')
            mkdir(data_dir);
        end
        save(fullfile(data_dir, 'X.mat'), 'X');
        save(fullfile(data_dir, 'Y.mat'), 'Y');
        save(fullfile(data_dir, 'wX.mat'), 'wX');
        save(fullfile(data_dir, 'wY.mat'), 'wY');
end
```

###  Create mask and label files
As we use simulated fMRI connectivity and behavioural data, we need to 
create mask and label files. Although we recommend to use a 
multi-modal or functional atlas for fMRI connectivity data, for 
simplicity, we will use the AAL atlas to create a subset of 100 
connections of the full connectivity matrix between all AAL regions. For 
our behavioural label file, we will simply use indexes for `Label` and 2 
domains as `Category`.

```matlab
% Add the AAL2 (https://www.gin.cnrs.fr/en/tools/aal/) and the BrainNet
% Viewer (https://www.nitrc.org/projects/bnv/) toolboxes to the path 
set_path('aal', 'brainnet');

% Create AAL labels for full simulated fMRI connectivity data
if ~exist(fullfile(data_dir, 'LabelsX.csv'), 'file')

        BrainNet_GenCoord(which('AAL2.nii'), 'AAL.txt');
        T = readtable('AAL.txt');
        nROI = size(T, 1);
        T.Properties.VariableNames([1:3 6]) = {'X' 'Y' 'Z' 'Index'}; % we will need only these variables
        T.Label = sprintfc('Region-%d', [1:nROI]'); % we need characters for this label
        writetable(T(:,[1:3 6:7]), fullfile(data_dir, 'LabelsX.csv'));
        delete AAL.txt; % clean up
end

% Create mask for subset of 100 connections used as features in input data
if ~exist(fullfile(data_dir, 'mask.mat'), 'file')

        mask = false(nROI);
        full_mask_id = find(tril(true(nROI), -1));
        rand_id = randperm(numel(full_mask_id));
        mask(rand_id(1:100)) = 1;
        save(fullfile(data_dir, 'mask.mat'), 'mask');
end

% Create labels for behavioural data
if ~exist(fullfile(data_dir, 'LabelsY.csv'), 'file')

        T = table([1:100]', [repmat({'Domain 1'}, 50, 1); repmat({'Domain 2'}, 50, 1)], ...
            'VariableNames', {'Label' 'Category'});
        writetable(T, fullfile(data_dir, 'LabelsY.csv'));
end
```

##  Analysis
Now we are ready to set up the analysis. We start by running `set_path` 
to add the necessary paths of the toolkit to your MATLAB path.

```matlab
%----- Analysis

% Set path for analysis
set_path;
```

###  Project folder
Next, we specify the folder to our project. Make sure to specify the 
correct path. We recommend to use a full path, but a relative path should 
also work.

```matlab
% Project folder
cfg.dir.project = fullfile(fileparts(data_dir));
```

###  Machine
Now, we configure the CCA/PLS model we would like to use. We set 
`machine.name` to `cca` and `machine.param.name` to `{'PCAx' 'PCAy'}` for 
[PCA-CCA](../../background/#cca-with-pca-dimensionality-reduction-pca-cca).
For quicker results, we fix the number of principal components. However, in 
general we recommend to determine the optimal number of components based 
on a grid search similar to [demo_smri](../demo_smri).

```matlab
% Machine settings
cfg.machine.name = 'cca';
cfg.machine.param.name = {'PCAx' 'PCAy'};
cfg.machine.param.PCAx = 95;
cfg.machine.param.PCAy = 95;
```

For more information on the CCA/PLS models and the hyperparameter choices,
see [here](../../cfg/#machine).

For further details on the choices of data settings, see [here](../../cfg/#data).

###  Framework
Next, we set the framework name to `holdout` and the number of outer data 
splits to 5 to perform a multiple holdout approach.

```matlab
% Framework settings
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 5;
```

For further details on the framework choices, see [here](../../cfg/#frwork).

###  Environment
Next, we set the computational environment for the toolkit. As our
PCA-CCA implementation is computationally efficient, most of the times we 
can run it locally on our computer.

```matlab
% Environment settings
cfg.env.comp = 'local';
```

For further details on the environmental settings, see [here](../../cfg/#env).

###  Statistical inference
Finally, we need to define how the statistical inference is performed. 
As we use a multiple holdout approach, we have additional options here 
too. We will perform statistical inference in two steps. First, for each 
outer split we do permutation testing based on out-of-sample correlation.
Second, to infer if the associative effect is significant across splits, 
__omnibus hypothesis__ is used, which tests if any outer split is 
significant after adjusting the threshold with Bonferroni correction 
(e.g., p=0.01 in case of 5 splits). This approach is based on 
[Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011).
For quicker results, we set the number of permutations to 100, however, 
we recommend using at least 1000 permutations in general. 

```matlab
% Statistical inference settings
cfg.stat.nperm = 100;
```

For further details on the statistical inference, see [here](../../cfg/#stat).

###  Run Analysis
To run the analysis, we simply update our `cfg` structure to add all 
necessary default values that we did not explicitly define and then run 
the `main` function. After the analysis, we clean up all the duplicate
and intermediate files to save disc space. Note that if you run the
analysis in a cluster environment then you will need to comment out
the last line and run it manually once the analysis is completed as the
`cleanup_files` function does not work in a parallel environment.

```matlab
% Update cfg with defaults
cfg = cfg_defaults(cfg);

% Run analysis
main(cfg);

% Clean up analysis files to save disc space
cleanup_files(cfg);
```

##  Visualization
Now that we have run our first analysis, let's plot some of the results. 
Before we can do any plotting, we need to make sure that we have called 
`set_path('plot')` to add the plotting folder. Then we load the `res`
structure.

In general, we advise you to plot your results on a local computer as it 
is often cumbersome and slow in a cluster environment. If you move your 
results from a cluster to a local computer, you need update the paths in 
your `cfg*.mat` and `res*.mat` files using `update_dir`. This should be 
called once the `res` structure is loaded either manually or by `res_defaults`.

```matlab
%----- Visualization

% Set path for plotting and the BrainNet Viewer toolbox
set_path('plot', 'brainnet');

% Load res
res.dir.frwork = cfg.dir.frwork;
res.frwork.level = 1;
res.gen.selectfile = 'none';
res.gen.weight.flip = 1;
res = res_defaults(res, 'load');
```

###  Plot projections
To plot the data projections (or latent variables) that has been 
learnt by the model, simply run `plot_proj`. As first argument, we need 
to pass the `res` structure. Then, we specify the data modalities as cell 
array and the level of associative effect. In this example, we plot the 
projections of `X` and `Y` for the first associative effect.
We set the fourth input parameter to 'osplit' so that the training and 
test data of the outer split will be used for the plot. The following 
argument defines the outer data split we want to use (in this demo, we 
have only one split). We use the second to last argument to specify the 
colour-coding of the data using the training and test data as groups 
(`teid`). Finally, we specify the low-level function that will plot the 
results. In this case it is `plot_proj_2d_group`. Please see the 
documentation of [plot_proj](../mfiles/plot_proj/) for more details. 

```matlab
% Plot data projections
plot_proj(res, {'X' 'Y'}, res.frwork.level, 'osplit', ...
res.frwork.split.best, 'training+test', '2d_group', 'gen.axes.FontSize', 20, ...
'gen.legend.FontSize', 20, 'gen.legend.Location', 'NorthWest', ...
'proj.scatter.SizeData', 120, 'proj.scatter.MarkerEdgeColor', 'k', ...
'proj.scatter.MarkerFaceColor', [0.3 0.3 0.9; 0.9 0.3 0.3]);
```

![demo_fmri_proj](../figures/example_fmri_proj.png)

###  Plot weights
Plotting model weights heavily depends on the kind of data that has been 
used in the analysis. In case of our fake functional MRI connectivity data, 
we will plot the weights as edges on a glass brain. We will use only the top 20 
most positive and top 20 most negative weights for the figure. We set 
this by first sorting the weights by their sign (`roi.weight.sorttype = sign`)
then taking the top 20 from both ends (`roi.weight.numtop = 20`). In case 
of our fake behavioural data, we will plot the weights as a vertical bar 
plot, again using only the top 20 most positive and top 20 most negative
weights. As first argument, we need to pass the `res` function, in which
we define our custom processing for the weights. Next, we specify the 
data modality and the type of the modality as strings. In this example, we use 
brain connectivity and behavioural data, so we set these to `X` and `conn`
for one and `Y` and `behav` for the other. The following argument 
defines the outer data split we want to use. Finally, we specify 
the low-level function that will plot the results. In this example, it 
will be `plot_weight_brain_edge` and `plot_weight_behav_vert`. Please 
see the documentation of [plot_weight](../mfiles/plot_weight) for more details. 

```matlab
% Plot connectivity weights on glass brain
plot_weight(res, 'X', 'conn', res.frwork.split.best, 'brain_edge', ...
'conn.weight.sorttype', 'sign', 'conn.weight.numtop', 20);
```

![demo_fmri_wx](../figures/example_fmri_weight_brain.png)

```matlab
% Plot behavioural weights as vertical bar plot
plot_weight(res, 'Y', 'behav', res.frwork.split.best, 'behav_vert', ...
'gen.axes.FontSize', 20, 'gen.legend.FontSize', 20, ...
'gen.axes.YLim', [-0.004 0.013], ...
'behav.weight.sorttype', 'sign', 'behav.weight.numtop', 20);
```

![demo_fmri_wy](../figures/example_fmri_weight_bar.png)

