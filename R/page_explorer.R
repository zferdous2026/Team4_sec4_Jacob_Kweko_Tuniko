# page_explorer.R
# =============================================================================
# Explore · Explorer: pick any two indicators and see how they relate across
# countries. A supporting tool for viewers who want to check things themselves;
# the story pages answer preset questions with their own charts.
#
# Owner: app lead
# Data:  wdi_clean.rds (custom year range -> one value per country)
#
# ## TODO
# 1. Server: average (or take the latest value of) input$x and input$y over
#    input$years for each country, filter by input$region, then draw a
#    scatter (Jacob's chart in page_inequality.R is a good start) and a
#    correlation table.
# 2. When input$x / input$y change, set the log checkboxes to the
#    indicator's log_scale value from indicator_info.csv.
# 3. Replace the placeholders with plotlyOutput / textOutput / tableOutput.
# =============================================================================

explorerUI <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      open = list(desktop = "open", mobile = "always"),
      selectInput(ns("x"), "X axis", choices = indicator_choices(),
                  selected = "gini_index"),
      selectInput(ns("y"), "Y axis", choices = indicator_choices(),
                  selected = "infant_mort"),
      checkboxInput(ns("log_x"), "Log scale on X"),
      checkboxInput(ns("log_y"), "Log scale on Y"),
      selectInput(ns("colour_by"), "Colour by", choices = colour_options),
      checkboxInput(ns("split"), "Split by income group"),
      selectInput(ns("region"), "Region", choices = c("All", regions)),
      year_controls(ns)
    ),

    card(
      card_header("Scatter plot"),
      placeholder("Scatter plot: X vs Y, one dot per country", "460px")
    ),
    layout_columns(
      col_widths = c(7, 5),
      card(card_header("What it shows"), placeholder("Plain-English summary", "120px")),
      card(card_header("Correlation (Spearman)"), placeholder("Correlation table", "120px"))
    )
  )
}

explorerServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # TODO: build the chart, summary and table from the inputs above
  })
}
