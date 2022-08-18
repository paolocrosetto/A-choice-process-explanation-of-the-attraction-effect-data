## re-importing data to get the screen markups
all <- read_csv("Data/alldata_exp1.csv")

markup <- all %>% 
  select(screen, markup) %>% 
  distinct() %>% 
  mutate %>% 
  mutate(markupF = cut(markup, breaks = c(0, 0.87, 0.97, 1.03, 1.06, 2), 
                       labels = c("15% cheaper", "5% cheaper", "Same price", 
                                  "5% more expensive", "15% more expensive")))

rm(all)

# joining markup and determining the right comparisons
df <- df %>% 
  left_join(markup, by = "screen") %>% 
  ungroup()

## generate the data to be plotted: target, competitor and decoy
plotme <- df %>% 
  group_by(time, level,  markupF, subject, chosen, .drop = F) %>% 
  tally() %>% 
  filter(!is.na(chosen)) %>% 
  ungroup() %>% 
  group_by(time, level, markupF, subject) %>% 
  mutate(share = n/sum(n)) %>%
  filter(!is.nan(share)) %>% 
  group_by(time, markupF, level, chosen, .drop = F) %>% 
  summarise(mean = mean(share, na.rm = TRUE),
            sd = sd(share, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) %>% 
  filter(!is.na(time)) %>% 
  mutate(expected = 0.5) %>% 
  mutate(level = as.factor(level),
         level = fct_relevel(level, "First click")) %>% 
  mutate(comparisons = case_when(chosen == "Target" & markupF == "15% cheaper" ~ "15% cheaper",
                                 chosen == "Competitor" & markupF == "15% more expensive" ~ "15% cheaper",
                                 chosen == "Target" & markupF == "5% cheaper" ~ "5% cheaper",
                                 chosen == "Competitor" & markupF == "5% more expensive" ~ "5% cheaper",
                                 markupF == "Same price" ~ "Same price",
                                 chosen == "Target" & markupF == "5% more expensive" ~ "5% more expensive",
                                 chosen == "Competitor" & markupF == "5% cheaper" ~ "5% more expensive",
                                 chosen == "Target" & markupF == "15% more expensive" ~ "15% more expensive",
                                 chosen == "Competitor" & markupF == "15% cheaper" ~ "15% more expensive"
  )) %>% 
  mutate(comparisons = fct_relevel(comparisons, "15% cheaper", "5% cheaper", "Same price", "5% more expensive"))

plotme <- plotme %>% 
  mutate(comparisons = fct_relevel(comparisons, "15% cheaper", "5% cheaper", "Same price", "5% more expensive"))

## plot: target, competitor and decoy
p1 <- plotme %>% 
  filter(chosen != "Decoy") %>% 
  filter(!is.na(level)) %>% 
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, color = chosen, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1)+
  geom_hline(aes(yintercept = expected), color='grey60', linetype='dashed')+
  scale_color_manual(name = "", values = c("#4DAF4A", "#377EB8"))+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_linetype_manual(name = "", values = c("twodash", "solid"))+
  labs(y = "Choice Share", x = "Seconds", 
       title = "")+
  coord_cartesian(ylim = c(0,1))+
  facet_grid(.~comparisons)+
  theme_ipsum()+
  theme(legend.position = "bottom",
        panel.grid.minor = element_blank(), 
        plot.title.position = "plot",
        plot.background = element_rect(fill = "white", color = "white"),
        plot.title = element_markdown(size = 14),
        strip.text = element_text(face = "bold", size = 13),
        # this part here below deletes stuff to better blend when pasted with diff plot
        axis.text.x = element_blank(),
        axis.title.x = element_blank(),
        plot.margin = unit(c(0,0,0.5,0), 'cm'))

## generate the data to be plotted: difference target/competitor
plotme_diff <- plotme %>%  
  filter(!is.na(level)) %>% 
  ungroup() %>% 
  filter(chosen != "Decoy") %>% 
  select(-markupF) %>% 
  group_by(level, comparisons) %>% 
  select(time, chosen, level, mean, ci, comparisons) %>% 
  pivot_wider(names_from = chosen, values_from = c(mean, ci)) %>% 
  mutate(mean = mean_Target - mean_Competitor, 
         ci = ci_Target)

## plot: difference target/competitor
p2 <- plotme_diff %>%
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, group = level, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1)+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_linetype_manual(name = "", values = c("twodash", "solid"))+
  scale_color_manual(name = "", values = "black")+
  geom_hline(yintercept = 0, color = "red", linetype = "dashed")+
  labs(y = "Difference", x = "Seconds")+
  coord_cartesian(ylim = c(-0.25,0.5))+
  facet_grid(.~comparisons)+
  theme_ipsum()+
  theme(legend.position = "bottom",
        panel.grid.minor = element_blank(),
        plot.title.position = "plot",
        plot.background = element_rect(fill = "white", color = "white"),
        plot.title = element_markdown(size = 22),
        strip.text = element_blank(),
        strip.background = element_blank(),
        plot.margin = unit(c(0,0,0,0), 'cm'))

## putting it all together
p1/p2 + plot_layout(heights = c(2.2,1), guides = "collect") & 
  theme(legend.position = "bottom", legend.margin = margin(0,0,0,0),
        legend.text = element_text(size = 15))

# saving the picture
ggsave("Figures/Figure_5.png", width = 16/1.6, height = 9/1.6, units = "in", dpi = 300)
