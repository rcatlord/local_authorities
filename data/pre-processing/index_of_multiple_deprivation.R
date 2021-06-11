# Indices of Deprivation 2019 (England)
# Source: Ministry of Housing, Communities and Local Government
# URL: https://www.gov.uk/government/statistics/english-indices-of-deprivation-2019

library(tidyverse) ; library(httr) ; library(readxl)

tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/833995/File_10_-_IoD2019_Local_Authority_District_Summaries__lower-tier__.xlsx",
    write_disk(tmp))
df <- read_xlsx(tmp, sheet = "IMD") %>% 
  select(area_code = `Local Authority District code (2019)`,
         area_name = `Local Authority District name (2019)`,
         `IMD - Rank of average score`,
         `IMD - Proportion of LSOAs in most deprived 10% nationally`) %>% 
  pivot_longer(-c(area_code, area_name), names_to = "group", values_to = "value") %>% 
  mutate(group = str_remove_all(group, "IMD - "),
         indicator = "Index of Multiple Deprivation 2019",
         measure = case_when(group == "Rank of average score" ~ "Rank",
                             group == "Proportion of LSOAs in most deprived 10% nationally" ~ "Percentage")) %>% 
  select(area_code, area_name, indicator, group, measure, value)
  
write_csv(df, "../indicators/index_of_multiple_deprivation.csv")

