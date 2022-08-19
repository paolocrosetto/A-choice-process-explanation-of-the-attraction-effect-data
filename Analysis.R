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


#### Experiment 2 ####

## raw data
df <- read_csv("Data/alldata_exp2.csv")


## data cleaning
df <- df %>% 
  mutate(chosen = capitalize(chosen),
         type = capitalize(type)) %>%
  mutate(type = if_else(type == "Decoy", "Attraction", type)) %>% 
  mutate(type = if_else(type == "Compromise", "Reverse Compromise", type)) %>% 
  filter(type != "2menu") %>% 
  mutate(type = as.factor(type),
         type = fct_relevel(type, "Attraction", "Similarity")) %>%
  # taking care of reverse compromise
  mutate(chosen = case_when(type == "Reverse Compromise" & chosen == "Target" ~ "Competitor",
                            type == "Reverse Compromise" & chosen == "Decoy" ~ "Target",
                            type == "Reverse Compromise" & chosen == "Competitor" ~ "Decoy",
                            TRUE ~ chosen)) %>% 
  mutate(chosen = as.factor(chosen),
         chosen = fct_relevel(chosen, "Target", "Competitor"))%>% 
  mutate(expected = case_when(type == "Attraction" ~ 0.5,
                              TRUE ~ 0.33))

## discretize the data to get a snapshot of the results every 10th of a second
source("exp2_discretize.R")

## Figure 8: Choice shares and difference in time, for the first click only and for all clicks, by effect
source("exp2_Figure_8.R")

## Figure 9: Figures 9-10-11: all effects: choice shares and difference in time, first and all clicks, by relative price
source("exp2_Figure_9_10_11.R")

## Table B.2: Dynamics of revisions: choice shares after the first click, revisions upon the second click, and choice share after two clicks
source("exp2_Table_B2.R")

#### Samples of Experiments 1 and 2 ####

## Table C.1: Control and demographics variables for both experiments
source("all_exp_Table_C1.R")