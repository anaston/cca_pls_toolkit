## CCA/PLS models

In this section, we present the formulations of the different CCA and PLS models implemented in the toolkit.

In all models, $\mathbf{X}$ and $\mathbf{Y}$ represent matrices for the two data modalities, each matrix containing one standardized (i.e., having zero mean and unit variance) variable/feature per column and one example/sample per row. The model weights, $\mathbf{w}_x$ and $\mathbf{w}_y$ (one weight vector for each modality) are column vectors with the same number of elements as the number of variables in their corresponding data modality.

Notations for L1 and L2-norm:

- $||\mathbf{w}||_2 = \sqrt{\sum_{k=1}^{n} |x_k|^2}$ is the L2-norm of a vector $\mathbf{w}$, i.e., square root of the sum of squares of weight values,
- $||\mathbf{w}||_1 = \sum_{k=1}^{n} |x_k|$ is the L1-norm of a vector $\mathbf{w}$, i.e., sum of absolute weight values.

### Canonical Correlation Analysis (CCA)

CCA ([Hotelling 1936](https://doi.org/10.2307/2333955)) finds a pair of weights, $\mathbf{w}_x$ and $\mathbf{w}_y$, such that the __correlation__ between the projections of $\mathbf{X}$ and $\mathbf{Y}$ onto these weights are maximised:
$$
max_{\mathbf{w}_x,\mathbf{w}_y} \text{ } corr(\mathbf{Xw}_x,\mathbf{Yw}_y)
$$

Most commonly though, CCA is expressed in the form of a constrained optimization problem:
$$
max_{\mathbf{w}_x,\mathbf{w}_y} \text{ } \mathbf{w}_x^T\mathbf{X}^T\mathbf{Yw}_y
$$
$$
\text{subject to } \mathbf{w}_x^T\mathbf{X}^T\mathbf{Xw}_x = 1,\\
\mathbf{w}_y^T\mathbf{Y}^T\mathbf{Yw}_y = 1
$$

We highlight that it is not possible to obtain a solution for this standard CCA when the number of variables exceeds the number of examples (technically speaking, the optimization problem is ill posed). Two approaches have been proposed to address this problem:

- reducing the dimensionality of the data with Principal Component Analysis (PCA) (e.g., [Smith et al. 2015](https://doi.org/10.1038/nn.4125), [Helmer et al. 2020](https://doi.org/10.1101/2020.08.25.265546), [Alnaes et al. 2020](https://doi.org/10.1073/pnas.2001517117)),
- using regularized extensions of CCA and PLS (e.g., [Xia et al. 2018](https://doi.org/10.1038/s41467-018-05317-y), [Ing et al. 2019](https://doi.org/10.1038/s41562-019-0738-8), [Popovic et al. 2020](https://doi.org/10.1016/j.biopsych.2020.05.020)). 

We note that although PLS always has a solution (i.e., never ill posed) irrespective of the number of variables, it might still benefit from regularization. Adding an L1-norm regularization, for example, pushes the weights of some variables to zero and therefore forcing the model to learn a sparse solution. 

### Partial Least Squares (PLS)

PLS (Wold 1985, [Wegelin 2000](https://stat.uw.edu/sites/default/files/files/reports/2000/tr371.pdf)) finds a pair of weights, $\mathbf{w}_x$ and $\mathbf{w}_y$, such that the __covariance__ between the projections of $\mathbf{X}$ and $\mathbf{Y}$ onto these weights are maximised:
$$
max_{\mathbf{w}_x,\mathbf{w}_y} \text{ } cov(\mathbf{Xw}_x,\mathbf{Yw}_y)
$$

Similar to CCA, PLS is most often expressed as a constrained optimization problem in the following form:
$$
max_{\mathbf{w}_x,\mathbf{w}_y} \text{ } \mathbf{w}_x^T\mathbf{X}^T\mathbf{Yw}_y
$$
$$
\text{subject to } ||\mathbf{w}_x||_2^2 = 1,\\
||\mathbf{w}_y||_2^2 = 1
$$

PLS is a family of methods. Depending on the modelling aim, PLS variants can be divided into two main groups:

- __symmetric variants__ (PLS-mode A, PLS-SVD): with the aim of identifying associations between two data modalities,
- __asymmetric variants__ (PLS1, PLS2): with the aim of predicting one modality from another modality.

For details on these variants, see e.g., [Wegelin 2000](https://stat.uw.edu/sites/default/files/files/reports/2000/tr371.pdf), [Rosipal & Kramer 2006](https://doi.org/10.1007/11752790_2), [Krishnan et al. 2011](https://doi.org/10.1016/j.neuroimage.2010.07.034), [Mihalik et al. 2020](https://doi.org/10.1016/j.biopsych.2019.12.001).

All PLS variants use the same optimization problem but they differ in their [deflation strategies](#deflation-methods). Therefore, whereas all variants yield the same first associative effect, the weights from the second associative effects will be different. 

### CCA with PCA dimensionality reduction (PCA-CCA)

PCA transforms each modality of multivariate data into uncorrelated principal components, such that the __variance__ of each principal component is maximised:
$$
max_{\mathbf{w}_x} \text{ } var(\mathbf{Xw}_x)
$$

$$
max_{\mathbf{w}_y} \text{ } var(\mathbf{Yw}_y)
$$

These principal components (i.e., $\mathbf{R}_x=\mathbf{Xw}_x$ and $\mathbf{R}_y=\mathbf{Yw}_y$) are then entered into CCA resulting in the following constrained optimization problem:
$$
max_{\mathbf{v}_x,\mathbf{v}_y} \text{ } \mathbf{v}_x^T\mathbf{R}_x^T\mathbf{R}_y\mathbf{v}_y
$$
$$
\text{subject to } \mathbf{v}_x^T\mathbf{R}_x^T\mathbf{R}_x\mathbf{v}_x = 1,
$$
$$
\mathbf{v}_y^T\mathbf{R}_y^T\mathbf{R}_y\mathbf{v}_y = 1
$$

PCA is often used as naive dimensionality reduction technique, as principal components explaining little variance are assumed to be noise and discarded, and the remaining principal components are entered into CCA.

### Regularized CCA (RCCA)

In RCCA, __L2-norm regularization__ is added to the CCA optimization ([Vinod 1976](https://doi.org/10.1016/0304-4076(76)90010-5)), which leads to the following constrained optimization problem:
$$
max_{\mathbf{w}_x,\mathbf{w}_y} \text{ } \mathbf{w}_x^T\mathbf{X}^T\mathbf{Yw}_y
$$
$$
\text{subject to } (1-c_x)\mathbf{w}_x^T\mathbf{X}^T\mathbf{Xw}_x+c_x||\mathbf{w}_x||_2^2 = 1,
$$
$$
(1-c_y)\mathbf{w}_y^T\mathbf{Y}^T\mathbf{Yw}_y+c_y||\mathbf{w}_y||_2^2 = 1
$$

The two hyperparameters of RCCA ($c_x$, $c_y$) control the amount of L2-norm regularization. We can see that these hyperparameters provide a smooth transition between CCA ($c_x=c_y=0$, not regularized) and PLS ($c_x=c_y=1$, most regularized), thus RCCA can be thought of as a mixture of CCA and PLS optimization.

### Sparse PLS (SPLS)

In SPLS, __L1-norm regularization__ is added to the PLS optimization (e.g., [Le Cao et al. 2008](https://doi.org/10.2202/1544-6115.1390), [Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011)), which leads to the following constrained optimization problem:
$$
max_{\mathbf{w}_x,\mathbf{w}_y} \text{ } \mathbf{w}_x^T\mathbf{X}^T\mathbf{Yw}_y
$$
$$
\text{subject to } ||\mathbf{w}_x||_2^2 \le 1,\\
||\mathbf{w}_x||_1 \le c_x,\\
||\mathbf{w}_y||_2^2 \le 1,\\
||\mathbf{w}_y||_1 \le c_y\\
$$

The two hyperparameters of SPLS ($c_x$, $c_y$) control the amount of L1-norm regularization. These hyperparameters set an upper limit to the L1-norm of the weights, thus imposing sparsity on the weights (i.e., the weights of some variables will be set to 0).

Similar to PLS, SPLS can also have different variants based on the [deflation methods](#deflation-methods) (e.g., generalized deflation in [Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011), PLS-mode A deflation in [Le Cao et al. 2009](https://doi.org/10.1186/1471-2105-10-34), PLS2 deflation in [Le Cao et al. 2008](https://doi.org/10.2202/1544-6115.1390)).

## Analysis frameworks

In order to optimize the hyperparameters (i.e., number of principal components or regularization parameters) and to perform statistical inference (i.e., assess the number of significant associative effects), the CCA/PLS model is embedded in an analytical framework.

The figures below ([Mihalik et al. 2022](https://doi.org/10.1016/j.bpsc.2022.07.012)) illustrate the two frameworks included in the toolkit.

<p align="center">
   <img src="../figures/framework_STAT.png" width="649" height="154">
</p>

In the __descriptive framework__, CCA/PLS is fitted on the entire data and the resulting model weights are used to compute in-sample correlation. There is no hyperparameter optimization, i.e., the number of principal components (PCA-CCA) or regularization parameters (RCCA, SPLS) is fixed. To assess the number of significant associative effects, we use permutation testing based on the in-sample correlation. In particular, we shuffle the order of the subjects (i.e., rows) in $\mathbf{Y}$ and fit the CCA/PLS model to compute permuted in-sample correlations. Critically, we calculate the p-value as the fraction of permuted in-sample correlations exceeding the in-sample correlation obtained on the non-permuted data of the first associative effect (i.e., maximum statistics approach).

<p align="center">
   <img src="../figures/framework_ML.png" width="649" height="331">
</p>

In the __predictive (or machine learning) framework__, first we randomly split the data into optimization set (e.g., 80% of the overall data) and holdout set (e.g., 20% of the overall data). For CCA/PLS models with hyperparameters (i.e., PCA-CCA, RCCA and SPLS), we further split the optimization set multiple times into training set (e.g., 80% of the optimization set) and validation set (e.g., 20% of the optimization set). The inner split is used for hyperparameter optimization and the outer split is used for statistical inference. The best hyperparameters (one for each data modality) are selected based on the best generalizability of the  model (measured as the average out-of-sample correlation in the validation sets). To assess the number of significant associative effects, we use permutation testing based on the out-of-sample correlation in the holdout set. In particular, we shuffle the order of the subjects (i.e., rows) in $\mathbf{Y}$ and fit the CCA/PLS model to compute permuted out-sample correlation. We calculate the p-value as the fraction of permuted out-of-sample correlations exceeding the out-of-sample correlation obtained on the non-permuted data. If multiple holdout sets are used then the p-value for each holdout set is corrected for multiple comparisons using Bonferroni correction (e.g., $\alpha=0.05/10=0.005$ in case of 10 holdout sets). This means that the associative effect is considered significant if $p \le 0.005$ in at least one of the holdout sets (omnibus hypothesis approach, for details see [Monteiro et al. 2016](https://doi.org/10.1016/j.jneumeth.2016.06.011)).

An important component of the CCA/PLS framework is testing the __stability of the model__. In the toolkit, the stability of the CCA/PLS model is measured as the average similarity of weights across different training (or optimization) sets (of course, at least two splits of data are needed for this). In addition to assessing the stability of the CCA/PLS model in the outer splits, stability can be also used as a joint criterion with generalizability for hyperparameter optimization (for details, see [Mihalik et al. 2020](https://doi.org/10.1016/j.biopsych.2019.12.001)).

## Deflation methods

The toolkit includes three different deflation methods for CCA/PLS models:

- generalized deflation,
- PLS-mode A deflation,
- PLS regression deflation.

__CCA__, __RCCA__ and __PLS-SVD__ can be all seen as subcases of the generalized eigenvalue problem. The iterative solution of the generalized eigenvalue problem uses generalized deflation, which thus will be the deflation strategy for these models. This deflation can be written as:  

$$
\mathbf{X}_{i+1} = \mathbf{X}_{i} - \mathbf{X}_{i} \mathbf{w}_x \mathbf{w}_x^T \mathbf{B}_{x}
$$

$$
\mathbf{Y}_{i+1} = \mathbf{Y}_{i} - \mathbf{Y}_{i} \mathbf{w}_{y} \mathbf{w}_y^T \mathbf{B}_{y}
$$

where we used the same notations as in the CCA/PLS models and $\mathbf{B}_x,\mathbf{B}_y$ define the different subcases of the generalized eigenvalue problem. In case of RCCA, $\mathbf{B}_x = (1-c_x)\mathbf{X}_0^T\mathbf{X}_0+c_x\mathbf{I}$ and $\mathbf{B}_y = (1-c_y)\mathbf{Y}_0^T\mathbf{Y}_0+c_y\mathbf{I}$, where $\mathbf{X}_0$ and $\mathbf{Y}_0$ are the original data matrices without deflation, $c_x$ and $c_y$ are the hyperparameters of L2-norm regularization in [RCCA](#regularized-cca-rcca). CCA and PLS-SVD are specific cases of $c_x=c_y=0$ and $c_x=c_y=1$, respectively.

__PLS-mode A__ uses the following deflation:

$$
\mathbf{X}_{i+1} = \mathbf{X}_i - \mathbf{X}_i \mathbf{w}_x \mathbf{p}^T
$$

$$
\mathbf{Y}_{i+1} = \mathbf{Y}_i - \mathbf{Y}_i \mathbf{w}_y \mathbf{q}^T
$$

where $\mathbf{p}=\frac{\mathbf{X}_i^T\mathbf{X}_i\mathbf{w}_x}{\mathbf{w}_x^T\mathbf{X}_i^T\mathbf{X}_i\mathbf{w}_x}$ and
$\mathbf{q}=\frac{\mathbf{Y}_i^T\mathbf{Y}_i\mathbf{w}_y}{\mathbf{w}_y^T\mathbf{Y}_i^T\mathbf{Y}_i\mathbf{w}_y}$.

__PLS1__ and __PLS2__ are regression methods (PLS1 refers to the variant with a single output variable and PLS2 refers to the variant with multiple output variables), in which case only the input data needs to be deflated as follows:
$$
\mathbf{X}_{i+1} = \mathbf{X}_i - \mathbf{X}_i \mathbf{w}_x \mathbf{p}^T
$$

where the same notations are used as above.

For additional details on deflations, see e.g., [Wegelin 2000](https://stat.uw.edu/sites/default/files/files/reports/2000/tr371.pdf), [Rosipal & Kramer 2006](https://doi.org/10.1007/11752790_2), [Mihalik et al. 2020](https://doi.org/10.1016/j.biopsych.2019.12.001), [Mihalik et al. 2022](https://doi.org/10.1016/j.bpsc.2022.07.012).
