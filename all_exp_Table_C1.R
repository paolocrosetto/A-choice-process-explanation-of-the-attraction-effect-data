### Creates the demographic table in appendix of the paper
###
### for both exp1 and exp2

### exp 1 data

e1 <- read_csv("Data/alldata_exp1.csv")


e1 <- e1 %>% 
  select(subject = id, treatment, starts_with("form")) %>% 
  distinct()

# renaming and cleaning
e1 <- e1 %>% 
  ## recoding variables. See paper for details. 
  mutate(CRT_ball = as.numeric(form_control.form.CRT_ball == 5),
         CRT_machines = as.numeric(form_control.form.CRT_machines == 5),
         CRT_nenuphar = as.numeric(form_control.form.CRT_nenuphar == 47)) %>% 
  ## TODO: trust is wrong, check file; "autre" all coded as bac+5 or more
  mutate(`CRT score` = CRT_ball + CRT_machines + CRT_nenuphar,
         `Confusion prone` = form_proneness.form.affirmation_1 + form_proneness.form.affirmation_2 +
           form_proneness.form.affirmation_3 + form_proneness.form.affirmation_4 +
           form_proneness.form.affirmation_5 + form_proneness.form.affirmation_6 +
           form_proneness.form.affirmation_7 + form_proneness.form.affirmation_8 +
           form_proneness.form.affirmation_9,
         `Loss aversion` = case_when(form_risk.form.gainloss == "gainsonly" ~ 0,
                                     form_risk.form.gainloss == "gainsmore" ~ 1,
                                     form_risk.form.gainloss == "lossmore" ~ 2,
                                     form_risk.form.gainloss == "lossonly" ~ 3),
         Trust = 12 - (form_risk.form.trust1 + form_risk.form.trust2 + form_risk.form.trust3),
         Male = if_else(form_socio.form.genre == "h", 1, 0),
         `Visual treatment` = as.numeric(treatment == "barres"),
         Motivation = case_when(form_comprehension.form.motivation == "minimal" ~ 0,
                                form_comprehension.form.motivation == "low" ~ 1,
                                form_comprehension.form.motivation == "medium" ~ 2,
                                form_comprehension.form.motivation == "high" ~ 3),
         AE = case_when(form_comprehension.form.ADE == "prefer_competitor" ~ 0,
                        form_comprehension.form.ADE == "indifferent" ~ 0.5,
                        form_comprehension.form.ADE == "avoid_competitor" ~ 1),
         `Budget holder` = if_else(form_socio.form.budgetholder == "Non", 0, 1),
         `Shopping experience` = if_else(form_socio.form.shopping == "Non", 0, 1),
         Economics = if_else(form_socio.form.econ == "Non", 0, 1),
         `City size` = case_when(form_socio.form.citycountry == "Campagne" ~ 0,
                                 form_socio.form.citycountry == "Village" ~ 1,
                                 form_socio.form.citycountry == "PetiteVille" ~ 2,
                                 form_socio.form.citycountry == "Ville" ~ 3,
                                 form_socio.form.citycountry == "Metro" ~ 4),
         Income = case_when(form_socio.form.revenu == "0_1000" ~ 500,
                            form_socio.form.revenu == "1000_2000" ~ 1500,
                            form_socio.form.revenu == "2000_3000" ~ 2500),
         Education = case_when(form_socio.form.diplome == "aucun" ~ 0,
                               form_socio.form.diplome == "cap" ~ 1,
                               form_socio.form.diplome == "bp" ~ 2,
                               form_socio.form.diplome == "bac" ~ 3,
                               form_socio.form.diplome == "sup2" ~ 4,
                               form_socio.form.diplome == "sup4" ~ 5,
                               form_socio.form.diplome == "autre" ~ 5),
         Occupation = case_when(form_socio.form.emploi == "chomage" ~ "Unemployed/Retired",
                                form_socio.form.emploi == "etudiant" ~ "Student",
                                form_socio.form.emploi == "foyer" ~ "Unemployed/Retired",
                                form_socio.form.emploi == "retraite" ~ "Unemployed/Retired",
                                form_socio.form.emploi == "travail" ~ "Worker",
                                form_socio.form.emploi == "recherche" ~ "Worker"),
         `Control Question trials` = NA) %>% 
  select(subject,
         # treatment
         #`Visual treatment`,
         # understanding
         `Control Question trials`,
         Difficult = form_comprehension.form.difficult,
         Experience = form_comprehension.form.experience,
         Motivation,
         Problems = form_comprehension.form.problems,
         Understanding = form_comprehension.form.understanding,
         # individual characteristics
         `CRT score`,
         Risk = form_risk.form.soep,
         AE,
         `Confusion prone`,
         `Loss aversion`,
         Trust,
         `Shopping experience`,
         `Budget holder`,
         # demographics
         Male,
         Age = form_socio.form.naissance,
         Income,
         Education,
         Economics,
         `City size`,
         Occupation 
  )


## computing stats

# numeric
e1_numeric <- e1 %>% 
  select(-subject) %>% 
  summarise(across(.cols = -Occupation, list(xp1mean = mean, xp1sd = sd, xp1min = min, xp1median = median, xp1max = max))) %>% 
  pivot_longer(cols = everything(), names_to = c("variable","indicator"), values_to = "value", names_sep = "_") %>% 
  pivot_wider(names_from = indicator, values_from = value)

e1_cat <- e1 %>% 
  select(Occupation) %>% 
  group_by(Occupation) %>% 
  tally() %>% 
  mutate(xp1share = paste0(round(100*n/sum(n)),"%")) %>% 
  select(variable = Occupation, xp1share)


### exp 2 data

e2 <- read_csv("Data/alldata_exp2.csv")


e2 <- e2 %>% 
  select(subject, CQtrials, starts_with("CRT"), diplome, autreDiplome, econ, emploi, genre, naissance, revenu, soep) %>% 
  distinct()

e2 <- e2 %>% 
  ## recoding variables. See paper for details. 
  mutate(CRT_ball = as.numeric(CRT_ball == 5),
         CRT_machines = as.numeric(CRT_machines == 5),
         CRT_nenuphar = as.numeric(CRT_nenuphar == 47)) %>% 
  ## TODO: trust is wrong, check file; "autre" all coded as bac+5 or more
  mutate(`CRT score` = CRT_ball + CRT_machines + CRT_nenuphar, 
         Male = if_else(genre == "h", 1, 0),
         Income = case_when(revenu == "0_1000" ~ 500,
                            revenu == "1000_2000" ~ 1500,
                            revenu == "2000_3000" ~ 2500,
                            revenu == "3000_4000" ~ 3500,
                            revenu == "4000_5000" ~ 4500,
                            revenu == "5000_6000" ~ 5500,
                            revenu == "6000_7000" ~ 6500,
                            revenu == "8000_plus" ~ 8000),
         Education = case_when(diplome == "aucun" ~ 0,
                               diplome == "cap" ~ 1,
                               diplome == "bp" ~ 2,
                               diplome == "bac" ~ 3,
                               diplome == "sup2" ~ 4,
                               diplome == "sup4" ~ 5,
                               diplome == "autre" ~ 5),
         Occupation = case_when(emploi == "chomage" ~ "Unemployed/Retired",
                                emploi == "etudiant" ~ "Student",
                                emploi == "foyer" ~ "Unemployed/Retired",
                                emploi == "retraite" ~ "Unemployed/Retired",
                                emploi == "travail" ~ "Worker",
                                emploi == "recherche" ~ "Worker"),
         Economics = if_else(econ == "Non", 0, 1)) %>% 
  select(subject,
         `Control Question trials` = CQtrials,
         `CRT score`,
         Risk = soep,
         Male,
         Age = naissance,
         Income,
         Economics,
         Education,
         Occupation 
  )


## computing stats

# numeric
e2_numeric <- e2 %>% 
  select(-subject) %>% 
  summarise(across(.cols = -Occupation, list(xp2mean = mean, xp2sd = sd, xp2min = min, xp2median = median, xp2max = max))) %>% 
  pivot_longer(cols = everything(), names_to = c("variable","indicator"), values_to = "value", names_sep = "_") %>% 
  pivot_wider(names_from = indicator, values_from = value)

e2_cat <- e2 %>% 
  select(Occupation) %>% 
  group_by(Occupation) %>% 
  tally() %>% 
  mutate(xp2share = paste0(round(100*n/sum(n)),"%")) %>% 
  select(variable = Occupation, xp2share)


### merging

numeric_variables <- full_join(e1_numeric, e2_numeric, by = "variable")
categorical_variables <- full_join(e1_cat, e2_cat, by = "variable")


## creating the table

tabC1 <- numeric_variables %>% 
  full_join(categorical_variables, by = "variable") %>% 
  select(variable, xp1share, xp1mean, xp1sd, xp1min, xp1median, xp1max, xp2share, xp2mean, xp2sd, xp2min, xp2median, xp2max) %>% 
  mutate(xp1mean = round(xp1mean, 2),
         xp2mean = round(xp2mean, 2),
         xp1sd = round(xp1sd, 2),
         xp2sd = round(xp2sd, 2),
         xp1share = if_else(is.na(xp1share), "", as.character(xp1share)),
         xp2share = if_else(is.na(xp2share), "", as.character(xp2share)),
         xp2mean = if_else(is.na(xp2mean), "", as.character(xp2mean)),
         xp2sd = if_else(is.na(xp2sd), "", as.character(xp2sd)),
         xp2min = if_else(is.na(xp2min), "", as.character(xp2min)),
         xp2median = if_else(is.na(xp2median), "", as.character(xp2min)),
         xp2max = if_else(is.na(xp2max), "", as.character(xp2max)),
         xp1mean = if_else(is.na(xp1mean), "", as.character(xp1mean)),
         xp1sd = if_else(is.na(xp1sd), "", as.character(xp1sd)),
         xp1min = if_else(is.na(xp1min), "", as.character(xp1min)),
         xp1median = if_else(is.na(xp1median), "", as.character(xp1min)),
         xp1max = if_else(is.na(xp1max), "", as.character(xp1max))) %>% 
  kable(col.names = NULL, 
        caption = "Control and demographics variables for both experiments", 
        label = "demographics") %>% 
  kable_styling(latex_options = "scale_down") %>% 
  add_header_above(c("", "Share", "Mean", "St.Dev.", "Min", "Median", "Max","Share", "Mean", "St.Dev.", "Min", "Median", "Max")) %>% 
  add_header_above(c("", "Experiment 1" = 6, "Experiment 2" = 6)) %>% 
  pack_rows("Understanding", 1, 6) %>% 
  pack_rows("Personal Characteristics", 7, 14) %>% 
  pack_rows("Demographics", 15, 20) %>% 
  pack_rows("Composition of the sample", 21, 23) 

## exporting to html and pdf
tabC1 %>% 
  save_kable("Tables/Table_C1.html")
tabC1 %>% 
  save_kable("Tables/Table_C1.pdf")
