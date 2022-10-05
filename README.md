# Data and Analysis for the paper Fast *then* Slow: A Choice Process Explanation for the Attraction Effect

This repository contains raw data and scripts to reproduce all analyses of the paper "*Fast then Slow: A Choice Process Explanation for the Attraction Effect*" by Alexia Gaudeul (R) Paolo Crosetto.

The paper can be found here: [Working Paper](https://ideas.repec.org/p/gbl/wpaper/2019-06.html)

# Descriptive section of the paper

In the `Descriptive analysis` section of the repository you will find all data and scripts to reproduce plots, table, figures and tests of the descriptive part of the paper.

## Dependencies

To run the descriptive analysis you need R and the following packages (available on CRAN):

-   `tidyverse` -- a set of tools to work with tidy -- i.e. well behaved -- data.
-   `hrbrthemes`, `ggtext` and `patchwork` -- a set of good-looking `ggplot` themes, tools to use markdown-formatted text in plots, and a plot-composer to patch together different plots
-   `zoo` -- a time-series library used to discretize the dataset
-   `R.utils` -- misc helper functions
-   `kableExtra` -- to create and export nice-looking tables

## How to run the analysis

-   Download or clone this repository.
-   Open the .Rproj file.
-   Open and execute the Analysis.R file.

The analysis is fully carried out in the file Analysis.R. This file:

-   loads the packages (do install them first if you do not have them yet)
-   loads the data
-   calls on individual files to generate individual figures or tables

For each figure or table in the paper, there is one dedicated file. The files are self-standing and can be executed in any order.

## Reproducibility

Things might not work for you, because the `R` ecosystem mutates at a fast pace, packages change, get new versions, conflicting functions, etc... The repo as it is does run correctly on ur systems, given our `R` versions and the version of each of a hundred or so of packages that are needed for the analyis to run (i.e. the packages mentioned above plus all of their dependencies). We cannot be sure that the analysis will keep running in the future, breaking changes to packages might occur.

A solution to this is to use `groundhog`. It installs a fresh `R` version with all the packages downloaded **at the very date** when we wrote the script; this ensures reproducibility but is very long (needs to download hundreds of packages).

The `analysis.R` file that runs the (descriptive) analysis features a vanilla version, where *your* installed `R` and packages are used; but also a version wirtten using `groundhog`, that needs time but ensures that our code will run in the future. Feel free to choose the one that is best for you.

### Figures

Figures are saved to the `Figures/` folder. They are the high-resolution images (and do not fit well in the github preview screen) included in the paper.

### Tables

Tables are saved to the `Tables/` folder. They contain the exact same information as in the paper, and they are saved both as .html and .pdf versions. They might have slight format differences from the paper final tables, as those were exported in Latex and then imported in the paper.

# MLBA-R model

In the `MLBA-R` section of the repository, you find an extension of the multiattribute linear ballistic accumulator model to allow for choice revisions.

We provide `RStan` code for the model, and commands for the simulations, estimations and post-estimation on two experiments.

## Dependencies

To run the simulations and model estimation you need `R` and the following packages (available on CRAN):

-   `rstan` and `cmdstanr` -- for Bayesian modeling and inference.

-   `posterior` and `bayesplot` -- for posterior analysis and plotting results

-   other necessary libraries are loaded in the file `MLBAR_LOADING_LIBRARIES.Rmd`

## How to run the analysis

-   Download or clone this repository.
-   Open the `.Rproj` file.
-   Open and run the following files:
    -   `MLBAR_LOADING_LIBRARIES.Rmd` : loads necessary packages and functions to do graphs and tables
    -   `MLBAR_SIMULATIONS.Rmd` : to perform simulations of choices for the attraction, similarity and compromise effects
    -   `MLBAR_ESTIMATION.Rmd` : to perform estimates of the parameters of the MLBAR model and outputs resulting estimates
    -   `MLBAR_POST_ESTIMATION.Rmd` : to obtain post-estimation based on estimated parameters and simulate resulting choices

### Models

-   `stan` models are provided for three types of regressions:
    -   a model with no revisions in choice and no mixed effects: `mlba_single_v8_Frechet_generalized.stan`
    -   a model with revisions in choice and no mixed effects: `mlba_revision_v9_Frechet_generalized.stan`
    -   a model with revisions in choice and mixed effects: `mlba_revision_v9_Frechet_generalized_mixed.stan`

We also include in the repo the `.exe` compiled versions of the `stan` models. These were compiled for Windows and might not work on your machine, but they could help in case you have troubles compiling `stan` models on Windows.

### Data

Data is saved to the `data/` folder.

### Results

Estimation results are saved to the `results/` folder. We only loaded the results of the first chain (sample of 2000) on GitHub.

This leads to slight differences in the figures and tables compared to the paper which reports results for 16 chains.

### Figures

Figures are saved to the `graphs/` folder.

### Tables

Tables are saved to the `tables/` folder.

# License

Creative Commons Attribution-NonCommercial-ShareAlike -- CC BY-NC-SA
