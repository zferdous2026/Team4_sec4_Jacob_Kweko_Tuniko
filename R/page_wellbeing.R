# page_wellbeing.R
# =============================================================================
# The Evidence · 5. Wellbeing
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
# Figure 1 is Jacob's (from HealthEqualityVSHapiness.Rmd): the chart code is
# health_happiness_chart() below. His notebook's year slider and continent
# filter are replaced by fixed 2010s averages (the page is guided); the
# toggle splits it by income group. Figures 2 and 3 are blank.
#
# ## Data
#   data/country_period.rds (2010s averages). happiness = World Happiness
#   Report life evaluation (0-10), 164 countries.
# =============================================================================

# Jacob's chart: health equality vs happiness ----------------------------------
# From HealthEqualityVSHapiness.Rmd. Countries are split into thirds by health
# equality (V-Dem), and happiness (World Happiness Report) is shown as a box
# plot per third, with one dot per country.
# d: 2010s data, one row per country (given by the template).
# by_income = TRUE: one panel per income group (the figure's toggle).
health_group_colours <- c("Lower" = "#86b6ef", "Middle" = "#3987e5",
                          "Higher" = "#0d366b")

health_happiness_chart <- function(d, by_income = FALSE) {
  d <- d %>%
    filter(!is.na(health_equality), !is.na(happiness), !is.na(income)) %>%
    mutate(
      # ntile(x, 3): 1 = lowest third of countries, 3 = highest third
      health_group = factor(ntile(health_equality, 3), levels = 1:3,
                            labels = names(health_group_colours)),
      continent = countrycode::countrycode(iso3c, "iso3c", "continent", warn = FALSE),
      tip = paste0("<b>", country, "</b>",
                   "<br>", continent, ", ", income,
                   "<br>Health equality: ", round(health_equality, 2),
                   "<br>Happiness: ", round(happiness, 2))
    )

  p <- ggplot(d, aes(x = health_group, y = happiness, fill = health_group)) +
    # outlier.shape = NA: no separate outlier dots, every country is a dot below
    geom_boxplot(alpha = 0.65, outlier.shape = NA) +
    # Jitter spreads the dots sideways so they don't overlap; seed keeps the
    # same positions every time the chart is drawn
    suppressWarnings(geom_point(aes(text = tip),
                                position = position_jitter(width = 0.15, height = 0, seed = 1),
                                alpha = 0.65, size = 2)) +
    scale_fill_manual(values = health_group_colours) +
    labs(x = "Health equality (thirds of countries: lower, middle, higher)",
         y = "Happiness (life evaluation, 0-10)") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none", panel.grid.minor = element_blank())

  if (by_income) p <- p + facet_wrap(~ income, ncol = 2)
  p
}

wellbeing_figures <- list(
  list(
    id = "1", title = "Countries with more equal healthcare report higher happiness",
    stat = "r = 0.68 \u00b7 162 countries",
    chart = "Box plot: happiness by thirds of health equality, 2010s",
    x = "health_equality", y = "happiness",
    plot = function(d, toggle) health_happiness_chart(d, by_income = toggle),
    toggle = "Compare within income groups",
    height = "520px",
    caption = "Preliminary: the third of countries with the most equal healthcare report a median happiness of 6.3, against 4.4 for the least equal third (r = 0.68, 162 countries). TODO"
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

wellbeingUI <- function(id) {
  story_page(
    id, "5. Wellbeing",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    wellbeing_figures, next_label = "6. Institutions"
  )
}

wellbeingServer <- function(id, parent_session) {
  story_server(id, wellbeing_figures, parent_session, next_page = "institutions")
}
