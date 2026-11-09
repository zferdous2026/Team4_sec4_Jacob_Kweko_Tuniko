# page_map.R
# =============================================================================
# Explore · World Map: one indicator for every country in a chosen year.
# Press play on the year slider to animate it over time.
#
# Owner: TBD
# Data:  wdi_clean.rds
#
# ## TODO
# 1. Server: filter wdi_clean to input$year, then draw a choropleth with
#    plotly::plot_ly(type = "choropleth", locations = ~iso3c, z = ~value).
# 2. Use one sequential blue scale (light = low, dark = high) for every
#    indicator; grey land = no data.
# 3. Note: plotly downloads country outlines from the internet when the map
#    first loads.
# =============================================================================

mapUI <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      open = list(desktop = "open", mobile = "always"),
      selectInput(ns("var"), "Indicator", choices = indicator_choices(),
                  selected = "under5_mort"),
      sliderInput(ns("year"), "Year", min = year_range[1], max = year_range[2],
                  value = 2020, step = 1, sep = "",
                  animate = animationOptions(interval = 700))
    ),
    card(
      card_header("World map"),
      placeholder("World map: countries shaded by the chosen indicator", "520px")
    )
  )
}

mapServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # TODO: draw the map for input$var and input$year
  })
}
