# Beyond Wealth

**Team 4:** Jacob, Kweko, Tuniko

An interactive Shiny app about one question:

> **Beyond national wealth, what is linked to better health, education and wellbeing (inequality, public spending, foreign money, or institutions), and do these links hold when we follow countries over time?**

Data: World Bank World Development Indicators, SWIID (inequality), World Happiness Report 2026, and V-Dem (institutions). 217 countries, 1960-2025.

> **Status:** skeleton. Every page has its layout, figures (as placeholders), captions with preliminary numbers, and navigation. Each file says what to do in it.

## Run the app

1. Open `Team4_sec4_Jacob_Kweko_Tuniko.Rproj` in RStudio.
2. Install packages once:
   ```r
   install.packages(c("shiny", "bslib", "dplyr", "tidyr", "purrr", "readr", "ggplot2",
                      "plotly", "WDI", "countrycode", "readxl", "remotes"))
   remotes::install_github("vdeminstitute/vdemdata")   # V-Dem is not on CRAN
   # Forecast & Models page:
   install.packages(c("fable", "tsibble", "fabletools", "feasts", "urca", "ranger"))
   ```
3. Open `app.R` and click **Run App**.

## How the project fits together

```
data-raw/ scripts ──► data/ files ──► analysis/ notebooks ──► captions + results
   (build data)        (store)          (check each figure)          │
                          │                                           ▼
                          └──────────────► R/ pages ──► app.R ──► the website
```

| Folder | What's in it | README |
|---|---|---|
| `app.R` | The navbar: which page goes where | — |
| `R/` | One file per page (with its charts) + shared helpers and story template | [R/README.md](R/README.md) |
| `data-raw/` | Scripts that download and build the data (run in order) | [data-raw/README.md](data-raw/README.md) |
| `data/` | Finished data the app reads (never edit by hand) | [data/README.md](data/README.md) |
| `analysis/` | One notebook per page, one section per figure | [analysis/README.md](analysis/README.md) |
| `report/` | The written report | [report/README.md](report/README.md) |

## The app: a guided story

Story pages are like an illustrated article: a sub-question, a takeaway, then 2-4 figures in a fixed order, each with a headline that **states the finding**. Viewers scroll and read; there are no question lists or dropdowns. Each scatter figure has an "Explore this yourself" link to the Explorer, where everything can be changed.

| Page | Figures | Owner |
|---|---|---|
| Home | Central question, 4 key findings, "Start" button | TBD |
| The Evidence · 1. Wealth | 1.1-1.3: income explains most of health and happiness, less of schooling | TBD |
| The Evidence · 2. Inequality | 2.1-2.3: inequality goes with worse health, beyond income; not with schooling | Jacob |
| The Evidence · 3. Public Spending | 3.1-3.3: spending helps, modestly | TBD |
| The Evidence · 4. Foreign Money | 4.1-4.2: no link beyond income | TBD |
| The Evidence · 5. Wellbeing | 5.1-5.3: income and health go with happiness; inequality matters little | TBD |
| The Evidence · 6. Institutions | 6.1-6.2: equal healthcare is the strongest link; explains part of the inequality link | TBD |
| Over Time | 7.1-7.3: the links between countries vanish within countries | TBD |
| Beating Expectations | 8.1-8.3: who beats their income, and what they share | TBD |
| **Forecast & Models** | 9.1-9.4: forecast to 2035; model back-test from drift to ML and a Neural ODE; what predicts improvement | TBD |
| Conclusion | Summary chart, the answer, limitations | TBD |
| Explore · Explorer, World Map | Free exploration of all 31 indicators | App lead / TBD |
| About | Sources, methods, literature, robustness, download | TBD |

## Team workflow

- `main` must always run. Work on a branch, open a pull request, get one approval, merge.
- Each person edits only their own files (see the owner line at the top of each file).
- Shared files (`app.R`, `R/helpers.R`, `R/page_story.R`, `analysis/_setup.R`, `data-raw/`) have one owner: ask before changing them.

## Order of work

1. **Analysis:** each owner runs their notebook in `analysis/`, checks the preliminary numbers, writes final captions.
2. **Charts:** each owner writes their charts in their own page file (`plot = function(d) {...}`), starting from their notebook.
3. **Pages:** paste titles, captions and charts into the page files.
4. **Forecast & Models:** work up the method ladder in `analysis/forecast.Rmd`.
5. **Conclusion, Home, About:** written last, from everyone's findings.
6. **Report** in `report/`.
