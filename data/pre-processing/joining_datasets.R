library(tidyverse)

df <- list.files(path = "~/Documents/projects/levelling-up/data/indicators", pattern = "*.csv") %>% 
  map_df(~read_csv(.))

write_csv(df, "../../app/data/indicators.csv")


