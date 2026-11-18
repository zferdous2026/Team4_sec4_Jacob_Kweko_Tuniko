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
# Figures 2 and 3 are Jacob's (HealthEqualityVSHapiness2.Rmd and
# DemocracyVsCorruption.Rmd), rebuilt on 2010s averages.
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

# Figure 2: health equality vs child mortality (Jacob's) ------------------------
# From HealthEqualityVSHapiness2.Rmd (which is about under-5 mortality, despite
# the name). Countries are split into thirds by health equality (V-Dem); under-5
# mortality is shown as a box plot per third, one dot per country.
# by_income = TRUE: one panel per income group (the figure's toggle).
health_mortality_chart <- function(d, by_income = FALSE) {
  colours <- c("Lower" = "#86b6ef", "Middle" = "#3987e5", "Higher" = "#0d366b")

  d <- d %>%
    filter(!is.na(health_equality), !is.na(under5_mort), !is.na(income)) %>%
    mutate(
      # ntile(x, 3): 1 = lowest third of countries, 3 = highest third
      health_group = factor(ntile(health_equality, 3), levels = 1:3, labels = names(colours)),
      tip = paste0("<b>", country, "</b>",
                   "<br>", income,
                   "<br>Health equality: ", round(health_equality, 2),
                   "<br>Under-5 mortality: ", round(under5_mort, 1), " per 1,000")
    )

  p <- ggplot(d, aes(x = health_group, y = under5_mort, fill = health_group)) +
    geom_boxplot(alpha = 0.65, outlier.shape = NA) +
    suppressWarnings(geom_point(aes(text = tip),
                                position = position_jitter(width = 0.15, height = 0, seed = 1),
                                alpha = 0.65, size = 2)) +
    scale_fill_manual(values = colours) +
    # Log scale: the thirds differ more than tenfold (about 60 vs 5 deaths)
    scale_y_log10() +
    labs(x = "Health equality (thirds of countries: lower, middle, higher)",
         y = "Under-5 mortality per 1,000 (log scale)") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "none", panel.grid.minor = element_blank())

  if (by_income) p <- p + facet_wrap(~ income, ncol = 2)
  p
}

# Figure 3: democracy vs corruption (Jacob's) -----------------------------------
# From DemocracyVsCorruption.Rmd. A CURVED trend (loess), not a straight line:
# partly democratic countries are the most corrupt, and only full democracies
# are clean. Colour on the points only, so there is one trend line, not one
# per region.
democracy_corruption_chart <- function(d) {
  colours <- c("East Asia & Pacific" = "#2a78d6", "Europe & Central Asia" = "#eda100",
               "Latin America & Caribbean" = "#eb6834",
               "Middle East, North Africa, Afghanistan & Pakistan" = "#8a63d2",
               "North America" = "#52514e", "South Asia" = "#1baf7a",
               "Sub-Saharan Africa" = "#e87ba4")

  d <- d %>%
    filter(!is.na(democracy), !is.na(corruption), !is.na(region)) %>%
    mutate(tip = paste0("<b>", country, "</b>",
                        "<br>", region,
                        "<br>Democracy: ", round(democracy, 2),
                        "<br>Corruption: ", round(corruption, 2)))

  ggplot(d, aes(x = democracy, y = corruption)) +
    geom_smooth(method = "loess", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    suppressWarnings(geom_point(aes(colour = region, text = tip),
                                size = 2.3, alpha = 0.85)) +
    scale_colour_manual(values = colours, name = NULL) +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
    labs(x = "Electoral democracy (V-Dem, 0 = low, 1 = high)",
         y = "Political corruption (V-Dem, 0 = clean, 1 = corrupt)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
}

institutions_figures <- list(
  list(
    id = "1", title = "Equal access to schooling goes with better learning; spending doesn't",
    stat = "r = 0.44 at similar income",
    chart = "Three scatters: test scores vs education spending, secondary enrollment and educational equality, 2010s",
    plot = function(d) learning_chart(d),
    height = "440px",
    caption = "Preliminary: at similar income levels, countries where schooling is shared more equally score higher on international tests (r = 0.44, 149 countries). Enrollment matters less (0.22), and education spending hardly at all (0.06). TODO"
  ),
  list(
    id = "2", title = "Where healthcare reaches everyone, far fewer children die",
    stat = "r = \u22120.50 at similar income",
    chart = "Box plot: under-5 mortality by thirds of health equality, 2010s",
    x = "health_equality", y = "under5_mort",
    plot = function(d, toggle) health_mortality_chart(d, by_income = toggle),
    toggle = "Compare within income groups",
    height = "520px",
    caption = "Preliminary: in the third of countries with the most equal healthcare, a median of 4.8 children per 1,000 die before age five, against 61.7 in the least equal third (r = -0.84, 174 countries). The link holds at similar income levels (r = -0.50), the strongest of any explanation in this project. TODO"
  ),
  list(
    id = "3", title = "Only full democracies are clean; partial democracies are the most corrupt",
    stat = "r = \u22120.53 at similar income",
    chart = "Scatter: democracy vs corruption (V-Dem), 2010s, with a curved trend",
    x = "democracy", y = "corruption",
    plot = function(d) democracy_corruption_chart(d),
    height = "460px",
    caption = "Preliminary: more democratic countries are less corrupt (r = -0.68, 175 countries; -0.53 at similar income levels), but not steadily. Countries that are only partly democratic (democracy 0.2-0.4) are the most corrupt of all (median 0.81); corruption falls sharply only among full democracies (median 0.05). TODO"
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
