# CCA/PLS Toolkit

This is a __MATLAB__ toolkit to incorporate __Canonical Correlation Analysis (CCA)__, __Partial Least Squares (PLS)__ and their different variants to investigate __multivariate associations__ between multiple modalities of data, e.g., brain imaging and behaviour. These models find pairs of weights (one weight for each data modality) such that the linear combination of the brain and behavioural variables maximise correlation (CCA) or covariance (PLS).

The toolkit includes various options for [__CCA/PLS models__](./background/#ccapls-models) (e.g., standard CCA, standard PLS, regularized CCA, sparse PLS) and [__analysis frameworks__](./background/#analysis-frameworks) (e.g., statistical framework, machine learning framework). It can also perform __Principal Component Analysis (PCA)__ to reduce the dimensionality of the data before entering them into standard CCA analysis (__PCA-CCA__).

Although there are methods to estimate all weights (or __associative effects__) for most CCA/PLS models at once, the toolkit uses an interative solution to be able to optimize the hyperparameters of the model (i.e., number of principal components or regularization parameters) for each associative effect independently. In such iterative solution, the CCA/PLS model estimates one pair of weights (one weight for each data modality) at a time. These associative effects are then removed from the data (by a process called [__deflation__](./background/#deflation-methods)) and the same process is repeated multiple times. The iterative solution also allows to estimate different PLS variants by choosing a specific deflation.

For a short theoretical introduction to the CCA/PLS models, analytic frameworks and deflation methods used in the toolkit, see [Background](./background). For further reading, see:

- Shawe-Taylor J, Cristianini N (2004) [Kernel Methods for Pattern Analysis.](https://kernelmethods.blogs.bristol.ac.uk) Cambridge: Cambridge University Press.

- Rosipal R, Kramer N (2006) [Overview and Recent Advances in Partial Least Squares.](https://doi.org/10.1007/11752790_2) In: Saunders, C., Grobelnik, M.m Gunn, S., Shawe-Taylor, J. (eds) Subspace, Latent Struct Featur Sel. Berlin, Heidelberg: Springer Berlin Heidelberg, pp 34-51. 

- Krishnan A, Williams LJ, McIntosh AR, Abdi H (2011) [Partial Least Squares (PLS) methods for neuroimaging: A tutorial and review.](https://doi.org/10.1016/j.neuroimage.2010.07.034) Neuroimage. 56: 455-475.

- Monteiro JM, Rao A, Shawe-Taylor J & Mourao-Miranda J (2016) [A multiple hold-out framework for Sparse Partial Least Squares.](https://doi.org/10.1016/j.jneumeth.2016.06.011) J. Neurosci. Methods 271, 182-194.

- Mihalik A, Ferreira FS, Moutoussis M et al. (2020) [Multiple Holdouts With Stability: Improving the Generalizability of Machine Learning Analyses of Brain-Behavior Relationships.](https://doi.org/10.1016/j.biopsych.2019.12.001) Biol. Psychiatry 87, 368-376.

- Winkler AM, Renaud O, Smith SM, Nichols TE (2020) [Permutation inference for canonical correlation analysis.](https://doi.org/10.1016/j.neuroimage.2020.117065) Neuroimage 220, 117065

- Mihalik A, Chapman J, Adams RA et al. (2022) [Canonical Correlation Analysis and Partial Least Squares for identifying brain-behaviour associations: a tutorial and a comparative study.](https://doi.org/10.1016/j.bpsc.2022.07.012) Biol. Psychiatry Cogn. Neurosci. Neuroimaging doi: https://doi.org/10.1016/j.bpsc.2022.07.012

Please use the menu on the left to get started with the toolkit.

## Contributors

- [Agoston Mihalik](https://github.com/anaston) - main developer (former at UCL, now at University of Cambridge, UK)
- [Nils Winter](https://github.com/NilsWinter) (University of Münster, Germany)
- [Fabio Ferreira](https://github.com/ferreirafabio80) (former at UCL, now at Imperial College London, UK)
- [James Chapman](https://github.com/jameschapman19) (UCL, UK)
- [Janaina Mourao-Miranda](https://iris.ucl.ac.uk/research/personal/index?upi=JMOUR63) - Principal Investigator (UCL, UK)

Some of the code used in the toolkit was developed by [Joao Monteiro](https://github.com/jmmonteiro) who was a PhD student at UCL (currently a data scientist at Heni). We wish to thank members and collaborators of the [Machine Learning & Neuroimaging Laboratory](http://www.mlnl.cs.ucl.ac.uk) for testing the toolkit and providing invaluable feedback. We would particularly like to acknowledge Eliana Nicolaisen, Cemre Zor, Konstantinos Tsirlis, Taiane Ramos and Richard Nguyen.

Feel free to email us if you have any feedback under [cca-pls-toolkit@cs.ucl.ac.uk](mailto:cca-pls-toolkit@cs.ucl.ac.uk).

## Acknowledgements

The CCA/PLS toolkit was developed at the [__Machine Learning & Neuroimaging Laboratory (MLNL)__](http://www.mlnl.cs.ucl.ac.uk), Centre for Medical Imaging Computing, Computer Science Department, University College London, UK. The development of the toolkit was supported by the Wellcome Trust (grant number WT102845/Z/13/Z).

## License

This project is licensed under the terms of the GNU General Public License v3.0 license.

Copyright © 2022 University College London
