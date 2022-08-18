####
####
####

## Authors: Paolo Crosetto & Alexia Gaudeul

## This file runs the whole analysis


## Libraries and dependencies
library(tidyverse)           # specific R dialect used in this file

library(zoo)                 # time-series tools to discretize the dataset

library(R.utils)             # misc statistic and helper functions

library(kableExtra)          # to export beautiful latex tables

library(hrbrthemes)          # main plotting theme
library(ggtext)              # add markdown support to ggplot
library(patchwork)           # compose complex plots by patching together simple plots



#### Experiment 1 ####

## raw data
df <- read_csv("Data/alldata_exp1.csv")


## Data formatting for better displayed values
df <- df %>% 
  rename(subject = id) %>% 
  filter(phase == "task") %>% 
  filter(screentype == "3 options CS") %>% 
  mutate(chosen = as.factor(chosen)) %>% 
  mutate(chosen = fct_relevel(chosen, "target", "competitor", "decoy")) %>% 
  mutate(treatment = as.factor(treatment),
         treatment = fct_recode(treatment, "Graphical" = "barres", "Numeric" = "chiffres")) %>% 
  mutate(chosen = as_factor(chosen), 
         chosen = fct_recode(chosen, "Target" = "target", "Competitor" = "competitor", "Decoy" = "decoy")) 

## discretize the data to get a snapshot of the results every 10th of a second
source("exp1_discretize.R")

## Figure 4: Choice shares and difference in time, for the first click only and for all clicks, by treatment
source("exp1_Figure_4.R")

## Figure 5: Choice shares and difference in time, first and all clicks, by relative price
source("exp1_Figure_5.R")

## Figure A.3: Alternative measures of the attraction effect, by treatment

## Figure A.4: Alternative measures of the attraction effect, by relative price of the target
source("exp1_Figure_A3_A4.R")

## Table B.1: Dynamics of revisions: choice shares after the first click, revisions upon the second click, and choice share after two clicks
source("exp1_Table_B1.R")