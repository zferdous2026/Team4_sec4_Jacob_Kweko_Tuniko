# page_inequality.R
# =============================================================================
# The Evidence · 2. Inequality
# Owner: Jacob
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
# Figures 1 and 2 are Jacob's chart (from FINALginivsinfantmortality.Rmd):
# all countries, then split by income group. It uses the SWIID Gini (more
# countries, comparable across countries) instead of his World Bank Gini. The chart code is written once
# below (gini_chart) and used by both figures. It's the working example of
# writing your own chart: copy it to your page and change it.
# Figure 3 is blank.
#
# ## Data
#   data/country_period.rds (2010s averages): any variable in docs/variables.md.
# =============================================================================

# Jacob's chart --------------------------------------------------------------
# d: 2010s data, one row per country (given by the template).
# split = TRUE: one panel per income group, each with its own trend line.
income_colours <- c("Low income" = "#86b6ef", "Lower middle income" = "#3987e5",
                    "Upper middle income" = "#1c5cab", "High income" = "#0d366b")

gini_chart <- function(d, split = FALSE) {
  d <- d %>%
    filter(!is.na(swiid_gini), !is.na(infant_mort), !is.na(income)) %>%
    mutate(tip = paste0("<b>", country, "</b>",
                        "<br>", income,
                        "<br>Gini index (SWIID): ", round(swiid_gini, 1),
                        "<br>Infant mortality: ", round(infant_mort, 1),
                        " per 1,000 live births"))

  p <- ggplot(d, aes(x = swiid_gini, y = infant_mort)) +
    # One trend line through all the points. Colour is set only on the
    # points, so the line isn't split by income group.
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    # `text` is the hover text. Only plotly reads it, so ggplot warns
    # "Ignoring unknown aesthetics"; the warning is harmless.
    suppressWarnings(geom_point(aes(colour = income, text = tip),
                                size = 2.3, alpha = 0.85)) +
    scale_colour_manual(values = income_colours, name = NULL) +
    scale_y_log10() +
    labs(x = "Gini index (SWIID, disposable income, 0-100)",
         y = "Infant mortality (log scale)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())

  if (split) {
    p <- p + facet_wrap(~ income, ncol = 2) + theme(legend.position = "none")
  }
  p
}

inequality_figures <- list(
  list(
    id = "1", title = "More unequal countries have higher infant mortality",
    chart = "Scatter: Gini index (SWIID) vs infant mortality (log scale), 2010s",
    x = "swiid_gini", y = "infant_mort",
    plot = function(d) gini_chart(d),
    caption = "Preliminary: r = 0.60 across 178 countries, and 0.50 at similar income levels. With the World Bank Gini the pattern is the same (r = 0.45, 160 countries). TODO"
  ),
  list(
    id = "2", title = "The link is strongest among richer countries",
    chart = "Scatter split by income group",
    x = "swiid_gini", y = "infant_mort",
    plot = function(d) gini_chart(d, split = TRUE),
    height = "560px",
    caption = "Preliminary: r = 0.66 in high-income, 0.44 upper-middle, 0.32 lower-middle and about 0 in low-income countries. TODO"
  ),
  list(
    id = "3", title = "Q3: TODO (write the finding as a headline)",
    chart = "Fig 3: TODO (which graph, which variables)",
    caption = "TODO: 2-3 sentences."
  )
)

inequalityUI <- function(id) {
  story_page(
    id, "2. Inequality",
    "Do more unequal countries have higher infant mortality?",
    "TODO: the answer in one sentence",
    inequality_figures, next_label = "3. Public Spending"
  )
}

inequalityServer <- function(id, parent_session) {
  story_server(id, inequality_figures, parent_session, next_page = "spending")
}
