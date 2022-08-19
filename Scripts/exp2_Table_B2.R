
#### Experiment 2 ####

### data
df <- read_csv("Data/alldata_exp2.csv")

# nice factor levels for the effects
df <- df %>% 
  mutate(chosen = capitalize(chosen),
         type = capitalize(type)) %>%
  mutate(type = if_else(type == "Decoy", "Attraction", type)) %>% 
  filter(type != "2menu") %>% 
  mutate(type = as.factor(type),
         type = fct_relevel(type, "Attraction", "Similarity")) %>% 
  mutate(chosen = as.factor(chosen),
         chosen = fct_relevel(chosen, "Target", "Competitor"))


# renaming type as effect
df <- df %>% 
  rename(effect = type)


## dropping 2menus as they are of no interest here for the time being
df <- df %>% 
  filter(effect != "2menu")

##### Exp2 : shares and times of first and second click ####
## contains
## 1. chocie shares of first click and of second click conditional on first
## 2. time to first click and extra time to second click, conditional on the above
## 3. situation after 2 clicks


## choice shares

firstclicks <- df %>% 
  filter(choiceno %in% c(1,2)) %>% 
  select(subject, screen, effect, choiceno, chosen, time) %>% 
  group_by(subject, screen, effect) %>% 
  mutate(time = as.character(time)) %>% 
  mutate(chosen = as.character(chosen)) %>% 
  pivot_wider(names_from = choiceno, values_from = c("chosen", "time"), values_fill = "stop")

## taking note of how many click zero times: 109 out of 7128 (1.52%)
firstclicks %>% 
  filter(is.na(chosen_1))

## taking note of how many click twice on the same option: 102 out of 7128 (1.43%)
firstclicks %>% 
  filter(chosen_1 == chosen_2)

## clean out 
## - all subjects not clickng
## - all subjects for which second click is the same as first
firstclicks <- firstclicks %>% 
  filter(!is.na(chosen_1),
         chosen_1 != "stop",
         chosen_1 != chosen_2)

## replace with NA if time_2 == "stop"
## and recode as integer the "time" variables
firstclicks <- firstclicks %>% 
  mutate(time_2 = if_else(time_2 == "stop", NA_character_, time_2)) %>% 
  mutate(time_1 = as.integer(time_1),
         time_2 = as.integer(time_2))

##table of shares
second <- firstclicks %>% 
  group_by(effect, chosen_1, chosen_2) %>% 
  tally() %>% 
  mutate(n/sum(n)) %>% 
  select(effect, firstclick = chosen_1, secondclick = chosen_2, share_second = `n/sum(n)`)

first <- firstclicks %>% 
  select(-chosen_2) %>% 
  group_by(effect, chosen_1) %>% 
  tally() %>% 
  mutate(n/sum(n)) %>% 
  select(effect,  firstclick = chosen_1, share_first = `n/sum(n)`)

table_share  <- first %>% right_join(second, by = c("effect", "firstclick"))


## table of times

second <- firstclicks %>% 
  group_by(effect, chosen_1, chosen_2) %>% 
  mutate(secondtime = time_2 - time_1) %>% 
  summarise(time_second = mean(secondtime, na.rm = T)/1000) %>% 
  select(effect, firstclick = chosen_1, secondclick = chosen_2, time_second)

first <- firstclicks %>% 
  select(-chosen_2) %>% 
  group_by(effect, chosen_1) %>% 
  summarise(time_first = mean(time_1, na.rm = T)/1000) %>% 
  select(effect, firstclick = chosen_1, time_first)


table_times <- first %>% right_join(second, by = c("effect", "firstclick"))

## situation after second click

# start from firstclicks, carry over chosen_1 to chosen_2 if chosen_2 == "stop"
situation <- firstclicks %>% 
  mutate(chosen_2 = if_else(chosen_2 == "stop", chosen_1, chosen_2)) %>% 
  select(subject, screen, effect, chosen_2) %>% 
  group_by(effect, chosen_2) %>% 
  tally() %>% 
  mutate(n/sum(n)) %>% 
  select(effect,  situation = chosen_2, share_after_second = `n/sum(n)`)


# merging shares and times
table <- table_share %>% 
  left_join(table_times, by = c("effect", "firstclick", "secondclick"))

# merging situation after second click
table <- table %>% 
  left_join(situation, by = c("effect", "firstclick" = "situation"))


# replacng NaNs by "--"
table <- table %>% 
  mutate(time_second = if_else(is.nan(time_second), 
                               "--", 
                               as.character(round(time_second,2))))

# formatting
table <- table %>% 
  mutate(share_first = round(100*share_first,2),
         share_second = round(100*share_second,2),
         share_after_second = round(100*share_after_second, 2)) %>% 
  mutate(time_first = paste0("(", round(time_first, 2), ")"),
         time_second = paste0("(", time_second, ")")) %>% 
  select(effect, firstclick, share_first, time_first, 
         secondclick, share_second, time_second, share_after_second)

## further formatting
table <- table %>% 
  mutate(firstclick = as_factor(firstclick), 
         firstclick = fct_relevel(firstclick, "Target", "Competitor"),
         secondclick = as_factor(secondclick),
         secondclick = fct_recode(secondclick, "No revision" = "stop"),
         secondclick = fct_relevel(secondclick, "Target", "Competitor")) %>% 
  arrange(effect, firstclick, secondclick)

# final formatting: removing duplicated rows
table <- table %>% 
  rownames_to_column() %>% 
  mutate(firstclick = as.character(firstclick)) %>% 
  mutate(rowname = as.integer(rowname),
         rowname = if_else(rowname %% 3 == 0 | (rowname + 1) %% 3 == 0, 0, 1 )) %>% 
  mutate(share_first = if_else(rowname == 0, "", as.character(share_first) ),
         time_first = if_else(rowname == 0, "", as.character(time_first)),
         firstclick = if_else(rowname == 0, "", firstclick),
         share_after_second = if_else(rowname == 0, "", as.character(share_after_second))) %>% 
  select(-rowname)

# adding a column to make the final share more meaningful
table <- table %>% 
  mutate(final = firstclick) %>% 
  select(effect, firstclick, share_first, time_first, 
         secondclick, share_second, time_second, 
         final, share_after_second)

# formatting table
tabB2 <- table %>% 
  ungroup() %>% 
  select(-effect) %>% 
  kable(col.names = NULL) %>% 
  add_header_above(c("", "share %", "time", "", "share %", "time", "", "share %")) %>% 
  add_header_above(c("First choice" = 3, "Revision" = 3, "After revision" = 2)) %>% 
  pack_rows("Attraction", 1, 9) %>% 
  pack_rows("Similarity", 10, 18) %>% 
  pack_rows("Compromise", 19, 27)


# saving the table: html and pdf
tabB2 %>% 
  save_kable("Tables/Table_B2.html")

tabB2 %>% 
  save_kable("Tables/Table_B2.pdf")