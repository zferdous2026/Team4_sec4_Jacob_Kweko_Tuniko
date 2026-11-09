# page_conclusion.R
# =============================================================================
# Conclusion: the answer to the central question
# Owner: TBD (whoever owns Wealth is a good fit)
#
# ## Central question
# Beyond national wealth, what is linked to better health, education and
# wellbeing (inequality, public spending, foreign money, or institutions),
# and do these links hold when we follow countries over time?
#
# ## Your tasks (do this page LAST, once the other findings are written)
# 1. Summary chart: one row per explanation (inequality, health spending,
#    education spending, FDI, aid, health equality, ...), showing its r beyond
#    GDP for health and for education, plus its over-time r where available.
#    Easiest: a small hand-made table of the numbers from the other pages,
#    drawn as a dot chart or table.
# 2. The answer: one paragraph. Use association language ("is linked to"),
#    not causal language ("causes", "drives").
# 3. Limitations: correlations only; decade averages mix years; Gini data
#    quality; current income groups applied to all years; small states.
# 4. What we would do next.
# =============================================================================

conclusionUI <- function(id) {
  ns <- NS(id)

  tagList(
    h3("Conclusion: beyond wealth, what matters?"),
    card(
      card_header("How strong is each explanation, beyond GDP?"),
      placeholder("Summary chart: each explanation's link to health and education beyond GDP, with its over-time result", "380px")
    ),
    layout_columns(
      col_widths = c(6, 6),
      card(card_header("Our answer"),
           placeholder("One paragraph answering the central question", "180px")),
      card(card_header("Limitations and next steps"),
           placeholder("Bullet points", "180px"))
    )
  )
}

conclusionServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # TODO: summary chart
  })
}
