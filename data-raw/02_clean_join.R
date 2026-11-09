# 02_clean_join.R
# Purpose: Combine every raw indicator into one clean country-year dataset
# Input:   data-raw/<indicator>.csv           (written by 01_download_wdi.R)
#          data-raw/external/clean/<source>.csv (written by 01b_external_data.R)
# Output:  data/wdi_clean.csv and data/wdi_clean.rds
#          (still called "wdi_clean" so nothing else breaks, but it now also
#          contains the SWIID, World Happiness Report and V-Dem columns)
# Run from the project root, after 01_download_wdi.R and 01b_external_data.R.

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

# Add the external datasets (SWIID, World Happiness Report, V-Dem).
# left_join keeps only our 217 World Bank countries and their years; external
# rows for other places (e.g. historical countries) are dropped.
external_files <- list.files("data-raw/external/clean", pattern = "\\.csv$", full.names = TRUE)
for (path in external_files) {
  external <- read_csv(path, show_col_types = FALSE)
  stopifnot(!anyDuplicated(external[c("iso3c", "year")]))
  matched <- n_distinct(intersect(external$iso3c, wdi_clean$iso3c))
  message(basename(path), ": matched ", matched, " countries")
  wdi_clean <- left_join(wdi_clean, external, by = c("iso3c", "year"))
}

# Basic checks
stopifnot(!anyDuplicated(wdi_clean[c("iso3c", "year")]))
message(n_distinct(wdi_clean$iso3c), " countries, ",
        min(wdi_clean$year), "-", max(wdi_clean$year), ", ",
        ncol(wdi_clean) - 10, " indicators")

# Save: CSV for sharing, RDS keeps column types for R
dir.create("data", showWarnings = FALSE)
write_csv(wdi_clean, "data/wdi_clean.csv")
saveRDS(wdi_clean, "data/wdi_clean.rds")
