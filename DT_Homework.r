## homework
data("flights")
data("airlines")
data("airports")

## transform nycflights13

library(nycflights13)

library(tidyverse) # dplyr

## ark 5 question about this DataSets

## select filter arrange mutate summarize count to make question and answer

?flights

# Example Q : most 5 flight carrier in Sep 2013
flights %>%
  filter(month == 9, year == 2013) %>%
  count(carrier) %>%
  arrange(desc(n)) %>%
  head(5) %>% # top 5
  left_join(airlines)

# Q1 : show carriers delay stats
flights %>%
  select(carrier,arr_delay) %>%
  filter(arr_delay < 0) %>% # get delay only
  group_by(carrier) %>%
  summarise(delay_count = n(),
            avg_delay = mean(arr_delay) ,
            med_delay = median(arr_delay),
            mosted_delayed = min(arr_delay),
            least_delay = max(arr_delay)) %>%
  arrange(desc(delay_count)) %>%
  inner_join(airlines, by="carrier")

# Q2 : % delay

f_delay <- flights %>%
  select(carrier,arr_delay) %>%
  filter(arr_delay < 0) %>% # get delay only
  group_by(carrier) %>%
  summarise(delay_count = n())
  
flights %>%
  select(carrier,arr_delay) %>%
  group_by(carrier) %>%
  summarise(full_count = n()) %>%
  inner_join(f_delay, by="carrier") %>%
  mutate(pct_delay = delay_count/full_count *100) %>%
  arrange(desc(pct_delay)) %>%
  select(carrier,pct_delay ,full_count) %>%
  inner_join(airlines, by="carrier") %>%
  head(5)

# Q3 : show carriers distance stats

flights %>%
  select(carrier , distance) %>%
  group_by(carrier) %>%
  summarise(avg_dis = mean(distance) ,
            med_dis = median(distance),
            shortest_dis = min(distance),
            longest_dis = max(distance),
            count = n(),) %>%
  arrange(med_dis) %>%
  inner_join(airlines, by="carrier")

# Q4 : long distance carriers and delay

q3 <- flights %>%
  select(carrier,arr_delay) %>%
  group_by(carrier) %>%
  summarise(full_count = n()) %>%
  inner_join(f_delay, by="carrier") %>%
  mutate(pct_delay = delay_count/full_count *100) %>%
  arrange(desc(pct_delay)) %>%
  select(carrier,pct_delay ,full_count)

flights %>%
  select(carrier , distance) %>%
  group_by(carrier) %>%
  summarise(med_dis = median(distance)) %>%
  filter(med_dis > 1000) %>%
  inner_join(q3 ,by="carrier") %>%
  select(carrier,med_dis,pct_delay) %>%
  arrange(desc(pct_delay)) %>%
  inner_join(airlines, by="carrier")

# Q5 : What is the most common flight destination from JFK? (Top 5)
flights %>%
  select(origin , dest) %>%
  filter(origin == "JFK") %>%
  count(dest) %>%
  arrange(desc(n)) %>%
  inner_join(airports, by=c("dest"="faa")) %>%
  select(dest,name,n) %>%
  head(5)

  