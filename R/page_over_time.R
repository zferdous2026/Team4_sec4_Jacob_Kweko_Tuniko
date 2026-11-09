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

over_time_figures <- list(
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
