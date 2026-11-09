# page_home.R
# =============================================================================
# Home: the central question, the short answer, and where to start.
# Owner: TBD
#
# ## Your tasks
# 1. Finalise the central question wording with the team (and professor).
# 2. Fill the four finding cards ONCE the evidence pages have findings:
#    one short headline + one sentence each, e.g.
#      "Wealth comes first"        GDP explains ~75% of differences in health.
#      "Inequality: across, not over time" ...
#      "Spending helps, modestly"  ...
#      "Foreign money: no link"    ...
# 3. Keep the page short: it should take 20 seconds to read.
# =============================================================================

homeUI <- function(id) {
  ns <- NS(id)

  finding_card <- function(title) {
    card(card_header(title), placeholder("Headline finding + one sentence", "110px"))
  }

  tagList(
    h2("Beyond wealth: what is linked to better health, education and wellbeing?"),
    p(class = "lead",
      "National income explains most of the differences between countries. We ask what",
      "matters beyond it (inequality, public spending, foreign money or institutions)",
      "and whether those links hold when we follow countries over time."),

    layout_columns(
      col_widths = c(3, 3, 3, 3),
      finding_card("Finding 1"),
      finding_card("Finding 2"),
      finding_card("Finding 3"),
      finding_card("Finding 4")
    ),

    div(class = "my-3",
        actionButton(ns("start"), "Start with the evidence →", class = "btn-primary btn-lg")),

    layout_columns(
      value_box(title = "Countries", value = max(info$n_countries)),
      value_box(title = "Indicators", value = nrow(info)),
      value_box(title = "Sources", value = length(unique(info$source))),
      value_box(title = "Years", value = paste(year_range, collapse = "-"))
    ),

    p(class = "text-muted mt-3",
      "Team 4: Jacob, Kweko, Tuniko. Data: World Bank WDI, SWIID, World Happiness Report, V-Dem.")
  )
}

# parent_session is the app's main session, needed to switch navbar tabs
homeServer <- function(id, parent_session) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$start, nav_select("main_nav", "wealth", session = parent_session))
  })
}
