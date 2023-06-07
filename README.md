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

-   `cmdstanr`must be installed from <https://github.com/stan-dev/cmdstanr> as explained at <https://mc-stan.org/r-packages/>

-   `posterior` and `bayesplot` -- for posterior analysis and plotting results

-   other necessary libraries are loaded in the file `MLBAR_LOADING_LIBRARIES.Rmd`

## How to run the analysis

-   Download or clone this repository.
-   Open the `.Rproj` file.
-   Open and run the following files in the following succession:
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

## Variables

Here we list all the variables in the raw datasets, for both experiments.

### Experiment 1

The raw dataset, when loaded, contains one row for each click made by each subject on each screen.

| Name                        | Type        | Description                                                                                                                                                                                         |
|-----------------------------|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `subject`                   | numeric     | unique subject ID                                                                                                                                                                                   |
| `screen`                    | numeric     | unique screen ID                                                                                                                                                                                    |
| `order`                     | numeric     | order of the screen as seen by each subject                                                                                                                                                         |
| `phase`                     | categorical | phase of the epxeriment (learning; task)                                                                                                                                                            |
| `time`                      | numeric     | time in millisecond elapsed from the start of the screen to the time of the click                                                                                                                   |
| `chosen`                    | categorical | target, competitor or decoy                                                                                                                                                                         |
| `nchoices`                  | numeric     | number of clicks in the given screen                                                                                                                                                                |
| `choiceno`                  | numeric     | ordered number of the click                                                                                                                                                                         |
| `session`                   | character   | unique session ID                                                                                                                                                                                   |
| `treatment`                 | character   | treatment identifier (Graphical; Numeric)                                                                                                                                                           |
| `date`                      | date        | date of the sessions                                                                                                                                                                                |
| `markup`                    | numeric     | unit price ratio, target/competitor                                                                                                                                                                 |
| `cost_target`               | numeric     | cost of the target option                                                                                                                                                                           |
| `correct_answer_target`     | logical     | is the target the optimal choice in the given screen?                                                                                                                                               |
| `size_target`               | numeric     | size of the target option in the given screen                                                                                                                                                       |
| `price_target`              | numeric     | shown price of the target option in the given screen                                                                                                                                                |
| `cost_competitor`           | numeric     | cost of the competitor option                                                                                                                                                                       |
| `correct_answer_competitor` | logical     | is the competitor the optimal choice in the given screen?                                                                                                                                           |
| `size_competitor`           | numeric     | size of the competitor option in the given screen                                                                                                                                                   |
| `price_competitor`          | numeric     | shown price of the competitor option in the given screen                                                                                                                                            |
| `cost_decoy`                | numeric     | cost of the decoy option                                                                                                                                                                            |
| `size_decoy`                | numeric     | size of the decoy option in the given screen                                                                                                                                                        |
| `price_decoy`               | numeric     | shown price of the decoy option in the given screen                                                                                                                                                 |
| `screentype`                | categorical | type of screen (2 or 3 options, presence or absence of a decoy)                                                                                                                                     |
| `up_target`                 | numeric     | unit price of the target option                                                                                                                                                                     |
| `up_competitor`             | numeric     | unit price of the competitor option                                                                                                                                                                 |
| `up_decoy`                  | numeric     | unit price of the decoy option                                                                                                                                                                      |
| `order_target`              | numeric     | position of the target option (1 = left, 2 = center, 3 = right)                                                                                                                                     |
| `AE`                        | categorical | If two offers were of the same volume and the third was of a different volume, did you tend to prefer or avoid that of a different volume? 0: Prefer competitor, 0.5: Indifferent 1: Prefer target. |
| `AE_why`                    | character   | free text explanation of reasons for the reply to `AE`                                                                                                                                              |
| `demand_effect`             | character   | free text where subjects could tell us what they thought was the aim of the experiment                                                                                                              |
| `difficult`                 | dummy       | Was it difficult for you to make choices. Yes=1, No=0                                                                                                                                               |
| `experience`                | numeric     | How many studies did you take part in the past?                                                                                                                                                     |
| `motivation`                | categorical | Was it important for you to make the right choices? Coded 0-3 in order of importance.                                                                                                               |
| `problems`                  | dummy       | Did you face any problems during this study. Yes=1, No=0                                                                                                                                            |
| `problems_detail`           | character   | free text explanation of reasons for the reply to problems                                                                                                                                          |
| `understanding`             | dummy       | Did you understand what to do in this study. Yes=1, No=0                                                                                                                                            |
| `CRT_ball`                  | numeric     | Answer to the tennis bat and ball CRT question                                                                                                                                                      |
| `CRT_machines`              | numeric     | Answer to the machines CRT question                                                                                                                                                                 |
| `CRT_nenuphar`              | numeric     | Answer to the pond CRT question                                                                                                                                                                     |
| `prone1` to `prone9`        | numeric     | Answers to 9 questions of the confusion proneness scale -- adapted from Walsh et al. (2007), each graded from 1 to 5, in order of higher expressed confusion when shopping.                         |
| `loss_aversion`             | character   | When you decide to take a risk, do you think about the gains you could get, or the losses you could endure?                                                                                         |
| `trust1` to `trust3`        | numeric     | Answer to the generic SOEP risk taking question (0 to 10 increasing risk tolerance)                                                                                                                 |
| `budgetholder`              | character   | Are you in charge of your own budget? (Oui, Non)                                                                                                                                                    |
| `citycountry`               | categorical | Where did you live most of your life, in order of size, from countryside to large city of more than 1 million people.                                                                               |
| `gender`                    | categorical | male (h) or female (f)                                                                                                                                                                              |
| `age`                       | numeric     | age of the subject                                                                                                                                                                                  |
| `occupation`                | categorical | Worker, Student or Unemployed/retired.                                                                                                                                                              |
| `economics`                 | dummy       | subject has studied economics                                                                                                                                                                       |
| `income`                    | categorical | Monthly post-tax family income, in categories (0-1000 euro, 1000-2000, 2000-3000+)                                                                                                                  |
| `shopping_experience`       | categorical | Do you generally go shopping yourself? (oui, non)                                                                                                                                                   |
| `education`                 | categorical | highest diploma obtained in the French school system                                                                                                                                                |
| `soep`                      | numeric     | answer to the soep standard risk question (willingness to take risks on a likert 0-10 scale)                                                                                                        |

### Experiment 2

The raw dataset, when loaded, contains one row for each click made by each subject on each screen.

| Name            | Type        | Description                                                                                         |
|-----------------|-------------|-----------------------------------------------------------------------------------------------------|
| `subject`       | numeric     | unique subject ID                                                                                   |
| `screen`        | numeric     | unique screen ID                                                                                    |
| `order`         | numeric     | order of the screen as seen by each subject                                                         |
| `CQtrials`      | numeric     | number of times a subject tried and failed to validate the control questions screen                 |
| `time`          | numeric     | time in millisecond elapsed from the start of the screen to the time of the click                   |
| `chosen`        | categorical | target, competitor or decoy                                                                         |
| `nchoices`      | numeric     | number of clicks in the given screen                                                                |
| `choiceno`      | numeric     | ordered number of the click                                                                         |
| `session`       | character   | unique session ID                                                                                   |
| `treatment`     | character   | treatment identifier (Graphical; Numeric)                                                           |
| `date`          | date        | date of the sessions                                                                                |
| `name`          | categorical | screen "name", i.e. unique ID + info on type of screen                                              |
| `ID`            | numeric     | screen numeric ID                                                                                   |
| `type`          | categorical | screen type (2 options, compromise, decoy, similarity)                                              |
| `p1`            | numeric     | price of the first option in a screen (always the target)                                           |
| `q1`            | numeric     | quantity of the first option in a screen (always the target)                                        |
| `up1`           | numeric     | unit price (p/q) of the target                                                                      |
| `order1`        | numeric     | position in the screen of the target (1 left, 2 middle, 3 right)                                    |
| `p2`            | numeric     | price of the second option in a screen (always the competitor)                                      |
| `q2`            | numeric     | quantity of the second option in a screen (always the competitor)                                   |
| `up2`           | numeric     | unit price (p/q) of the competitor                                                                  |
| `order2`        | numeric     | position in the screen of the competitor (1 left, 2 middle, 3 right)                                |
| `p3`            | numeric     | price of the third option in a screen (always the decoy)                                            |
| `q3`            | numeric     | quantity of the third option in a screen (always the decoy)                                         |
| `up3`           | numeric     | unit price (p/q) of the decoy                                                                       |
| `order3`        | numeric     | position in the screen of the decoy (1 left, 2 middle, 3 right)                                     |
| `indiff`        | numeric     | difference in value between target and competitor (0 = no difference)                               |
| `decoy_penalty` | numeric     | how does the decoy unit price compare to the target unit price                                      |
| `comp_penalty`  | numeric     | how does the competitor unit price compare to the target unit price                                 |
| `targ_adv`      | numeric     | how does the target unit price compare to the competitor unit price (identical to 1/`comp_penalty`) |
| `CRT_ball`      | numeric     | Answer to the tennis bat and ball CRT question                                                      |
| `CRT_machines`  | numeric     | Answer to the machines CRT question                                                                 |
| `CRT_nenuphar`  | numeric     | Answer to the pond CRT question                                                                     |
| `education`     | categorical | highest diploma obtained in the French school system                                                |
| `gender`        | categorical | male (h) or female (f)                                                                              |
| `age`           | numeric     | age of the subject                                                                                  |
| `occupation`    | categorical | Worker, Student or Unemployed/retired.                                                              |
| `economics`     | dummy       | subject has studied economics                                                                       |
| `income`        | categorical | Monthly post-tax family income, in categories (0-1000 euro, 1000-2000, 2000-3000+)                  |
| `soep`          | numeric     | answer to the soep standard risk question (willingness to take risks on a likert 0-10 scale)        |

# License

Creative Commons Attribution-NonCommercial-ShareAlike -- CC BY-NC-SA
