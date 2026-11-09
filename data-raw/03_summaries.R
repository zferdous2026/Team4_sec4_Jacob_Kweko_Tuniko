# 03_summaries.R
# =============================================================================
# Purpose: Build the small, app-ready tables the Shiny app reads at startup,
#          so no heavy data work happens while the app is running.
#
# Input:   data/wdi_clean.rds (written by 02_clean_join.R)
#          -> every country, every year, 20 indicators (14,322 rows)
#
# Output:  data/indicator_info.csv
#            The data dictionary: one row per indicator with its label, unit,
#            World Bank code, theme and how much data exists for it.
#            Used for dropdowns, axis labels and the Data & Methods page.
#
#          data/country_period.rds
#            One row per country per decade, each indicator averaged over the
#            decade. Used for cross-country comparisons ("is A related to B?"):
#            scatter plots, correlations, the theme pages.
#
#          data/group_trends.rds
#            Yearly medians for income groups, regions and the whole world.
#            Used for line charts over time (Trends page, Forecast page).
#
# Run from the project root, after 02_clean_join.R.
# Pipeline: 01_download_wdi.R -> 02_clean_join.R -> 03_summaries.R -> app.R
# =============================================================================

library(dplyr)   # data wrangling: mutate, filter, group_by, summarise, joins
library(tidyr)   # reshaping: pivot_longer (wide table -> long table)
library(readr)   # write_csv
library(tibble)  # tribble: type a small table row by row

# Load the master dataset (one row per country per year)
wdi <- readRDS("data/wdi_clean.rds")

# The order income groups should appear in (legends, tables, facets).
# Without this, R sorts them alphabetically: High, Low, Lower middle, Upper middle.
income_levels <- c("Low income", "Lower middle income",
                   "Upper middle income", "High income")


# =============================================================================
# 1. INDICATOR METADATA (the data dictionary)
# =============================================================================
# This is the only part of the script typed by hand. Each row describes one
# indicator. Change a label here and it changes everywhere in the app.
#
# Columns:
#   variable          column name in the data (must match exactly)
#   label             short readable name for dropdowns and axis titles
#   unit              unit shown on axes and in tooltips
#   source            where the data comes from (shown on the Data & Methods page)
#   code              the indicator's code in that source (World Bank code,
#                     SWIID / V-Dem variable name)
#   theme             topic group used for the dropdowns in the app
#   log_scale         TRUE if values are very skewed (a few countries are far
#                     larger than the rest), so a log axis is the better default
#   forecastable      TRUE if the data is complete enough for the Forecast page
#   higher_is_better  TRUE / FALSE sets the colour direction on maps
#                     (e.g. green = good); NA if the indicator is neutral

indicator_info <- tribble(
  ~variable,          ~label,                         ~unit,                    ~source,       ~code,                  ~theme,         ~log_scale, ~forecastable, ~higher_is_better,
  # Inequality and poverty
  "gini_index",       "Gini index (World Bank)",      "0-100",                  "World Bank",  "SI.POV.GINI",          "Inequality",   FALSE,      FALSE,         FALSE,
  "swiid_gini",       "Gini index (SWIID, disposable income)", "0-100",         "SWIID",       "gini_disp",            "Inequality",   FALSE,      FALSE,         FALSE,
  "swiid_gini_mkt",   "Gini index (SWIID, market income)", "0-100",             "SWIID",       "gini_mkt",             "Inequality",   FALSE,      FALSE,         FALSE,
  "pov_headcount",    "Poverty headcount ($3.00/day)", "% of population",       "World Bank",  "SI.POV.DDAY",          "Inequality",   FALSE,      FALSE,         FALSE,
  # Health
  "life_expect",      "Life expectancy",              "years",                  "World Bank",  "SP.DYN.LE00.IN",       "Health",       FALSE,      TRUE,          TRUE,
  "infant_mort",      "Infant mortality",             "per 1,000 live births",  "World Bank",  "SP.DYN.IMRT.IN",       "Health",       TRUE,       TRUE,          FALSE,
  "under5_mort",      "Under-5 mortality",            "per 1,000 live births",  "World Bank",  "SH.DYN.MORT",          "Health",       TRUE,       TRUE,          FALSE,
  "health_spend",     "Health spending",              "% of GDP",               "World Bank",  "SH.XPD.CHEX.GD.ZS",    "Health",       FALSE,      FALSE,         NA,
  "oop_health",       "Out-of-pocket health spending", "% of health spending",  "World Bank",  "SH.XPD.OOPC.CH.ZS",    "Health",       FALSE,      FALSE,         FALSE,
  "hiv_prev",         "HIV prevalence",               "% of people 15-49",      "World Bank",  "SH.DYN.AIDS.ZS",       "Health",       TRUE,       FALSE,         FALSE,
  # Education
  "gross_prim_enrol", "Primary enrollment (gross)",   "% of age group",         "World Bank",  "SE.PRM.ENRR",          "Education",    FALSE,      FALSE,         TRUE,
  "gross_sec_enrol",  "Secondary enrollment (gross)", "% of age group",         "World Bank",  "SE.SEC.ENRR",          "Education",    FALSE,      FALSE,         TRUE,
  "prim_comp_rate",   "Primary completion rate",      "% of age group",         "World Bank",  "SE.PRM.CMPT.ZS",       "Education",    FALSE,      FALSE,         TRUE,
  "edc_spending",     "Education spending",           "% of GDP",               "World Bank",  "SE.XPD.TOTL.GD.ZS",    "Education",    FALSE,      FALSE,         NA,
  "adlt_liter",       "Adult literacy rate",          "% of people 15+",        "World Bank",  "SE.ADT.LITR.ZS",       "Education",    FALSE,      FALSE,         TRUE,
  "test_scores",      "Harmonized test scores",       "score (300-625)",        "World Bank",  "HD.HCI.HLOS",          "Education",    FALSE,      FALSE,         TRUE,
  # Economy and the state
  "gdp_per_capita",   "GDP per capita",               "constant 2015 US$",      "World Bank",  "NY.GDP.PCAP.KD",       "Economy",      TRUE,       TRUE,          TRUE,
  "gdp_growth",       "GDP growth",                   "annual %",               "World Bank",  "NY.GDP.MKTP.KD.ZG",    "Economy",      FALSE,      FALSE,         TRUE,
  "tax_revenue",      "Tax revenue",                  "% of GDP",               "World Bank",  "GC.TAX.TOTL.GD.ZS",    "Economy",      FALSE,      FALSE,         NA,
  "gov_rev_nogrant",  "Government revenue (excl. grants)", "% of GDP",          "World Bank",  "GC.REV.XGRT.GD.ZS",    "Economy",      FALSE,      FALSE,         NA,
  "gov_expense",      "Government expense",           "% of GDP",               "World Bank",  "GC.XPN.TOTL.GD.ZS",    "Economy",      FALSE,      FALSE,         NA,
  "aid_received_gni", "Aid received (net ODA)",       "% of GNI",               "World Bank",  "DT.ODA.ODAT.GN.ZS",    "Economy",      FALSE,      FALSE,         NA,
  "fdi",              "FDI, net inflows",             "% of GDP",               "World Bank",  "BX.KLT.DINV.WD.GD.ZS", "Economy",      FALSE,      FALSE,         NA,
  "resource_rents",   "Natural resource rents",       "% of GDP",               "World Bank",  "NY.GDP.TOTL.RT.ZS",    "Economy",      FALSE,      FALSE,         NA,
  # Population
  "total_pop",        "Population",                   "people",                 "World Bank",  "SP.POP.TOTL",          "Population",   TRUE,       TRUE,          NA,
  "urban_pop",        "Urban population",             "% of total population",  "World Bank",  "SP.URB.TOTL.IN.ZS",    "Population",   FALSE,      TRUE,          NA,
  # Wellbeing
  "happiness",        "Life evaluation (happiness)",  "0-10 ladder score",      "World Happiness Report", "Life evaluation", "Wellbeing", FALSE,   FALSE,         TRUE,
  # Institutions
  "democracy",        "Electoral democracy",          "index 0-1",              "V-Dem",       "v2x_polyarchy",        "Institutions", FALSE,      FALSE,         TRUE,
  "health_equality",  "Health equality",              "index (higher = more equal)", "V-Dem",  "v2pehealth",           "Institutions", FALSE,      FALSE,         TRUE,
  "educ_equality",    "Educational equality",         "index (higher = more equal)", "V-Dem",  "v2peedueq",            "Institutions", FALSE,      FALSE,         TRUE,
  "corruption",       "Political corruption",         "index 0-1 (higher = more corrupt)", "V-Dem", "v2x_corr",        "Institutions", FALSE,      FALSE,         FALSE
)

# --- Find the indicator columns in the data ---------------------------------
# wdi_clean has two kinds of columns:
#   ID columns        say WHICH row it is (country, year, region, ...)
#   indicator columns hold the MEASUREMENTS (gini_index, life_expect, ...)
# setdiff(a, b) = "everything in a that is not in b". So this takes all
# column names and leaves out the 10 ID names, giving the indicator names.
# Nothing is deleted from the data: `indicators` is just a list of names we
# use below to tell each step which columns to calculate with.
# If a new indicator is added to 01_download_wdi.R, it appears here automatically.
id_cols    <- c("country", "iso2c", "iso3c", "region", "income", "lending",
                "capital", "longitude", "latitude", "year")
indicators <- setdiff(names(wdi), id_cols)

# Safety check: every indicator in the data must have exactly one row in the
# dictionary above (and vice versa). If someone adds an indicator to the
# download but forgets to describe it here, the script stops with an error
# instead of silently producing an incomplete dictionary.
stopifnot(setequal(indicators, indicator_info$variable),
          !anyDuplicated(indicator_info$variable))

# --- Reshape to long format -------------------------------------------------
# pivot_longer turns the wide table (one column per indicator) into a long
# table (one row per country + year + indicator):
#
#   wide:  iso3c year gini_index infant_mort     long:  iso3c year variable    value
#          GHA   2015 43.5       41.2        ->         GHA   2015 gini_index  43.5
#                                                       GHA   2015 infant_mort 41.2
#
# In long format we can summarise all 20 indicators at once with
# group_by(variable), instead of writing the same code 20 times.
# filter(!is.na(value)) keeps only years where a value was actually measured.
wdi_long <- wdi %>%
  select(iso3c, year, all_of(indicators)) %>%
  pivot_longer(all_of(indicators), names_to = "variable", values_to = "value") %>%
  filter(!is.na(value))

# --- Coverage statistics ----------------------------------------------------
# For each indicator: how much data actually exists? Shown on the
# Data & Methods page so readers can see which variables are sparse.
coverage <- wdi_long %>%
  group_by(variable) %>%
  summarise(
    first_year     = min(year),            # earliest year with any data
    last_year      = max(year),            # latest year with any data
    n_countries    = n_distinct(iso3c),    # countries with at least one value
    # % of all possible country-years in 2010-2019 that have a value
    # (217 countries x 10 years = 2,170 possible values).
    # between() is inside sum(), so it only COUNTS 2010s rows; nothing is filtered.
    coverage_2010s = round(100 * sum(between(year, 2010, 2019)) /
                             (n_distinct(wdi$iso3c) * 10), 1),
    # % of all possible country-years in the whole dataset (1960-2025) that
    # have a value (217 countries x 66 years = 14,322 possible values).
    # Lower than coverage_2010s for every indicator because early decades have
    # little data, and it penalises series that started late (e.g. health
    # spending only begins in 2000).
    coverage_full  = round(100 * n() /
                             (n_distinct(wdi$iso3c) * n_distinct(wdi$year)), 1),
    .groups = "drop"
  )

# Add the coverage columns to the dictionary (matched by variable name)
indicator_info <- indicator_info %>% left_join(coverage, by = "variable")


# =============================================================================
# 2. COUNTRY x DECADE AVERAGES
# =============================================================================
# Why: our research questions compare countries ("do countries with higher X
# have higher Y?"), so we need ONE value per country. But many indicators are
# only measured every few years (Gini, poverty and literacy come from household
# surveys). If we picked a single year, most countries would have no value.
# Averaging over a decade means one or two measurements anywhere in the decade
# are enough -> Gini goes from a few dozen countries in a single year to 160
# countries in the 2010s. It also smooths out volatile indicators like GDP growth.
# Trade-off: values in a decade may come from different years.
#
# Result: one row per country per decade, all 20 indicators as columns.

# Helper: mean of the values that exist, or NA if there are none.
mean_or_na <- function(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)

country_period <- wdi %>%
  # Assign each year to its decade.
  # floor(2017 / 10) * 10 = floor(201.7) * 10 = 2010
  # The label is "2010-2019"; the 2020s are "2020-2025" because the data stops there.
  mutate(
    decade = floor(year / 10) * 10,
    period = if_else(decade == 2020, "2020-2025",
                     paste0(decade, "-", decade + 9))
  ) %>%
  # One group per country per decade. Only these columns are kept in the
  # output (summarise keeps the grouping columns + what it calculates), so
  # year, iso2c, capital, lending, longitude and latitude are dropped here.
  group_by(iso3c, country, region, income, period) %>%
  # across() applies mean_or_na to every indicator column at once:
  # 10 yearly rows become 1 row of decade averages.
  # .groups = "drop" removes the grouping afterwards so it doesn't affect later steps.
  summarise(across(all_of(indicators), mean_or_na), .groups = "drop") %>%
  # Make income a factor (a category with a fixed order) so it sorts Low -> High
  mutate(income = factor(income, levels = income_levels)) %>%
  arrange(country, period)


# =============================================================================
# 3. GROUP TRENDS OVER TIME
# =============================================================================
# Why: to show how TYPES of countries changed over time (e.g. "has the gap in
# child mortality between low- and high-income countries narrowed?"), we
# summarise countries into groups, year by year.
#
# Groups are the World Bank's own classifications (from extra = TRUE in the
# download):
#   Income group  4 groups based on GNI per capita (Low, Lower middle,
#                 Upper middle, High income)
#   Region        7 geographic regions (e.g. Sub-Saharan Africa)
#   World         all 217 countries together
# Note: each country keeps its CURRENT classification for every year
# (e.g. South Korea counts as "High income" in 1960 too).
#
# For each group, indicator and year we calculate:
#   median       the middle country (not the mean, so one extreme country
#                can't distort the group)
#   p25, p75     25th and 75th percentiles: the range of the middle half of
#                countries, for a shaded band around the line on charts
#   n_countries  how many countries had data that year

# Attach each country's region and income group to the long table
with_groups <- wdi_long %>%
  left_join(distinct(wdi, iso3c, region, income), by = "iso3c")

# A function so the same calculation can run for any grouping (income,
# region, world) without writing it three times.
#   group_type  a label for the kind of grouping, e.g. "Income group"
#   group_col   which column to group by. {{ group_col }} ("curly-curly")
#               lets us pass a bare column name like `income` into dplyr.
summarise_group <- function(data, group_type, group_col) {
  data %>%
    mutate(group_type = group_type, group = {{ group_col }}) %>%
    filter(!is.na(group)) %>%
    group_by(group_type, group, variable, year) %>%
    summarise(
      median      = median(value),
      p25         = quantile(value, 0.25),
      p75         = quantile(value, 0.75),
      n_countries = n(),          # n() = number of rows (countries) in the group
      .groups = "drop"
    )
}

# Total number of countries in each group (whether or not they have data).
# Needed to calculate what share of a group reported in a given year.
group_sizes <- bind_rows(
  wdi %>% distinct(iso3c, income) %>% count(group = income, name = "n_in_group") %>%
    mutate(group_type = "Income group"),
  wdi %>% distinct(iso3c, region) %>% count(group = region, name = "n_in_group") %>%
    mutate(group_type = "Region"),
  tibble(group = "World", n_in_group = n_distinct(wdi$iso3c), group_type = "World")
)

# Run the summary three times and stack the results into one table.
# For "World" we pass a constant "World" instead of a column, so every
# country lands in the same group.
group_trends <- bind_rows(
  summarise_group(with_groups, "Income group", income),
  summarise_group(with_groups, "Region",       region),
  summarise_group(with_groups, "World",        "World")
) %>%
  left_join(group_sizes, by = c("group_type", "group")) %>%
  # Share of the group's countries that had data that year. If only 5 of 25
  # low-income countries reported, the median is unreliable and the app can
  # hide that year (e.g. when pct_reporting < 50).
  mutate(pct_reporting = round(100 * n_countries / n_in_group, 1)) %>%
  arrange(group_type, group, variable, year)


# =============================================================================
# CHECKS AND SAVE
# =============================================================================

# Each country must appear exactly once per decade; if a join went wrong and
# created duplicate rows, stop here instead of saving bad data.
stopifnot(!anyDuplicated(country_period[c("iso3c", "period")]))

# Print a short summary so you can see the script worked
message("indicator_info: ", nrow(indicator_info), " indicators")
message("country_period: ", nrow(country_period), " rows (",
        n_distinct(country_period$iso3c), " countries x ",
        n_distinct(country_period$period), " decades)")
message("group_trends:   ", nrow(group_trends), " rows")

# The dictionary is saved as CSV so it can be opened and read in Excel.
# The other two are RDS so they keep column types (e.g. the income factor
# order) and load quickly in R.
write_csv(indicator_info, "data/indicator_info.csv")
saveRDS(country_period,   "data/country_period.rds")
saveRDS(group_trends,     "data/group_trends.rds")
