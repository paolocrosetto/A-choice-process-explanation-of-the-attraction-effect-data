# Data and Analysis for the paper Fast *then* Slow: A Choice Process Explanation for the Attraction Effect

This repository contains raw data and scripts to reproduce all analyses of the paper "*Fast then Slow: A Choice Process Explanation for the Attraction Effect*" by Alexia Gaudeul (R) Paolo Crosetto.

The paper can be found here: [Working Paper](https://ideas.repec.org/p/gbl/wpaper/2019-06.html)

# Descriptive section of the paper
## Dependencies
To run the descriptive analysis you need R and the following packages (available on CRAN):

- `tidyverse` -- a set of tools to work with tidy -- i.e. well behaved -- data. 
- `hrbrthemes`, `ggtext` and `patchwork` -- a set of good-looking `ggplot` themes, tools to use markdown-formatted text in plots, and a plot-composer to patch together different plots
- `zoo` -- a time-series library used to discretize the dataset
- `R.utils` -- misc helper functions
- `kableExtra` -- to create and export nice-looking tables

## How to run the analysis

- Download or clone this repository.
- Open the .Rproj file.
- Open and execute the Analysis.R file.

The analysis is fully carried out in the file Analysis.R. This file:

- loads the packages (do install them first if you do not have them yet)
- loads the data
- calls on individual files to generate individual figures or tables

For each figure or table in the paper, there is one dedicated file. The files are self-standing and can be executed in any order.

## Reproducibility

Things might not work for you, because the `R` ecosystem mutates at a fast pace, packages change, get new versions, conflicting functions, etc... The repo as it is does run correctly on ur systems, given our `R` versions and the version of each of a hundred or so of packages that are needed for the analyis to run (i.e. the packages mentioned above plus all of their dependencies). We cannot be sure that the analysis will keep running in the future, breaking changes to packages might occur. 

A solution to this is to use `groundhog`. It installs a fresh `R` version with all the packages downloaded **at the very date** when we wrote the script; this ensures reproducibility but is very long (needs to download hundreds of packages).

The `analysis.R` file that runs the (descriptive) analysis features a vanilla version, where *your* installed `R` and packages are used; but also a version wirtten using `groundhog`, that needs time but ensures that our code will run in the future. Feel free to choose the one that is best for you. 

### Figures
Figures are saved to the `Figures/` folder. They are the high-resolution images (and do not fit well in the github preview screen) included in the paper.

### Tables
Tables are saved to the `Tables/` folder. They contain the exact same information as in the paper, and they are saved both as .html and .pdf versions. They might have slight format differences from the paper final tables, as those were exported in Latex and then imported in the paper.


# Model setup, simulations and estimation 
## Dependencies

To run the simulations and model estimation you need R and the following packages (available on CRAN):

- `rstan` and `cmdstanr` -- for Bayesian modeling and inference.
- `posterior` and `bayesplot` -- for posterior analysis and plotting results
- `hrbrthemes`, `ggtext` and `patchwork` -- a set of good-looking `ggplot` themes, tools to use markdown-formatted text in plots, and a plot-composer to patch together different plots
- `R.utils` -- misc helper functions
- `kableExtra` -- to create and export nice-looking tables

## Functions

- stan models are available in folder stan 

## Simulations

## License

Creative Commons Attribution-NonCommercial-ShareAlike -- CC BY-NC-SA

