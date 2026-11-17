# page_over_time.R
# =============================================================================
# Over Time
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
#   data/country_change.rds: d_<var> (change 2000s -> 2010s) and pct_<var>
#   (% change). d holds 2010s LEVELS, so for change graphs load the file
#   once at the top of this file, e.g.
#   change_data <- readRDS("data/country_change.rds"), and use it inside
#   plot = function(d) {...} instead of d.
# =============================================================================

# Data: one row per country, 2000s vs 2010s (loaded once)
change_data <- readRDS("data/country_change.rds")

# Figure 1: change in inequality vs change in child mortality ------------------
# Each dot is a country. Dashed lines at 0 split the chart into four quadrants;
# a flat trend line means countries that reduced inequality did NOT cut child
# mortality faster. Uses change_data, not d.
change_chart <- function() {
  colours <- c("Low income" = "#86b6ef", "Lower middle income" = "#3987e5",
               "Upper middle income" = "#1c5cab", "High income" = "#0d366b")

  data <- change_data %>%
    filter(!is.na(d_swiid_gini), !is.na(pct_under5_mort), !is.na(income)) %>%
    mutate(tip = paste0("<b>", country, "</b>",
                        "<br>", income,
                        "<br>Gini: ", round(swiid_gini_2000s, 1), " to ", round(swiid_gini_2010s, 1),
                        " (", sprintf("%+.1f", d_swiid_gini), " points)",
                        "<br>Under-5 mortality: ", round(under5_mort_2000s, 1), " to ",
                        round(under5_mort_2010s, 1), " (", sprintf("%+.0f", pct_under5_mort), "%)"))

  # How many countries fall in each quadrant, for the corner labels
  n_in <- function(gini_fell, mort_fell) {
    sum((data$d_swiid_gini < 0) == gini_fell & (data$pct_under5_mort < 0) == mort_fell)
  }
  corners <- tibble(
    x = c(-6.5, 2.8, -6.5, 2.8), y = c(40, 40, -62, -62),
    # \n = line break, so the labels fit inside the chart
    label = c(paste0("Inequality fell,\nmortality rose (", n_in(TRUE, FALSE), ")"),
              paste0("Inequality rose,\nmortality rose (", n_in(FALSE, FALSE), ")"),
              paste0("Inequality fell,\nmortality fell (", n_in(TRUE, TRUE), ")"),
              paste0("Inequality rose,\nmortality fell (", n_in(FALSE, TRUE), ")"))
  )

  ggplot(data, aes(x = d_swiid_gini, y = pct_under5_mort)) +
    geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60") +
    geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60") +
    geom_text(data = corners, aes(x = x, y = y, label = label),
              colour = "grey45", size = 3.3) +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    suppressWarnings(geom_point(aes(colour = income, text = tip),
                                size = 2.3, alpha = 0.85)) +
    scale_colour_manual(values = colours, name = NULL) +
    labs(x = "Change in Gini index (SWIID), 2000s to 2010s (points)",
         y = "Change in under-5 mortality (%)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
}

# Figure 2: which changes went with faster progress? ---------------------------
# For each change between the 2000s and the 2010s, its Spearman correlation
# with the % change in under-5 mortality. Negative = countries where this rose
# more cut child mortality faster. Calculated once, when the app starts.
progress_changes <- c(
  pct_gdp_per_capita = "Economic growth (% change in GDP per capita)",
  d_gross_sec_enrol  = "Secondary enrollment rose",
  d_urban_pop        = "Urban population share rose",
  d_health_equality  = "Healthcare became more equal",
  d_swiid_gini       = "Inequality rose (Gini)",
  d_democracy        = "Democracy improved",
  d_edc_spending     = "Education spending rose",
  d_health_spend     = "Health spending rose",
  d_corruption       = "Corruption rose",
  d_aid_received_gni = "Aid received rose"
)

progress_links <- bind_rows(lapply(names(progress_changes), function(v) {
  ok <- !is.na(change_data[[v]]) & !is.na(change_data$pct_under5_mort)
  test <- cor.test(change_data[[v]][ok], change_data$pct_under5_mort[ok],
                   method = "spearman", exact = FALSE)
  tibble(change = progress_changes[[v]], n = sum(ok),
         r = unname(test$estimate), p = test$p.value)
}))

progress_chart <- function() {
  data <- progress_links %>%
    mutate(
      # Sorted so the strongest "faster progress" link is at the top
      change = reorder(change, -r),
      clear = if_else(p < 0.05, "Clear link (p < 0.05)", "No clear link"),
      tip = paste0("<b>", change, "</b>",
                   "<br>r = ", sprintf("%.2f", r), " (", n, " countries)",
                   "<br>p = ", signif(p, 2))
    )

  ggplot(data, aes(x = r, y = change, fill = clear, text = tip)) +
    geom_col(width = 0.65) +
    geom_vline(xintercept = 0, colour = "grey40") +
    scale_fill_manual(values = c("Clear link (p < 0.05)" = "#1c5cab", "No clear link" = "#c8c7c1"),
                      name = NULL) +
    scale_x_continuous(limits = c(-0.45, 0.45)) +
    labs(x = "Correlation with % change in under-5 mortality\n(negative = faster progress)",
         y = NULL) +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank(), panel.grid.major.y = element_blank())
}

over_time_figures <- list(
  list(
    id = "1", title = "Countries that reduced inequality did not cut child deaths faster",
    chart = "Change scatter: change in Gini vs % change in under-5 mortality, 2000s to 2010s",
    plot = function(d) change_chart(),
    height = "480px",
    caption = "Preliminary: child mortality fell in almost every country between the 2000s and the 2010s, but no faster where inequality fell (r = -0.04, 175 countries; -0.07 accounting for economic growth). Across countries the link is strong (Inequality page, Figure 1); over time it disappears. TODO"
  ),
  list(
    id = "2", title = "Growth and schooling went with faster progress; inequality and spending did not",
    chart = "Bar chart: correlation of each 2000s-to-2010s change with the % change in under-5 mortality",
    plot = function(d) progress_chart(),
    height = "440px",
    caption = "Preliminary: countries whose economies grew faster (r = -0.38) and whose secondary enrollment rose more (-0.26) cut child mortality faster. Changes in inequality, health spending and democracy show no link. Rising aid goes with slower progress (+0.31), most likely because aid goes to countries that are struggling. TODO"
  ),
  list(
    id = "3", title = "Q3: TODO (write the finding as a headline)",
    chart = "Fig 3: TODO (which graph, which variables)",
    caption = "TODO: 2-3 sentences."
  )
)

overTimeUI <- function(id) {
  story_page(
    id, "Over Time",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    over_time_figures, next_label = "Beating Expectations"
  )
}

overTimeServer <- function(id, parent_session) {
  story_server(id, over_time_figures, parent_session, next_page = "expectations")
}
