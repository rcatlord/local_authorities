library(tidyverse) ; library(httr) ; library(readxl) ;  library(sf)

# Levelling Up Fund priority categories
# Source: HM Treasury
# URL: https://www.gov.uk/government/publications/levelling-up-fund-prospectus
tmp <- tempfile(fileext = ".xlsx")
GET(url = "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/966137/Levelling_Up_Fund_list_of_local_authorities_by_priority_category.xlsx",
    write_disk(tmp))
priority_categories <- read_xlsx(tmp, sheet = 1) %>% 
  rename(country = Country, area_name = Name, category = `Priority category`) %>% 
  mutate(area_name = case_when(area_name == "Rhondda Cynon Taff" ~ "Rhondda Cynon Taf", TRUE ~ area_name))

# Local authority districts (England, Scotland, Wales)
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-december-2020-uk-bgc
local_authority_districts <- st_read("https://opendata.arcgis.com/datasets/db23041df155451b9a703494854c18c4_0.geojson") %>% 
  select(area_code = LAD20CD, area_name = LAD20NM) %>% 
  filter(!str_detect(area_code, "^N")) # exclude Northern Ireland

# Regions (England)
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-district-to-region-april-2019-lookup-in-england
regions <- read_csv("https://opendata.arcgis.com/datasets/3ba3daf9278f47daba0f561889c3521a_0.csv") %>% 
  select(area_code = LAD19CD, region = RGN19NM)

# join and write datasets
priority_places <- left_join(local_authority_districts, priority_categories, by = "area_name") %>% 
  left_join(regions, by = "area_code") %>% 
  mutate(region = case_when(str_detect(country, "^S") ~ "Scotland",
                            str_detect(country, "^W") ~ "Wales",
                            TRUE ~ region)) %>% 
  relocate("region", .before = "country")

st_write(priority_places, "../../app/data/priority_places.geojson")
