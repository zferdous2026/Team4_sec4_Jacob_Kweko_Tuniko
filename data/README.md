# data/: finished data (read by the app and the notebooks)

Everything here is **built by the scripts in `data-raw/`**. Never edit these files by hand; change the script and re-run it.

| File | One row per | Built by | Used by |
|---|---|---|---|
| `wdi_clean.rds` / `.csv` | country × year (217 countries, 1960-2025, 31 indicators from all four sources) | `02_clean_join.R` | Explorer, World Map, download button |
| `indicator_info.csv` | indicator (31): label, unit, source, code, theme, log scale, coverage | `03_summaries.R` | Every page (dropdowns, labels), Data & Methods |
| `country_period.rds` | country × decade (decade averages) | `03_summaries.R` | Evidence pages, notebooks |
| `group_trends.rds` | group × indicator × year (medians for income groups, regions, world) | `03_summaries.R` | Trends & Forecast |
| `country_change.rds` | country: 2000s vs 2010s (`<var>_2000s`, `<var>_2010s`, `d_<var>`, `pct_<var>`) | `04_changes_scores.R` | Over Time |
| `country_scores.rds` | country × outcome: actual vs expected from GDP, `score` (+ = better) | `04_changes_scores.R` | Beating Expectations |
| `forecast_results.rds` | list: group forecasts to 2035, back-test scores, variable importance | `analysis/forecast.Rmd` | Forecast & Models |

## Load in R

```r
cp     <- readRDS("data/country_period.rds")
d2010s <- subset(cp, period == "2010-2019")
info   <- read.csv("data/indicator_info.csv")
```

`.rds` keeps column types (e.g. the Low → High order of income groups); `.csv` is for sharing with people who don't use R.

## Things to know

- **Income groups and regions** are the World Bank's current classification, applied to every year.
- **Decade averages** use whatever years have data in that decade; sparse indicators (Gini, test scores) may rest on one or two values.
- **`happiness`** is already a 3-year average (World Happiness Report).
- **`corruption`** is higher = MORE corrupt; for most other indicators higher = better (see `higher_is_better`).
