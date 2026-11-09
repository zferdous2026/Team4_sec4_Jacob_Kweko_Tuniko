# page_forecast.R
# =============================================================================
# Forecast & Models
# Owner: TBD
#
# ## This page is a blank template: write your own questions and graphs
# 1. Choose the page's question (the second argument of story_page() below)
#    and 2-4 figures, each answering one smaller question.
#    Ideas: docs/question_bank.md     Variables: docs/variables.md
# 2. Work out the answer in a notebook in analysis/ (see analysis/README.md).
# 3. Fill in each figure below:
#      title    the FINDING in one sentence ("Richer countries live longer"),
#               not the variables ("GDP vs life expectancy")
#      chart    what the graph shows (displayed until the real graph exists)
#      caption  2-3 sentences: what the graph shows, the key number, what it means
# 4. Add your chart: paste the ggplot code from your notebook into the figure,
#        plot = function(d) { ggplot(d, aes(...)) + ... }
#    d = 2010s data, one row per country. Any chart type works.
#    Optional: x = "...", y = "..." (adds an "Explore this yourself" link),
#    toggle = "...", exclude = c("LUX", ...).
#    Details and examples: header of R/page_story.R.
# 5. Add or remove figures freely (copy a list(...) block). Then write the
#    takeaway: the page's answer in one sentence.
#
# Working example: R/page_inequality.R (Jacob's figure).
#
# ## Data
#   models are trained in analysis/forecast.Rmd, never in the app; save
#   results to data/ with saveRDS() and draw them here. group_trends.rds and
#   wdi_clean.rds have the yearly series.
#
# ## Method ladder (keep this: it's the technical side of the project)
# | Level | Model | Package | Idea |
# |---|---|---|---|
# | 0 | Drift (straight-line trend) | fable | Baseline every model must beat |
# | 1 | ETS, ARIMA | fable | Classic time-series models, one per country/group |
# | 2 | Random forest / XGBoost, one GLOBAL model | ranger / xgboost | Trained on all countries at once |
# | 3 | Neural ODE (stretch) | torch (R) | Learns dy/dt = f(y, covariates) as a small neural network |
#
# Rules: back-test (train to 2014, predict 2015-2019) and report every model,
# including the losers; always show uncertainty bands; forecasts are not causal.
#
# Chart ideas (write them here with plot = function(d) {...}; load the saved
# results once at the top of this file, e.g.
# forecast_results <- readRDS("data/forecast_results.rds")):
# - Forecast fan: history as a solid line, forecast dashed, 80% / 95% bands
#   as two shades (geom_ribbon), one colour per income group or model.
# - Model comparison: back-test error (MAE) per model as sorted bars, the
#   drift baseline marked with a dashed line.
# - Variable importance: one bar per predictor, sorted.
# =============================================================================

forecast_figures <- list(
  list(
    id = "1", title = "Q1: TODO (write the finding as a headline)",
    chart = "Fig 1: TODO (which graph, which variables)",
    caption = "TODO: 2-3 sentences."
  ),
  list(
    id = "2", title = "Q2: TODO (write the finding as a headline)",
    chart = "Fig 2: TODO (which graph, which variables)",
    caption = "TODO: 2-3 sentences."
  ),
  list(
    id = "3", title = "Q3: TODO (write the finding as a headline)",
    chart = "Fig 3: TODO (which graph, which variables)",
    caption = "TODO: 2-3 sentences."
  )
)

forecastUI <- function(id) {
  story_page(
    id, "Forecast & Models",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    forecast_figures, next_label = "Conclusion"
  )
}

forecastServer <- function(id, parent_session) {
  story_server(id, forecast_figures, parent_session, next_page = "conclusion")
}
