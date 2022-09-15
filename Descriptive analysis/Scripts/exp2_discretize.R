
# discretize: first click
df_1 <- df %>% 
  filter(choiceno == 1) %>% 
  select(subject, type, screen, time, chosen)


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
         type = na.locf(type, na.rm = FALSE),
         type = na.locf(type, na.rm = FALSE, fromLast = TRUE)
  ) %>% 
  mutate(level = "First click")



# discretize: all clicks
df_all <- df %>% 
  select(subject, type, screen, time, chosen)


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
         type = na.locf(type, na.rm = FALSE),
         type = na.locf(type, na.rm = FALSE, fromLast = TRUE)
  ) %>% 
  mutate(level = "All clicks")


## merging first click only and all clicks
df <- bind_rows(df_1,df_all)