# app.R
# =============================================================================
# Layout only: the navbar and which page goes where.
# Each page lives in its own file in R/ (Shiny loads that folder automatically).
# Shared helpers: R/helpers.R · story page template: R/page_story.R
# (charts are written in each page file)
#
# The navbar follows the argument, in reading order:
#   Home -> The Evidence (1-6) -> Over Time -> Beating Expectations ->
#   Forecast & Models -> Conclusion
# Story pages are guided: fixed figures with headline findings, no choices.
# Each ends with a "Next ->" button; the `value` of each nav_panel
# ("wealth", "inequality", ...) is what those buttons use.
# Explore (Explorer, World Map) is for free exploration.
#
# Run the app: open this file in RStudio and click "Run App",
# or run shiny::runApp() in the console from the project folder.
# =============================================================================

ui <- page_navbar(
  id = "main_nav",
  title = "Beyond Wealth",
  theme = bs_theme(version = 5, primary = "#2a78d6"),
  # Pages scroll normally. Once charts are added, the Explorer and map can be
  # made to stretch to the window instead: fillable = c("explorer", "map")
  fillable = FALSE,

  nav_panel("Home", homeUI("home"), value = "home"),

  nav_menu(
    "The Evidence",
    nav_panel("1. Wealth",          wealthUI("wealth"),             value = "wealth"),
    nav_panel("2. Inequality",      inequalityUI("inequality"),     value = "inequality"),
    nav_panel("3. Public Spending", spendingUI("spending"),         value = "spending"),
    nav_panel("4. Foreign Money",   foreignUI("foreign"),           value = "foreign"),
    nav_panel("5. Wellbeing",       wellbeingUI("wellbeing"),       value = "wellbeing"),
    nav_panel("6. Institutions",    institutionsUI("institutions"), value = "institutions")
  ),

  nav_panel("Over Time",            overTimeUI("over_time"),        value = "over_time"),
  nav_panel("Beating Expectations", expectationsUI("expectations"), value = "expectations"),
  nav_panel("Forecast & Models",    forecastUI("forecast"),         value = "forecast"),
  nav_panel("Conclusion",           conclusionUI("conclusion"),     value = "conclusion"),

  nav_menu(
    "Explore",
    nav_panel("Explorer",  explorerUI("explorer"), value = "explorer"),
    nav_panel("World Map", mapUI("map"),           value = "map")
  ),

  nav_panel("About", aboutUI("about"), value = "about")
)

server <- function(input, output, session) {
  # Story pages get the main session so their buttons and links can switch tabs
  homeServer("home", parent_session = session)
  wealthServer("wealth", parent_session = session)
  inequalityServer("inequality", parent_session = session)
  spendingServer("spending", parent_session = session)
  foreignServer("foreign", parent_session = session)
  wellbeingServer("wellbeing", parent_session = session)
  institutionsServer("institutions", parent_session = session)
  overTimeServer("over_time", parent_session = session)
  expectationsServer("expectations", parent_session = session)
  forecastServer("forecast", parent_session = session)
  conclusionServer("conclusion")

  explorerServer("explorer")
  mapServer("map")
  aboutServer("about")
}

shinyApp(ui, server)
