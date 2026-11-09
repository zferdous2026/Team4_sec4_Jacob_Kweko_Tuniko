# page_foreign.R
# =============================================================================
# The Evidence · 4. Foreign Money
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
#   data/country_period.rds (2010s averages). Tip: FDI in financial hubs is
#   money passing through; leave them out with exclude = c("LUX", "IRL", ...).
# =============================================================================

foreign_figures <- list(
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

foreignUI <- function(id) {
  story_page(
    id, "4. Foreign Money",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    foreign_figures, next_label = "5. Wellbeing"
  )
}

foreignServer <- function(id, parent_session) {
  story_server(id, foreign_figures, parent_session, next_page = "wellbeing")
}
