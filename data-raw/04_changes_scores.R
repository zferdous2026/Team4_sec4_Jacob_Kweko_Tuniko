# 04_changes_scores.R
# =============================================================================
# Purpose: Build the two tables for the "Over Time" and "Beating Expectations"
#          pages, so the app doesn't have to calculate them while running.
#
# Input:   data/country_period.rds (written by 03_summaries.R)
# Output:  data/country_change.rds  one row per country: 2000s vs 2010s
#          data/country_scores.rds  one row per country per outcome:
#                                   actual vs expected-from-GDP
# Run from the project root, after 03_summaries.R.
# =============================================================================

library(dplyr)
library(tidyr)
library(purrr)   # pmap: run a function once per row of a table

country_period <- readRDS("data/country_period.rds")
info           <- read.csv("data/indicator_info.csv", stringsAsFactors = FALSE)
indicators     <- info$variable
id_cols        <- c("iso3c", "country", "region", "income")


# =============================================================================
# 1. CHANGES: 2000s -> 2010s  (questions E1-E5)
# =============================================================================
# For every indicator and country:
#   <var>_2000s   decade average 2000-2009
#   <var>_2010s   decade average 2010-2019
#   d_<var>       absolute change (2010s minus 2000s), e.g. Gini points
#   pct_<var>     % change, for indicators where proportional change is the
#                 fair comparison (mortality: 100 -> 50 and 10 -> 5 are the
#                 same improvement). NA if a value is zero or negative.
# Why 2000s -> 2010s: health spending only starts in 2000, and Gini coverage
# is best in these decades.

before <- "2000-2009"
after  <- "2010-2019"

wide <- country_period %>%
  filter(period %in% c(before, after)) %>%
  mutate(period = if_else(period == before, "2000s", "2010s")) %>%
  pivot_wider(id_cols = all_of(id_cols), names_from = period,
              values_from = all_of(indicators), names_sep = "_")

country_change <- wide
for (var in indicators) {
  old <- wide[[paste0(var, "_2000s")]]
  new <- wide[[paste0(var, "_2010s")]]
  country_change[[paste0("d_", var)]]   <- new - old
  country_change[[paste0("pct_", var)]] <- if_else(old > 0 & new > 0, 100 * (new / old - 1), NA_real_)
}


# =============================================================================
# 2. BEATING EXPECTATIONS: actual vs expected from GDP  (questions F1-F7, H2)
# =============================================================================
# For each outcome (2010s averages):
#   1. fit the typical relationship between the outcome and log GDP per capita
#   2. expected = what a country "should" have at its income level
#   3. score    = how far it is above (+) or below (-) that, always oriented so
#                 POSITIVE = BETTER than expected
# Mortality is modelled on a log scale (proportional differences), so its
# score is in log points; exp(score) - 1 is roughly "% lower than expected".
#
# Small states (under 1 million people) are flagged and left out of the fit:
# their statistics are often unusual (e.g. students schooled across a border
# distort enrollment). Their scores are still calculated, so the app can show
# or hide them.

outcomes <- tribble(
  ~outcome,          ~log_scale, ~higher_is_better,
  "life_expect",     FALSE,      TRUE,
  "under5_mort",     TRUE,       FALSE,
  "infant_mort",     TRUE,       FALSE,
  "prim_comp_rate",  FALSE,      TRUE,
  "gross_sec_enrol", FALSE,      TRUE,
  "test_scores",     FALSE,      TRUE,
  "happiness",       FALSE,      TRUE
)

decade <- country_period %>%
  filter(period == after, !is.na(gdp_per_capita)) %>%
  mutate(small_state = !is.na(total_pop) & total_pop < 1e6)

score_outcome <- function(outcome, log_scale, higher_is_better) {
  data <- decade %>%
    filter(!is.na(.data[[outcome]])) %>%
    mutate(y = if (log_scale) log(.data[[outcome]]) else .data[[outcome]],
           log_gdp = log(gdp_per_capita))

  fit <- lm(y ~ log_gdp, data = filter(data, !small_state))
  predicted <- predict(fit, newdata = data)

  data %>%
    transmute(
      across(all_of(id_cols)), small_state,
      outcome   = outcome,
      gdp_per_capita,
      actual    = .data[[outcome]],
      expected  = if (log_scale) exp(predicted) else predicted,
      score     = (if (higher_is_better) 1 else -1) * (y - predicted),
      r_squared = summary(fit)$r.squared   # share of the outcome GDP explains
    )
}

country_scores <- outcomes %>%
  pmap(score_outcome) %>%
  bind_rows()


# =============================================================================
# CHECKS AND SAVE
# =============================================================================
stopifnot(!anyDuplicated(country_change$iso3c),
          !anyDuplicated(country_scores[c("iso3c", "outcome")]))

message("country_change: ", nrow(country_change), " countries, ",
        sum(!is.na(country_change$d_swiid_gini)), " with a SWIID Gini change")
country_scores %>%
  group_by(outcome) %>%
  summarise(countries = n(), gdp_explains = paste0(round(100 * first(r_squared)), "%")) %>%
  print()

saveRDS(country_change, "data/country_change.rds")
saveRDS(country_scores, "data/country_scores.rds")
