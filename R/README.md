# R/: the app's pages

Shiny runs every `.R` file in this folder (alphabetically) before `app.R`. Each page is a **module**: a `...UI(id)` function (what it looks like) and a `...Server(id)` function (what it does). `app.R` puts them in the navbar.

## Files

| File | Page | Owner | Status |
|---|---|---|---|
| `helpers.R` | Shared: indicator lists, placeholders, controls, navigation | App lead | ✅ Done |
| `page_story.R` | Template for every guided story page (figure cards, "Next →", "Explore this yourself") | App lead | Layout done, charts TODO |
| `page_home.R` | Home | TBD | Layout done, findings TODO |
| `page_wealth.R` | The Evidence · 1. Wealth | TBD | Figures + preliminary captions |
| `page_inequality.R` | The Evidence · 2. Inequality | Jacob | Figures + preliminary captions |
| `page_spending.R` | The Evidence · 3. Public Spending | TBD | Figures + preliminary captions |
| `page_foreign.R` | The Evidence · 4. Foreign Money | TBD | Figures + preliminary captions |
| `page_wellbeing.R` | The Evidence · 5. Wellbeing | TBD | Figures + preliminary captions |
| `page_institutions.R` | The Evidence · 6. Institutions | TBD | Figures + preliminary captions |
| `page_over_time.R` | Over Time | TBD | Figures + preliminary captions |
| `page_expectations.R` | Beating Expectations | TBD | Figures + preliminary captions |
| `page_forecast.R` | Forecast & Models | TBD | Figures defined; models in `analysis/forecast.Rmd` |
| `page_conclusion.R` | Conclusion | TBD | Layout done, do last |
| `page_explorer.R` | Explore · Explorer | App lead | Controls done, chart TODO |
| `page_map.R` | Explore · World Map | TBD | Controls done, map TODO |
| `page_about.R` | About | TBD | Text done, charts TODO |

## A story page = a list of figures

Each story page file defines its figures and passes them to the template:

```r
inequality_figures <- list(
  list(
    id = "2.1",
    title = "More unequal countries have higher child mortality",   # the FINDING
    chart = "Chart 1 (scatter): Gini vs under-5 mortality, 2010s",  # shown until the chart exists
    x = "swiid_gini", y = "under5_mort",                             # optional: adds "Explore this yourself"
    toggle = "Show by income group",                                 # optional: one checkbox
    caption = "2-3 sentences: what the chart shows, the key number, what it means."
  ),
  ...
)
```

- **Titles state the finding**, not the variables ("Richer countries live much longer", not "GDP vs life expectancy").
- **2-4 figures per page.** If something doesn't earn its place in the story, put it in the report or leave it to the Explorer.
- `x` / `y` must be column names from `data/indicator_info.csv`.
- **At most one toggle per figure**, and only when it adds something.

## Build a chart into a page

You write the chart yourself, in your own page file. No shared file needs to change.

1. Draw it in your notebook with ggplot.
2. Paste the code into the figure as `plot = function(d) { ggplot(d, aes(...)) + ... }`. `d` is the 2010s data (one row per country); it becomes interactive automatically.
3. For a scatter, start from Jacob's chart (`gini_chart()` in `page_inequality.R`).

Other data (changes, scores, yearly data): load it once at the top of your page file and use it inside the function. Toggles, colours and more examples: header of `page_story.R`.

## Rules

- One page per file; edit only your own.
- Shared files (`helpers.R`, `page_story.R`) have one owner: ask before changing them.
- Load data once at the top of a file, never inside a server function. **Never train models inside the app**: the Forecast page reads saved results from `data/`.
- Run the app before you push.
