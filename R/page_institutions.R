# page_institutions.R
# =============================================================================
# The Evidence · 6. Institutions
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
#   data/country_period.rds (2010s averages). V-Dem variables: democracy,
#   health_equality, educ_equality, corruption.
# =============================================================================

# Figure 1: what goes with learning? -------------------------------------------
# Test scores against three possible explanations, one panel each. The panel
# title gives the correlation once income is taken into account, which is
# where the three differ most.
# d: 2010s data, one row per country (given by the template).

# Correlation between x and y after removing what GDP per capita explains in
# each (ranks, as in analysis/_setup.R's beyond())
r_beyond_income <- function(x, y, gdp) {
  ok <- !is.na(x) & !is.na(y) & !is.na(gdp)
  rx <- resid(lm(rank(x[ok]) ~ rank(gdp[ok])))
  ry <- resid(lm(rank(y[ok]) ~ rank(gdp[ok])))
  cor(rx, ry)
}

learning_chart <- function(d) {
  colours <- c("Low income" = "#86b6ef", "Lower middle income" = "#3987e5",
               "Upper middle income" = "#1c5cab", "High income" = "#0d366b")
  explanations <- c(edc_spending    = "Education spending (% of GDP)",
                    gross_sec_enrol = "Secondary enrollment (%)",
                    educ_equality   = "Educational equality (V-Dem)")

  # Panel titles with the "beyond income" correlation, e.g.
  # "Educational equality (V-Dem): r = 0.44 at similar income"
  panel_titles <- sapply(names(explanations), function(v) {
    r <- r_beyond_income(d[[v]], d$test_scores, d$gdp_per_capita)
    paste0(explanations[[v]], "\nr = ", sprintf("%.2f", r), " at similar income")
  })

  d <- d %>%
    filter(!is.na(test_scores), !is.na(income)) %>%
    tidyr::pivot_longer(all_of(names(explanations)), names_to = "measure", values_to = "value") %>%
    filter(!is.na(value)) %>%
    mutate(
      tip = paste0("<b>", country, "</b>",
                   "<br>", income,
                   "<br>", explanations[measure], ": ", round(value, 2),
                   "<br>Test score: ", round(test_scores)),
      measure = factor(measure, levels = names(explanations), labels = panel_titles)
    )

  ggplot(d, aes(x = value, y = test_scores)) +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    suppressWarnings(geom_point(aes(colour = income, text = tip),
                                size = 1.8, alpha = 0.8)) +
    # free_x: each explanation keeps its own x scale
    facet_wrap(~ measure, scales = "free_x") +
    scale_colour_manual(values = colours, name = NULL) +
    labs(x = NULL, y = "Harmonized test score (300-625)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(), strip.text = element_text(face = "bold"))
}

institutions_figures <- list(
  list(
    id = "1", title = "Equal access to schooling goes with better learning; spending doesn't",
    chart = "Three scatters: test scores vs education spending, secondary enrollment and educational equality, 2010s",
    plot = function(d) learning_chart(d),
    height = "440px",
    caption = "Preliminary: at similar income levels, countries where schooling is shared more equally score higher on international tests (r = 0.44, 149 countries). Enrollment matters less (0.22), and education spending hardly at all (0.06). TODO"
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

institutionsUI <- function(id) {
  story_page(
    id, "6. Institutions",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    institutions_figures, next_label = "Over Time"
  )
}

institutionsServer <- function(id, parent_session) {
  story_server(id, institutions_figures, parent_session, next_page = "over_time")
}
