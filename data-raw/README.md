# data-raw/: building the data

Scripts that download the raw data and turn it into the finished tables in `data/`. **Run them in order, from the project root.** Only the data owner needs to run `01_download_wdi.R`; everyone else can run 02-04, or just pull the finished files.

| Step | Script | Does | Output |
|---|---|---|---|
| 1 | `01_download_wdi.R` | Downloads World Bank indicators (only missing ones, unless `refresh <- TRUE`) | `data-raw/<name>.csv` |
| 1b | `01b_external_data.R` | Cleans SWIID, World Happiness Report and V-Dem into iso3c + year | `data-raw/external/clean/*.csv` |
| 2 | `02_clean_join.R` | Joins everything, drops regional aggregates | `data/wdi_clean.rds` / `.csv` |
| 3 | `03_summaries.R` | Data dictionary, decade averages, group trends | `data/indicator_info.csv`, `country_period.rds`, `group_trends.rds` |
| 4 | `04_changes_scores.R` | 2000s → 2010s changes; actual vs expected scores | `data/country_change.rds`, `country_scores.rds` |

```r
source("data-raw/01_download_wdi.R")
source("data-raw/01b_external_data.R")
source("data-raw/02_clean_join.R")
source("data-raw/03_summaries.R")
source("data-raw/04_changes_scores.R")
```

## Sources

| Source | Where it comes from | Variables |
|---|---|---|
| **World Bank WDI** | Downloaded by `01_download_wdi.R` (R package `WDI`) | 24 indicators: income, health, education, spending, aid, FDI, Gini, HIV, resource rents, test scores |
| **SWIID v9.92** | `external/swiid9_92.rda` (download from Frederick Solt's SWIID site / Harvard Dataverse) | `swiid_gini` (disposable income), `swiid_gini_mkt` (market income) |
| **World Happiness Report 2026** | `external/WHR26_Data_Figure_2.1.xlsx` (worldhappiness.report) | `happiness` (life evaluation, 0-10, 3-year average) |
| **V-Dem** | R package `vdemdata`: `remotes::install_github("vdeminstitute/vdemdata")` | `democracy`, `health_equality`, `educ_equality`, `corruption` |

Not available from the World Bank API (tested Nov 2026): UHC service coverage index, Government effectiveness. V-Dem's health equality and corruption cover the same ideas.

## Add a new indicator

1. **World Bank:** add `name = "CODE"` to `indicators` in `01_download_wdi.R`.
   **Other source:** add a section to `01b_external_data.R` that writes `external/clean/<source>.csv` with columns `iso3c, year, <variables>`.
2. Add one row per new variable to the dictionary (`tribble`) in `03_summaries.R`. The script stops with an error if you forget.
3. Run steps 2-4. The new variable appears in every app dropdown automatically.

## Notes

- Country names from SWIID and WHR are converted to ISO codes with `countrycode`. Historical or disputed entities (Soviet Union, Yugoslavia, Czechoslovakia, North Cyprus, Somaliland) are dropped; the scripts print which.
- Never edit files in `external/` or the downloaded CSVs by hand: change the scripts instead.
