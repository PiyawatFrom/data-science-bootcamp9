## HW 2 - restaurant pizza SQL
## create 3-5 tables =>  write table into server

library(RPostgreSQL)
library(tidyverse)

p_orders <- read_csv("pizza_orders.csv")
p_menus <- read_csv("pizza_menus.csv")
p_cus <- read_csv("pizza_res_customers.csv")

## create connection
con <- dbConnect(
  PostgreSQL(), # What SQL server u use
  host = "arjuna.db.elephantsql.com", # server
  dbname = "snxkebes", # User & Default database
  user = "snxkebes", # User & Default database
  password = "*********",
  port = 5432 # for PostgreSQL
)

## db List Tables
dbListTables(con)

## write table
dbWriteTable(con, "customers" , p_cus)
dbWriteTable(con, "orders" , p_orders)
dbWriteTable(con, "menus" , p_menus)

## disconnect
dbDisconnect(con)

rm(p_cus)
rm(p_menus)
rm(p_orders)

## get table from server
customers <- dbGetQuery(con, "select id , name , gender from customers")
menus <- dbGetQuery(con, "select id , name , price from menus")
orders <- dbGetQuery(con, "select id , cus_id , food_id, portion from orders")

## tibble change
cus_tib <- as_tibble(customers)
menus_tib <- as_tibble(menus)
order_tib <- as_tibble(orders)

## join
full_trans <- order_tib %>%
  inner_join(cus_tib, by = c("cus_id"="id")) %>%
  inner_join(menus_tib, by = c("food_id"="id"))

colnames(full_trans)[5] <- "cus_name"
colnames(full_trans)[7] <- "food_name"

full_trans

## Q1 : Top 3 customers that make us the most income
full_trans %>%
  mutate(total = portion*price) %>%
  group_by(cus_name) %>%
  summarise(total_spend = sum(total)) %>%
  arrange(desc(total_spend)) %>%
  head(3)

## Q2 : The top 5 most popular food orders
full_trans %>%
  group_by(food_name) %>%
  summarise(totol_dish = sum(portion)) %>%
  arrange(desc(totol_dish)) %>%
  head(5)

## Q3 : The most popular food for men and women
tb1 <- full_trans %>%
  filter(gender == "male") %>%
  group_by(food_name) %>%
  summarise(totol_dish = sum(portion)) %>%
  arrange(desc(totol_dish)) %>%
  head(1)

tb1["gender"] <- "male"

tb2 <- full_trans %>%
  filter(gender == "female") %>%
  group_by(food_name) %>%
  summarise(totol_dish = sum(portion)) %>%
  arrange(desc(totol_dish)) %>%
  head(1)

tb2["gender"] <- "female"

rbind(tb1,tb2)
