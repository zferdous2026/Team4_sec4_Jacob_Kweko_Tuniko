# 02_clean_join.R
# Purpose: Combine every raw WDI indicator CSV into one clean country-year dataset
# Input:   data-raw/<indicator>.csv (written by 01_download_wdi.R)
# Output:  data/wdi_clean.csv and data/wdi_clean.rds
# Run from the project root, after 01_download_wdi.R.

library(dplyr)
library(readr)
library(purrr)

# Every indicator CSV in data-raw/ (the file name is the indicator column name)
files      <- list.files("data-raw", pattern = "\\.csv$", full.names = TRUE)
indicators <- tools::file_path_sans_ext(basename(files))

# Keep real countries only: drop regional / income-group aggregates
# (e.g. "World", "High income"), which have region "Aggregates" or no region
# and sometimes a blank iso3c that would break the join
read_countries <- function(path) {
  read_csv(path, show_col_types = FALSE) %>%
    filter(!is.na(region), region != "Aggregates", !is.na(iso3c))
}

# Read each file, keeping only the join keys and its indicator column
indicator_data <- map2(files, indicators, \(path, var) {
  read_countries(path) %>% select(iso3c, year, all_of(var))
})

# Country metadata (same in every file, so take it from the first one)
country_info <- read_countries(files[1]) %>%
  distinct(iso3c, country, iso2c, region, income, lending, capital, longitude, latitude)
stopifnot(!anyDuplicated(country_info$iso3c))

# Join all indicators on country code + year
wdi_clean <- indicator_data %>%
  reduce(full_join, by = c("iso3c", "year")) %>%
  left_join(country_info, by = "iso3c") %>%
  relocate(country, iso2c, iso3c, region, income, lending, capital,
           longitude, latitude, year) %>%
  arrange(country, year)

# Basic checks
stopifnot(!anyDuplicated(wdi_clean[c("iso3c", "year")]))
message(n_distinct(wdi_clean$iso3c), " countries, ",
        min(wdi_clean$year), "-", max(wdi_clean$year), ", ",
        length(indicators), " indicators")

# Save: CSV for sharing, RDS keeps column types for R
dir.create("data", showWarnings = FALSE)
write_csv(wdi_clean, "data/wdi_clean.csv")
saveRDS(wdi_clean, "data/wdi_clean.rds")
