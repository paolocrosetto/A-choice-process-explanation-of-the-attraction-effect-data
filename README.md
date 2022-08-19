# Data and Analysis for the paper Fast *then* Slow: A Choice Process Explanation for the Attraction Effect

This repository contains raw data and scripts to reproduce all analyses of the paper "*Fast then Slow: A Choice Process Explanation for the Attraction Effect*" by Alexia Gaudeul (R) Paolo Crosetto.

The paper can be found here: [Working Paper](https://ideas.repec.org/p/gbl/wpaper/2019-06.html)

## Dependencies
To run the analysis you need R and the following packages (available on CRAN):

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

### Figures
Figures are saved to the `Figures/` folder. They are the high-resolution images (and do not fit well in the github preview screen) included in the paper.

### Tables
Tables are saved to the `Tables/` folder. They contain the exact same information as in the paper, and they are saved both as .html and .pdf versions. They might have slight format differences from the paper final tables, as those were exported in Latex and then imported in the paper.


### Model setup and estimation 

ALEXIA TODO

## License

Creative Commons Attribution-NonCommercial-ShareAlike -- CC BY-NC-SA

