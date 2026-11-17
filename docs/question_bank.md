# Question bank

Every question the app had before the pages were reset to blank templates, plus the extra questions from the notebooks, with the graph that could answer each. **Use it for ideas**: pick, change or ignore any of them when you write your own page.

- **"r"** = Spearman correlation across countries (2010s averages). **"beyond GDP"** = the same after removing the effect of income (partial correlation). Numbers are preliminary: re-check them before using them.
- The code for every question marked with a figure number (1.1, 2.1, …) is still in that page's notebook in `analysis/`.
- **Graph types:** you write every graph yourself in your page file with `plot = function(d) { ggplot(...) }` (see `R/page_story.R`). For a scatter, copy Jacob's chart from `R/page_inequality.R`.
- Variables: see [`variables.md`](variables.md).

## Central question (draft)

> Beyond national wealth, what is linked to better health, education and wellbeing (inequality, public spending, foreign money, or institutions), and do these links hold when we follow countries over time?

---

## 1. Wealth (the baseline)

**Page question:** How much of the difference in health, education and wellbeing does national income explain?

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 1.1 | Do richer countries live longer? | Scatter (log x) | `gdp_per_capita` → `life_expect` | r = 0.87 (213 countries); gains level off among rich countries (Preston curve) |
| 1.2 | Does income matter as much for schooling? | Scatter (log x) | `gdp_per_capita` → `prim_comp_rate` | r = 0.60 (186), weaker than for health |
| 1.3 | How much of each outcome does income explain? | Bar chart (R² per outcome) | `country_scores.rds` → `r_squared` | 72-77% of health, 74% of happiness, 38% of primary completion |
| extra | Do richer countries have lower inequality? | Scatter | `gdp_per_capita` → `swiid_gini` | |
| extra | Do richer countries collect more tax? | Scatter | `gdp_per_capita` → `tax_revenue` | |
| extra | Does income predict secondary enrollment and test scores? | Scatter | `gdp_per_capita` → `gross_sec_enrol`, `test_scores` | |

## 2. Inequality (Jacob)

**Page question:** Are more unequal countries worse off, even at similar income levels?

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| **Jacob** | **Do more unequal countries have higher infant mortality?** | **Scatter (log y), and the same split by income group** | **`swiid_gini` → `infant_mort`** (his original: `gini_index`) | **SWIID: r = 0.60 (178), 0.50 beyond GDP; by income: high 0.66, upper-middle 0.44, lower-middle 0.32, low ~0. World Bank Gini: r = 0.45 (160). Kept on the page.** |
| 2.1 | Same with the SWIID Gini and under-5 mortality | Scatter (log y) | `swiid_gini` → `under5_mort` | r = 0.60 (178), 0.52 beyond GDP |
| 2.2 | Is the link the same at every income level? | Scatter split by income group | `swiid_gini` → `under5_mort` | high 0.66, upper-middle 0.46, lower-middle 0.36, low ~0 |
| 2.3 | Is inequality linked to less schooling? | Scatter | `swiid_gini` → `prim_comp_rate` | r = -0.25, but -0.06 beyond GDP |
| extra | Inequality vs life expectancy, secondary enrollment | Scatter | `swiid_gini` → `life_expect`, `gross_sec_enrol` | |
| extra | Do more unequal countries spend less on health or education? | Scatter | `swiid_gini` → `health_spend`, `edc_spending` | |
| extra | Inequality vs poverty and growth | Scatter | `swiid_gini` → `pov_headcount`, `gdp_growth` | |

## 3. Public Spending

**Page question:** Do countries that spend more on health and education get better outcomes, beyond what their income predicts?

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 3.1 | Does more health spending go with fewer child deaths? | Scatter (log y), toggle by income | `health_spend` → `under5_mort` | r = -0.41 (192), -0.28 beyond GDP |
| 3.2 | Is education spending linked to completion? | Scatter, toggle by income | `edc_spending` → `prim_comp_rate` | r = 0.21 (174), 0.15 beyond GDP; 0.50 in lower-middle income |
| 3.3 | Does it matter who pays (families vs the state)? | Scatter (log y) | `oop_health` → `under5_mort` | r = 0.38, but 0.00 beyond GDP |
| extra | Health spending vs life expectancy | Scatter | `health_spend` → `life_expect` | |
| extra | Education spending vs secondary enrollment and test scores | Scatter | `edc_spending` → `gross_sec_enrol`, `test_scores` | |
| extra | Do states that collect more tax spend more on health? | Scatter | `tax_revenue` → `health_spend` | |

## 4. Foreign Money

**Page question:** Are foreign direct investment and development aid linked to better health?

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 4.1 | Is foreign investment linked to life expectancy? | Scatter, financial hubs excluded (`exclude = c("MLT","CYP","IRL","LUX","NLD","CYM","HKG","SGP")`) | `fdi` → `life_expect` | r = 0.01 (194): no link |
| 4.2 | Does aid go with lower child mortality? | Scatter (log y) | `aid_received_gni` → `under5_mort` | r = 0.51 (aid goes to poorer countries), -0.01 beyond GDP |
| extra | Does FDI go to countries with more educated populations? | Scatter | `gross_sec_enrol` → `fdi` | |
| extra | Do countries receiving more aid collect less tax? | Scatter | `aid_received_gni` → `tax_revenue` | |
| extra | Aid vs primary completion | Scatter | `aid_received_gni` → `prim_comp_rate` | |

## 5. Wellbeing

**Page question:** Beyond income, are healthier and more equal countries happier?

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| **Jacob** | **Do countries with more equal healthcare report higher happiness?** | **Box plot of happiness by thirds of health equality; toggle splits by income group** | **`health_equality` → `happiness`** | **r = 0.68 (162); median happiness 6.3 (most equal third) vs 4.4 (least equal third). On the Wellbeing page.** |
| 5.1 | Are richer countries happier? | Scatter (log x) | `gdp_per_capita` → `happiness` | r = 0.85 (164) |
| 5.2 | Are healthier countries happier, even at similar incomes? | Scatter | `life_expect` → `happiness` | r = 0.81, 0.20 beyond GDP |
| 5.3 | Are more unequal countries less happy? | Scatter, toggle by income | `swiid_gini` → `happiness` | r = -0.45, only -0.09 beyond GDP |
| extra | Is corruption linked to lower happiness? | Scatter | `corruption` → `happiness` | |
| extra | Which countries are happier than their income predicts? | Expectations chart | `country_scores.rds`, outcome `happiness` | |

## 6. Institutions

**Page question:** Do institutions, such as healthcare that reaches everyone, explain more than income inequality?

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 6.1 | Where healthcare reaches everyone, do fewer children die? | Scatter (log y), toggle by income | `health_equality` → `under5_mort` | r = -0.84 (174), -0.50 beyond GDP: the strongest link found |
| 6.2 | Does equal healthcare explain part of the inequality link? | Bar chart (two regression coefficients) | `log(under5_mort) ~ log(gdp_per_capita) + swiid_gini (+ health_equality)` | Gini coefficient 0.040 → 0.030 |
| extra | Democracy vs life expectancy | Scatter | `democracy` → `life_expect` | |
| extra | Educational equality vs primary completion | Scatter | `educ_equality` → `prim_comp_rate` | |
| extra | Corruption vs child mortality | Scatter | `corruption` → `under5_mort` | |

## 7. Over Time

**Page question:** Did countries that reduced inequality, or spent more on health, improve faster between the 2000s and the 2010s?

Data: `country_change.rds` (`d_<var>` = change, `pct_<var>` = % change). The built scatter reads 2010s levels, so these need the change chart.

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 7.1 | Did countries that reduced inequality cut child deaths faster? | Change scatter with quadrant lines at 0 | `d_swiid_gini` → `pct_under5_mort` | r = -0.04 (175): no link (World Bank Gini: -0.18) |
| 7.2 | Did raising health spending speed up progress? | Change scatter | `d_health_spend` → `pct_under5_mort` | r = 0.06 (187) |
| 7.3 | Do links between countries hold within countries over time? | Dot chart: r in levels next to r in changes, per pair | both tables | inequality vs child mortality: 0.60 between countries, -0.04 over time |

## 8. Beating Expectations

**Page question:** Which countries do better, or worse, than their income predicts, and what do the overperformers have in common?

Data: `country_scores.rds` (`score` > 0 = better than income predicts).

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 8.1 | Which countries live longer than their income predicts? | Expectations chart: outcome vs log GDP with expected line, top/bottom 5 labelled (toggle: school completion) | `life_expect` (or `prim_comp_rate`) scores | Albania +8.4 years; Nigeria, South Sudan, Eswatini 13-15 years short |
| 8.2 | Who are the biggest over- and underperformers? | Ranked table (top/bottom 10) | `country`, `actual`, `expected`, `score` | post-socialist countries top; HIV-affected and oil-rich bottom |
| 8.3 | What do overperformers have in common? | Dot chart: r between score and each explanation | score vs `swiid_gini`, `health_equality`, `health_spend`, `hiv_prev`, `resource_rents`, `aid_received_gni`, `fdi` | Gini 0.43, health equality 0.32, HIV -0.37, resource rents -0.25 |

## 9. Forecast & Models

**Page question:** Where are countries heading, and how well can models (from simple trends to machine learning and a Neural ODE) predict it?

Data: `data/forecast_results.rds`, made by `analysis/forecast.Rmd` (models are never trained in the app).

| # | Question | Graph | Variables | Preliminary result |
|---|---|---|---|---|
| 9.1 | Will the child mortality gap between rich and poor countries close by 2035? | Forecast fan chart per income group (80%/95% bands) | `group_trends.rds` → `under5_mort` median | ETS: low income ~54 vs high ~4 in 2035, still ~13x |
| 9.2 | What do different models predict for one country? | Forecast chart for a chosen country, one line per model | `wdi_clean.rds` → `under5_mort` | not built yet |
| 9.3 | Which model predicts best? | Bar chart of back-test error (train to 2014, predict 2019) | drift, ETS, ARIMA, random forest (+ Neural ODE) | MAE: ETS 2.30, ARIMA 2.74, drift 2.80, random forest 3.26 |
| 9.4 | What predicts which countries improve fastest? | Importance bars (random forest) | `pct_under5_mort` from 2000s levels | weak model (R² 0.08) |
