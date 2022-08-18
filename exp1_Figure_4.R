
## generate the data to be plotted: target, competitor and decoy

plotme <- df %>% 
  group_by(time, level, treatment, subject, chosen, .drop = F) %>% 
  tally() %>% 
  filter(!is.na(chosen)) %>% 
  ungroup() %>% 
  group_by(time, level, subject, treatment) %>% 
  mutate(share = n/sum(n)) %>%
  filter(!is.nan(share)) %>% 
  group_by(time, level, treatment, chosen, .drop = F) %>% 
  summarise(mean = mean(share, na.rm = TRUE),
            sd = sd(share, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) %>% 
  mutate(expected = 0.5) %>% 
  mutate(level = as.factor(level),
         level = fct_relevel(level, "First click"))

## generate the data to be plotted: difference target/competitor
plotme_diff <- df %>%
  group_by(time, level, treatment, subject, chosen, .drop = F) %>%
  tally() %>%
  filter(!is.na(chosen)) %>%
  group_by(time, level, treatment, subject) %>%
  mutate(share = n/sum(n)) %>%
  filter(!is.nan(share)) %>%
  select(-n) %>%
  pivot_wider(names_from = chosen, values_from = share) %>%
  mutate(diff = Target - Competitor) %>%
  group_by(time, level, treatment, .drop = F) %>%
  summarise(mean = mean(diff, na.rm = TRUE),
            sd = sd(diff, na.rm = TRUE),
            n = n(),
            se = sd/sqrt(n()),
            confintmult = qt(.95/2 + .5, n()),
            ci = se*confintmult) %>% 
  mutate(level = as.factor(level),
         level = fct_relevel(level, "First click"))

## plot: target - competitor - decoy

p1 <- plotme %>% 
  mutate(ci = if_else(level == "All clicks", ci, NA_real_)) %>% 
  ggplot(aes(time, mean, color = chosen, linetype = level))+
  geom_errorbar(width = 0.25, aes(ymin=mean-ci, ymax=mean+ci), size = 0.3, alpha = 0.2)+
  geom_line(size=1)+
  geom_hline(aes(yintercept = expected), color='grey60', linetype='dashed')+
  scale_color_brewer(name = "", palette= "Set1", direction = -1)+
  scale_y_continuous(labels = scales::percent)+
  scale_x_continuous(labels = scales::trans_breaks(function(x) x/10, function(x) x/1),
                     limits = c(0,200))+
  scale_linetype_manual(name = "", values = c("twodash", "solid"))+
  labs(y = "Choice Share", x = "Seconds", 
       title = "")+
  coord_cartesian(ylim = c(0,0.7))+
  facet_grid(.~treatment)+
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
        plot.margin = unit(c(0,0,0.5,0), 'cm')
  )

## plot: difference

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
  facet_wrap(~treatment, nrow = 1)+
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

## saving the figure
ggsave("Figures/Figure_4.png", width = 16/1.6, height = 9/1.6, units = "in", dpi = 300)