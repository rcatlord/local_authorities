# Brexit vote
# Source: Electoral Commission
# URL: https://www.electoralcommission.org.uk/who-we-are-and-what-we-do/elections-and-referendums/past-elections-and-referendums/eu-referendum/results-and-turnout-eu-referendum

library(tidyverse)

df <- read_csv("https://www.electoralcommission.org.uk/sites/default/files/2019-07/EU-referendum-result-data.csv") %>% 
  rename(area_code = `Area_Code`, area_name = Area, value = Pct_Leave) %>% 
  filter(!area_name == "Gibraltar") %>% 
  mutate(indicator = "Voted leave in EU referendum",
         group = NA,
         measure = "Percentage") %>% 
  select(area_code, area_name, indicator, group, measure, value)

write_csv(df, "../indicators/eu_referendum.csv")
