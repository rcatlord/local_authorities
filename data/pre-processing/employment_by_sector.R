# Employment by sector (2019)
# Source: ONS Business Register and Employment Survey
# URL: https://www.nomisweb.co.uk/datasets/newbres6pub

library(tidyverse)

df <- read_csv("http://www.nomisweb.co.uk/api/v01/dataset/NM_189_1.data.csv?geography=1811939329...1811939332,1811939334...1811939336,1811939338...1811939428,1811939436...1811939442,1811939768,1811939769,1811939443...1811939497,1811939499...1811939501,1811939503,1811939505...1811939507,1811939509...1811939517,1811939519,1811939520,1811939524...1811939570,1811939575...1811939599,1811939601...1811939628,1811939630...1811939634,1811939636...1811939647,1811939649,1811939655...1811939664,1811939667...1811939680,1811939682,1811939683,1811939685,1811939687...1811939704,1811939707,1811939708,1811939710,1811939712...1811939717,1811939719,1811939720,1811939722...1811939730&date=latest&industry=163577857...163577874&employment_status=1&measure=2&measures=20100&select=geography_code,geography_name,industry_name,obs_value") %>% 
  rename(area_code = GEOGRAPHY_CODE, area_name = GEOGRAPHY_NAME, group = INDUSTRY_NAME, value = OBS_VALUE) %>% 
  mutate(group = str_remove(group, "\\s*\\([^\\)]+\\)"),
         group = str_remove(group, "(\\s+[A-Za-z]+)?[0-9-]+"),
         group = str_remove(group, "[[:punct:]]"),
         group = str_trim(group),
         group = case_when(group == "Transport & storage (H)" ~ "Transport & storage", TRUE ~ group),
         indicator = "Employment by sector",
         measure = "Percentage") %>% 
  select(area_code, area_name, indicator, group, measure, value)

write_csv(df, "../indicators/employment_by_sector.csv")
