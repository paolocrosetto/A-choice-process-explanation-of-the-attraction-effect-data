####
####
####

## Authors: Paolo Crosetto & Alexia Gaudeul

## This file runs the whole analysis


## Libraries and dependencies
library(tidyverse)           # specific R dialect used in this file

library(zoo)                 # time-series tools to discretize the dataset

library(R.utils)             # misc statistic and helper functions


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