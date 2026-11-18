# Variables: what each page can work with

Every variable in the project, grouped by the page it fits best. **Any page can use any variable**: the groups are a starting point, not a rule.

- **Name** is the column name to use in code and in figures (`x = "gini_index"`).
- **Countries** = how many countries have at least one value (1960-2025). **2010s coverage** = share of country-years in 2010-2019 with data: below ~40%, decade averages rest on few values and fewer countries.
- **(log scale)**: very skewed; use a log axis (`scale_x_log10()` / `scale_y_log10()`).
- The full list with years and codes is `data/indicator_info.csv`. Ideas for questions: [`question_bank.md`](question_bank.md).

## Outcomes (the things we try to explain; use on any page)

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `life_expect` | Life expectancy | years | World Bank | 217 | 100% |
| `infant_mort` | Infant mortality (log scale) | per 1,000 live births | World Bank | 196 | 90.3% |
| `under5_mort` | Under-5 mortality (log scale) | per 1,000 live births | World Bank | 196 | 90.3% |
| `prim_comp_rate` | Primary completion rate | % of age group | World Bank | 198 | 63.9% |
| `gross_prim_enrol` | Primary enrollment (gross) | % of age group | World Bank | 209 | 76.9% |
| `gross_sec_enrol` | Secondary enrollment (gross) | % of age group | World Bank | 208 | 67.6% |
| `test_scores` | Harmonized test scores | score (300-625) | World Bank | 169 | 19.4% |
| `adlt_liter` | Adult literacy rate | % of people 15+ | World Bank | 170 | 21.4% |
| `happiness` | Life evaluation (happiness) | 0-10 ladder score | World Happiness Report | 164 | 56.6% |

Health: `life_expect`, `infant_mort`, `under5_mort`. Education: `prim_comp_rate`, `gross_prim_enrol`, `gross_sec_enrol`, `test_scores`, `adlt_liter` (sparse). Wellbeing: `happiness`. `hiv_prev` is a health condition, mainly useful to explain underperformers.

## 1. Wealth

How much does national income explain? Plus any outcome above.

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `gdp_per_capita` | GDP per capita (log scale) | constant 2015 US$ | World Bank | 213 | 96.6% |
| `gdp_growth` | GDP growth | annual % | World Bank | 214 | 96.8% |
| `total_pop` | Population (log scale) | people | World Bank | 217 | 100% |
| `urban_pop` | Urban population | % of total population | World Bank | 217 | 100% |

## 2. Inequality (Jacob)

Income inequality and poverty. Plus any outcome above.

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `gini_index` | Gini index (World Bank) | 0-100 | World Bank | 171 | 38.5% |
| `swiid_gini` | Gini index (SWIID, disposable income) | 0-100 | SWIID | 194 | 75% |
| `swiid_gini_mkt` | Gini index (SWIID, market income) | 0-100 | SWIID | 194 | 75% |
| `pov_headcount` | Poverty headcount ($3.00/day) | % of population | World Bank | 171 | 38.5% |

## 3. Public Spending

What governments collect and spend. Plus any outcome above.

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `health_spend` | Health spending | % of GDP | World Bank | 193 | 87.9% |
| `oop_health` | Out-of-pocket health spending | % of health spending | World Bank | 193 | 87.9% |
| `edc_spending` | Education spending | % of GDP | World Bank | 203 | 72.5% |
| `tax_revenue` | Tax revenue | % of GDP | World Bank | 161 | 63.6% |
| `gov_rev_nogrant` | Government revenue (excl. grants) | % of GDP | World Bank | 162 | 63.6% |
| `gov_expense` | Government expense | % of GDP | World Bank | 161 | 63.6% |

## 4. Foreign Money

Money from abroad, and natural resources. Plus any outcome above.

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `fdi` | FDI, net inflows | % of GDP | World Bank | 203 | 90.2% |
| `aid_received_gni` | Aid received (net ODA) | % of GNI | World Bank | 162 | 63.5% |
| `resource_rents` | Natural resource rents | % of GDP | World Bank | 214 | 96.3% |

## 5. Wellbeing

Happiness (and the outcomes above). Plus any outcome above.

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `happiness` | Life evaluation (happiness) | 0-10 ladder score | World Happiness Report | 164 | 56.6% |

## 6. Institutions

V-Dem measures of how the state works. Plus any outcome above.

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `democracy` | Electoral democracy | index 0-1 | V-Dem | 175 | 80.6% |
| `health_equality` | Health equality | index (higher = more equal) | V-Dem | 175 | 80.6% |
| `educ_equality` | Educational equality | index (higher = more equal) | V-Dem | 175 | 80.6% |
| `corruption` | Political corruption | index 0-1 (higher = more corrupt) | V-Dem | 175 | 80.6% |

## Other health variable

| Variable | What it is | Unit | Source | Countries | 2010s coverage |
|---|---|---|---|---|---|
| `hiv_prev` | HIV prevalence (log scale) | % of people 15-49 | World Bank | 153 | 69.8% |

## Columns in every data file

| Column | What it is |
|---|---|
| `iso3c` | 3-letter country code (e.g. `GHA`). Use it for `exclude = c(...)` |
| `country` | Country name |
| `region` | World Bank region (7) |
| `income` | World Bank income group: Low, Lower middle, Upper middle, High (ordered) |
| `period` | Decade, e.g. `"2010-2019"` (`country_period.rds`) |
| `year` | Year (`wdi_clean.rds`, `group_trends.rds`) |

## Which data file for which page

| File | One row per | Variables | Pages |
|---|---|---|---|
| `country_period.rds` | country × decade | all variables above, as decade averages | 1-6 (the `d` your chart receives is the 2010s rows) |
| `wdi_clean.rds` | country × year | all variables above, yearly | Forecast, Explorer, Map, any time-series graph |
| `country_change.rds` | country | `<var>_2000s`, `<var>_2010s`, `d_<var>` (change), `pct_<var>` (% change) for every variable | Over Time |
| `country_scores.rds` | country × outcome | `outcome`, `actual`, `expected` (from log GDP), `score` (> 0 = better than income predicts), `r_squared`, `small_state` | Beating Expectations |
| `group_trends.rds` | group × variable × year | `median`, `p25`, `p75`, `n_countries`, `pct_reporting` for income groups, regions and the world | Forecast, trend graphs |
| `forecast_results.rds` | (list) | group forecasts to 2035, back-test scores, variable importance | Forecast |

### Over Time (`country_change.rds`)

Every variable above has four columns, e.g. for `under5_mort`: `under5_mort_2000s`, `under5_mort_2010s`, `d_under5_mort` (2010s minus 2000s) and `pct_under5_mort` (% change; use for mortality and GDP).

### Beating Expectations (`country_scores.rds`)

Outcomes with scores: `life_expect`, `under5_mort`, `infant_mort`, `prim_comp_rate`, `gross_sec_enrol`, `test_scores`, `happiness`. Join with `country_period.rds` (2010s) on `iso3c` to compare scores with any variable above.

### Forecast & Models

Yearly series from `wdi_clean.rds`; variables marked forecastable (long, complete series): `life_expect`, `infant_mort`, `under5_mort`, `gdp_per_capita`, `total_pop`, `urban_pop`.
