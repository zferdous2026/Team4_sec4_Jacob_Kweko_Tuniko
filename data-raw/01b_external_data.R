# 01b_external_data.R
# =============================================================================
# Purpose: Clean the three non-World Bank datasets into the same shape
#          (one row per country-year, keyed by iso3c + year) so 02_clean_join.R
#          can join them onto the World Bank data.
#
# Input:   data-raw/external/swiid9_92.rda               SWIID v9.92 (Solt)
#          data-raw/external/WHR26_Data_Figure_2.1.xlsx  World Happiness Report 2026
#          vdemdata R package                            V-Dem (installed from GitHub)
# Output:  data-raw/external/clean/swiid.csv
#          data-raw/external/clean/whr.csv
#          data-raw/external/clean/vdem.csv
#
# Run from the project root, after 01_download_wdi.R.
#
# One-time setup (V-Dem is not on CRAN):
#   install.packages("remotes")
#   remotes::install_github("vdeminstitute/vdemdata")
# =============================================================================

library(dplyr)
library(readr)
library(countrycode)

dir.create("data-raw/external/clean", showWarnings = FALSE, recursive = TRUE)

# Country names differ between sources; countrycode converts them to ISO codes.
# custom_match handles names countrycode doesn't know.
# Names set to NA are dropped on purpose: they would otherwise be matched to
# another country's code and duplicate it ("Soviet Union" -> Russia,
# "North Cyprus" -> Cyprus).
to_iso3 <- function(names) {
  countrycode(names, "country.name", "iso3c", warn = FALSE,
              custom_match = c("Kosovo" = "XKX", "Micronesia" = "FSM",
                               "Soviet Union" = NA, "North Cyprus" = NA))
}

report_unmatched <- function(data, source) {
  unmatched <- unique(data$name[is.na(data$iso3c)])
  if (length(unmatched) > 0) {
    message(source, ": dropped ", length(unmatched), " names without an ISO code: ",
            paste(unmatched, collapse = ", "))
  }
}


# -----------------------------------------------------------------------------
# 1. SWIID: Standardized World Income Inequality Database (Frederick Solt)
# -----------------------------------------------------------------------------
# Why: World Bank Gini values are sparse and mix income-based and
# consumption-based surveys. SWIID harmonises them into one comparable series
# for most countries and years. Values are estimates with uncertainty
# (gini_disp_se); cite: Solt, F. (2020). Social Science Quarterly 101(3).
#
# swiid_gini     = Gini of disposable income (after taxes and transfers), 0-100
# swiid_gini_mkt = Gini of market income (before taxes and transfers), 0-100

swiid_env <- new.env()
load("data-raw/external/swiid9_92.rda", envir = swiid_env)

swiid <- as.data.frame(swiid_env$swiid_summary) %>%
  transmute(name = country, year,
            swiid_gini = gini_disp, swiid_gini_mkt = gini_mkt) %>%
  mutate(iso3c = to_iso3(name))
report_unmatched(swiid, "SWIID")

swiid %>%
  filter(!is.na(iso3c)) %>%
  select(iso3c, year, swiid_gini, swiid_gini_mkt) %>%
  write_csv("data-raw/external/clean/swiid.csv")


# -----------------------------------------------------------------------------
# 2. World Happiness Report 2026 (Gallup World Poll)
# -----------------------------------------------------------------------------
# happiness = average answer to "imagine a ladder from 0 (worst possible life)
# to 10 (best possible life): where do you stand?" Each value is a 3-year
# average ending in `Year` (e.g. 2025 = surveys from 2023-2025).
# The "Explained by:" columns are the WHR's own model, which already uses GDP
# and life expectancy, so we deliberately do NOT use them (that would be circular).

whr <- readxl::read_excel("data-raw/external/WHR26_Data_Figure_2.1.xlsx", sheet = 1) %>%
  transmute(name = `Country name`, year = as.integer(Year),
            happiness = `Life evaluation (3-year average)`) %>%
  mutate(iso3c = to_iso3(name))
report_unmatched(whr, "WHR")

whr %>%
  filter(!is.na(iso3c), !is.na(happiness)) %>%
  select(iso3c, year, happiness) %>%
  write_csv("data-raw/external/clean/whr.csv")


# -----------------------------------------------------------------------------
# 3. V-Dem: Varieties of Democracy (University of Gothenburg)
# -----------------------------------------------------------------------------
# Expert-coded measures of political institutions. Cite: Coppedge et al.,
# V-Dem Dataset (current version, see vdemdata::vdem documentation).
#
# democracy        v2x_polyarchy  electoral democracy index, 0-1
# health_equality  v2pehealth     is basic healthcare guaranteed to all? (higher = more equal)
# educ_equality    v2peedueq      is basic education guaranteed to all? (higher = more equal)
# corruption       v2x_corr       political corruption index, 0-1 (higher = MORE corrupt)
# V-Dem's country_text_id is (almost always) the ISO3 code.

vdemdata::vdem %>%
  filter(year >= 1960) %>%
  transmute(iso3c = country_text_id, year,
            democracy = v2x_polyarchy, health_equality = v2pehealth,
            educ_equality = v2peedueq, corruption = v2x_corr) %>%
  write_csv("data-raw/external/clean/vdem.csv")

message("External data cleaned: data-raw/external/clean/")
