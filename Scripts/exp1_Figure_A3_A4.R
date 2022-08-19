### Plots using alternative measure for Experiment 1
###
### Overall and by markup; produces plots that go in the appendix (A3 and A4)
###
### Using different measures
###
### 1. T - T: 3vs3
### 2. T - T: 3vs2
###
### and then 
### 1. Overall, by treatment
### 2. by markup, merging treatments


## Raw data
df <- read_csv("Data/alldata_exp1.csv")

# Making variables display nicer names and values
df <- df %>% 
  rename(subject = id) %>% 
  filter(phase == "task") %>% 
  mutate(chosen = as.factor(chosen)) %>% 
  mutate(chosen = fct_relevel(chosen, "target", "competitor", "decoy")) %>% 
  mutate(treatment = as.factor(treatment),
         treatment = fct_recode(treatment, "Graphical" = "barres", "Numeric" = "chiffres")) %>% 
  mutate(chosen = as_factor(chosen), 
         chosen = fct_recode(chosen, "Target" = "target", "Competitor" = "competitor", "Decoy" = "decoy")) 



# discretize: first click only
df_1 <- df %>% 
  filter(choiceno == 1) %>% 
  select(subject, treatment, screentype, screen, time, chosen)


subjects <- df %>% ungroup() %>% select(subject,screen) %>% distinct()
times <- data.frame(subject = rep(subjects$subject,200), screen=subjects$screen) %>% 
  arrange(subject,screen) %>% 
  as_tibble()
times <- data.frame(subject = times$subject, screen=times$screen, time=1:200) %>% 
  as_tibble()
rm(subjects)

df_1 <- df_1 %>%
  mutate(time=ceiling(time/100)) %>% 
  right_join(times, by=c("time", "subject","screen")) %>% 
  group_by(subject,screen) %>% 
  arrange(subject, screen, time)

df_1 <- df_1 %>% 
  ungroup() %>% 
  group_by(subject, screen) %>%
  mutate(chosen = na.locf(chosen, na.rm = FALSE),
         treatment = na.locf(treatment, na.rm = FALSE),
         treatment = na.locf(treatment, na.rm = FALSE, fromLast = TRUE), 
         screentype = na.locf(screentype, na.rm = FALSE),
         screentype = na.locf(screentype, na.rm = FALSE, fromLast = TRUE)
  ) %>% 
  mutate(level = "First click")

# discretize: all clicks
df_all <- df %>% 
  select(subject, treatment, screentype, screen, time, chosen)


subjects <- df %>% ungroup() %>% select(subject,screen) %>% distinct()
times <- data.frame(subject = rep(subjects$subject,200), screen=subjects$screen) %>% 
  arrange(subject,screen) %>% 
  as_tibble()
times <- data.frame(subject = times$subject, screen=times$screen, time=1:200) %>% 
  as_tibble()
rm(subjects)

df_all <- df_all %>%
  mutate(time=ceiling(time/100)) %>% 
  right_join(times, by=c("time", "subject","screen")) %>% 
  group_by(subject,screen) %>% 
  arrange(subject, screen, time)

df_all <- df_all %>% 
  ungroup() %>% 
  group_by(subject, screen) %>%
  mutate(chosen = na.locf(chosen, na.rm = FALSE),
         treatment = na.locf(treatment, na.rm = FALSE),
         treatment = na.locf(treatment, na.rm = FALSE, fromLast = TRUE),
         screentype = na.locf(screentype, na.rm = FALSE),
         screentype = na.locf(screentype, na.rm = FALSE, fromLast = TRUE)
  ) %>% 
  mutate(level = "All clicks")

## merging first click only and all clicks
df <- bind_rows(df_1,df_all)


# data used for plotting
df_all_plots <- df %>% 
  group_by(time, subject, level, treatment, screentype, chosen, .drop = F) %>% 
  tally() %>% 
  filter(!is.na(chosen)) %>% 
  ungroup() %>% 
  group_by(time, screentype, treatment, subject) %>% 
  mutate(share = n/sum(n)) %>%
  filter(!is.nan(share)) 



### 1: T-T; 3vs3

measure1 <- df_all_plots %>% 
  filter(screentype != "2 options") %>% 
  filter(chosen == "Target") %>% 
  # pivoting to wider to make difference by subject
  select(-n) %>% 
  pivot_wider(names_from = screentype, values_from = share) %>% 
  # omitting subject that did not make a choice in one of the two scenarios
  filter(!is.na(`3 options noCS`)) %>% 
  filter(!is.na(`3 options CS`)) %>% 
  mutate(diff = `3 options CS` - `3 options noCS`) %>% 
  group_by(time, level, treatment, .drop = F) %>% 
  summarise(mean = mean(diff, na.rm = TRUE),
            sd = sd(diff, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) 

p1 <- measure1 %>% 
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1.5)+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_linetype_manual(name = "", values = c("solid", "twodash")) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  facet_wrap(~treatment, nrow = 1)+
  labs(y = "Difference in choice share", x = "Seconds",
       title = "3vs3")+
  theme_ipsum()+
  coord_cartesian(ylim = c(-0.25, 0.3))+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(), 
        plot.title.position = "plot",
        plot.background = element_rect(fill = "white", color = "white"))


### 1: T-T; 3vs2

measure2 <- df_all_plots %>% 
  filter(screentype != "3 options noCS") %>% 
  filter(chosen == "Target") %>% 
  # pivoting to wider to make difference by subject
  select(-n) %>% 
  pivot_wider(names_from = screentype, values_from = share) %>% 
  # omitting subject that did not make a choice in one of the two scenarios
  filter(!is.na(`2 options`)) %>% 
  filter(!is.na(`3 options CS`)) %>% 
  mutate(diff = `3 options CS` - `2 options`) %>% 
  group_by(time, level, treatment, .drop = F) %>% 
  summarise(mean = mean(diff, na.rm = TRUE),
            sd = sd(diff, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) 

p2 <- measure2 %>% 
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1.5)+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_color_manual(name = "", values = "black")+
  scale_linetype_manual(name = "", values = c("solid", "twodash")) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  facet_wrap(~treatment, nrow = 1)+
  labs(y = "Difference in choice share", x = "Seconds",
       title = "3vs2")+
  theme_ipsum()+
  coord_cartesian(ylim = c(-0.25, 0.3))+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(), 
        plot.title.position = "plot",
        plot.background = element_rect(fill = "white", color = "white"),
        strip.background = element_blank(),
        strip.text = element_blank())

p1/p2 + plot_layout(guides = "collect") & theme(legend.position = "bottom",
                                                legend.margin = margin(0,0,0,0),
                                                plot.margin = unit(c(0,0,0,0), 'cm'),
                                                legend.text = element_text(size = 15))

ggsave("Figures/Figure_A3.png", width = 16/1.6, height = 12/1.6, units = "in", dpi = 300)


### 2. by markup, merging treatments

# importing the markup info per screen
all <- read_csv("Data/alldata_exp1.csv")

markup <- all %>% 
  select(screen, markup) %>% 
  distinct() %>% 
  mutate %>% 
  mutate(markupF = cut(markup, breaks = c(0, 0.87, 0.97, 1.03, 1.06, 2), 
                       labels = c("15% cheaper", "5% cheaper", "Same price", 
                                  "5% more expensive", "15% more expensive")))

# joining markup and determining the right comparisons
df <- df %>% 
  left_join(markup, by = "screen") %>% 
  ungroup()


# add another factor to identify the comparisons
# that allow us to net out the effect of markup
# that is, we compare T and C at the SAME level of price relative to each other
# example
# "15% more" = Target & T15% more expensive vs Competitor & T15% less expensive


df_all_plots <- df %>% 
  group_by(time, subject, markupF, level, screentype, chosen, .drop = F) %>% 
  tally() %>% 
  filter(!is.na(chosen)) %>% 
  ungroup() %>% 
  group_by(time, screentype, markupF, subject) %>% 
  mutate(share = n/sum(n)) %>%
  filter(!is.nan(share)) 



### 1: T-T; 3vs3

measure1 <- df_all_plots %>% 
  filter(screentype != "2 options") %>% 
  filter(chosen == "Target") %>% 
  # pivoting to wider to make difference by subject
  select(-n) %>% 
  pivot_wider(names_from = screentype, values_from = share) %>% 
  # omitting subject that did not make a choice in one of the two scenarios
  filter(!is.na(`3 options noCS`)) %>% 
  filter(!is.na(`3 options CS`)) %>% 
  mutate(diff = `3 options CS` - `3 options noCS`) %>% 
  group_by(time, level, markupF, .drop = F) %>% 
  summarise(mean = mean(diff, na.rm = TRUE),
            sd = sd(diff, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) 

p1 <- measure1 %>% 
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1.5)+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_linetype_manual(name = "", values = c("solid", "twodash")) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  facet_wrap(~markupF, nrow = 1)+
  labs(y = "Difference in choice share", x = "Seconds",
       title = "3vs3")+
  theme_ipsum()+
  coord_cartesian(ylim = c(-0.25, 0.3))+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(), 
        plot.title.position = "plot",
        plot.background = element_rect(fill = "white", color = "white"))


### 1: T-T; 3vs2

measure2 <- df_all_plots %>% 
  filter(screentype != "3 options noCS") %>% 
  filter(chosen == "Target") %>% 
  # pivoting to wider to make difference by subject
  select(-n) %>% 
  pivot_wider(names_from = screentype, values_from = share) %>% 
  # omitting subject that did not make a choice in one of the two scenarios
  filter(!is.na(`2 options`)) %>% 
  filter(!is.na(`3 options CS`)) %>% 
  mutate(diff = `3 options CS` - `2 options`) %>% 
  group_by(time, level, markupF, .drop = F) %>% 
  summarise(mean = mean(diff, na.rm = TRUE),
            sd = sd(diff, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) 

p2 <- measure2 %>% 
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1.5)+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_linetype_manual(name = "", values = c("solid", "twodash")) +
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  facet_wrap(~markupF, nrow = 1)+
  labs(y = "Difference in choice share", x = "Seconds",
       title = "3vs2")+
  theme_ipsum()+
  coord_cartesian(ylim = c(-0.25, 0.3))+
  theme(legend.position = "none",
        panel.grid.minor = element_blank(), 
        plot.title.position = "plot",
        plot.background = element_rect(fill = "white", color = "white"),
        strip.background = element_blank(),
        strip.text = element_blank())

p1/p2 + plot_layout(guides = "collect") & theme(legend.position = "bottom",
                                                legend.margin = margin(0,0,0,0),
                                                plot.margin = unit(c(0,0,0,0), 'cm'),
                                                legend.text = element_text(size = 15))


ggsave("Figures/Figure_A4.png", width = 16/1.6, height = 12/1.6, units = "in", dpi = 300)