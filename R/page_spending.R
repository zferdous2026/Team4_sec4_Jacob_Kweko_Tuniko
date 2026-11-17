# page_spending.R
# =============================================================================
# The Evidence · 3. Public Spending
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
#   data/country_period.rds (2010s averages): any variable in docs/variables.md.
# =============================================================================

# Figure 1: inequality before vs after taxes and transfers ---------------------
# The same countries twice: left panel with the Gini BEFORE taxes and transfers
# (market income), right panel AFTER (disposable income). The difference
# between the two is how much the state redistributes.
# d: 2010s data, one row per country (given by the template).
redistribution_chart <- function(d) {
  colours <- c("Low income" = "#86b6ef", "Lower middle income" = "#3987e5",
               "Upper middle income" = "#1c5cab", "High income" = "#0d366b")

  d <- d %>%
    filter(!is.na(swiid_gini_mkt), !is.na(swiid_gini), !is.na(under5_mort), !is.na(income)) %>%
    mutate(redistribution = swiid_gini_mkt - swiid_gini) %>%
    # Long format: one row per country per Gini measure, so facet_wrap can
    # draw the two measures as two panels
    tidyr::pivot_longer(c(swiid_gini_mkt, swiid_gini), names_to = "measure", values_to = "gini") %>%
    mutate(
      measure = factor(measure, levels = c("swiid_gini_mkt", "swiid_gini"),
                       labels = c("Before taxes and transfers", "After taxes and transfers")),
      tip = paste0("<b>", country, "</b>",
                   "<br>", income,
                   "<br>Gini ", tolower(measure), ": ", round(gini, 1),
                   "<br>Taxes and transfers remove ", round(redistribution, 1), " Gini points",
                   "<br>Under-5 mortality: ", round(under5_mort, 1), " per 1,000")
    )

  ggplot(d, aes(x = gini, y = under5_mort)) +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    suppressWarnings(geom_point(aes(colour = income, text = tip),
                                size = 2, alpha = 0.8)) +
    facet_wrap(~ measure) +
    scale_colour_manual(values = colours, name = NULL) +
    scale_y_log10() +
    labs(x = "Gini index (SWIID, 0-100)", y = "Under-5 mortality (log scale)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(), strip.text = element_text(face = "bold"))
}

spending_figures <- list(
  list(
    id = "1", title = "What matters is inequality after taxes and transfers, not before",
    chart = "Two scatters: Gini before vs after taxes and transfers, against under-5 mortality (log scale), 2010s",
    plot = function(d) redistribution_chart(d),
    height = "460px",
    caption = "Preliminary: inequality before taxes and transfers is barely linked to child mortality (r = -0.19; 0.11 at similar income levels). Inequality after them is strongly linked (r = 0.60; 0.52 at similar income). Countries where taxes and transfers remove more inequality have fewer child deaths, even at similar income (r = -0.40). TODO"
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

spendingUI <- function(id) {
  story_page(
    id, "3. Public Spending",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    spending_figures, next_label = "4. Foreign Money"
  )
}

spendingServer <- function(id, parent_session) {
  story_server(id, spending_figures, parent_session, next_page = "foreign")
}
