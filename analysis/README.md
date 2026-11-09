# analysis/: notebooks for checking every figure

One notebook per app page, with **one section per figure**. This is where the analysis happens: run each figure's chunk, check the numbers, and write the final caption. Then copy the caption into the matching page file in `R/`.

| Notebook | Page | Owner | Figures |
|---|---|---|---|
| `wealth.Rmd` | 1. Wealth | TBD | 1.1-1.3 |
| `inequality.Rmd` | 2. Inequality | Jacob | 2.1-2.3 |
| `spending.Rmd` | 3. Public Spending | TBD | 3.1-3.3 |
| `foreign.Rmd` | 4. Foreign Money | TBD | 4.1-4.2 |
| `wellbeing.Rmd` | 5. Wellbeing | TBD | 5.1-5.3 |
| `institutions.Rmd` | 6. Institutions | TBD | 6.1-6.2 (incl. the key regression) |
| `over_time.Rmd` | Over Time | TBD | 7.1-7.3 |
| `expectations.Rmd` | Beating Expectations | TBD | 8.1-8.3 |
| `forecast.Rmd` | Forecast & Models | TBD | 9.1-9.4: fable models, global random forest, Neural ODE outline |
| `_setup.R` | Shared functions (don't edit without asking) | App lead | — |

Every caption in the page files starts with **"Preliminary:"** and real numbers from these notebooks. Your job is to check them, look at the chart, and turn them into 2-3 plain sentences.

## How to work in a notebook

1. Open it in RStudio and run the first two chunks (`setup`, `load`).
2. Run each figure's chunk. `summarise_question(d, x, y)` returns:
   - `overall`: Spearman r, n and p-value across all countries
   - `beyond_gdp`: partial r controlling for log GDP per capita ("at similar income levels")
   - `by_income`: r within each income group
3. Look at the scatter: outliers? small states? a curve?
4. Write the caption under **Caption**. Association language ("is linked to"), never "causes".
5. Copy it into the figure's `caption = "..."` in `R/page_<name>.R`. If the finding changed, update the figure's `title` too.

Each Evidence notebook ends with **optional extra questions** that didn't become figures: useful for the report.

## Shared functions (`_setup.R`)

| Function | Does |
|---|---|
| `decade("2010-2019")` | One row per country for that decade |
| `spearman(data, x, y)` | n, r, p |
| `beyond(data, x, y, control)` | Partial r controlling for `control` (default GDP per capita; use `"pct_gdp_per_capita"` for change data) |
| `by_income(data, x, y)` | r within each income group |
| `summarise_question(data, x, y)` | All three at once |
| `quick_scatter(data, x, y, log_x, log_y)` | Exploratory scatter (the website's charts are written in each page file) |

## The forecast notebook

`forecast.Rmd` works up a ladder of models, all judged by the same back-test (train up to 2014, predict 2019):
drift → ETS / ARIMA (`fable`) → one global random forest (`ranger`) → Neural ODE (`torch`, stretch goal, outlined). It saves its results to `data/forecast_results.rds`, which the app will read. Levels 0-2 run as they are; the Neural ODE is an untested outline to build on.
