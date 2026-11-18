# app.R
# =============================================================================
# Layout only: the navbar and which page goes where.
# Each page lives in its own file in R/ (Shiny loads that folder automatically).
# Shared helpers: R/helpers.R · story page template: R/page_story.R
# (charts are written in each page file)
#
# The navbar has four items: Home, Story (the guided pages in reading order:
#   1-6 -> Over Time -> Beating Expectations -> Forecast & Models ->
#   Conclusion), Explore (Explorer, World Map) and About.
# Story pages are guided: fixed figures with headline findings, no choices.
# Each ends with a "Next ->" button; the `value` of each nav_panel
# ("wealth", "inequality", ...) is what those buttons use.
# Explore (Explorer, World Map) is for free exploration.
#
# Run the app: open this file in RStudio and click "Run App",
# or run shiny::runApp() in the console from the project folder.
# =============================================================================

# Look of the whole site ------------------------------------------------------
# Fonts: a serif for headings and a clean sans-serif for text (the "data
# journalism article" look). font_google() downloads them the first time the
# app runs and keeps a copy, so it needs internet once.
# bs_add_rules() adds our own CSS on top of Bootstrap: the takeaway pull-quote,
# the key-number badges on figures, and softer cards. $primary etc. are
# Bootstrap's variables, so the CSS follows the theme colours.
app_theme <- bs_theme(
  version = 5,
  primary = "#1c5cab",
  base_font = font_google("Inter"),
  heading_font = font_google("Fraunces", wght = c(500, 600))
) %>%
  bs_add_rules("
    .story-page h2 { font-size: 2.4rem; margin-bottom: .25rem; }
    .story-page .lead { color: #55595e; }
    .takeaway {
      border-left: 6px solid $primary; background: rgba($primary, .05);
      border-radius: 0 10px 10px 0; padding: 1rem 1.4rem; margin: 1.5rem 0 2rem;
      font-family: $headings-font-family; font-size: 1.35rem; line-height: 1.45;
    }
    .takeaway-label {
      display: block; font-family: $font-family-sans-serif; font-size: .72rem;
      font-weight: 600; letter-spacing: .08em; text-transform: uppercase;
      color: $primary; margin-bottom: .3rem;
    }
    .card { border-color: #e6e6e3; box-shadow: 0 1px 3px rgba(0, 0, 0, .05); }
    .card-header { background: transparent; border-bottom-color: #efefec; }
    .figure-stat {
      background: rgba($primary, .1); color: $primary; font-weight: 600;
      border-radius: 999px; padding: .2rem .7rem; font-size: .8rem; white-space: nowrap;
    }
    .figure-caption { color: #4a4d52; }
    .stat-box { border: 1px solid #e6e6e3; border-radius: 10px; padding: .7rem 1rem; height: 100%; }
    .stat-box .stat-value { font-family: $headings-font-family; font-size: 1.7rem; color: $primary; }
    .stat-box .stat-label { font-size: .8rem; color: #6b6f75; }
  ")

ui <- page_navbar(
  id = "main_nav",
  title = "Beyond Wealth",
  theme = app_theme,
  # Dark blue navbar with light text
  navbar_options = navbar_options(bg = "#0d366b", theme = "dark"),
  # Pages scroll normally. The Explorer and map could stretch to the window
  # instead: fillable = c("explorer", "map")
  fillable = FALSE,

  nav_panel("Home", homeUI("home"), value = "home"),

  # The whole guided story in one menu, in reading order. "----" draws a
  # divider line inside the menu.
  nav_menu(
    "Story",
    nav_panel("1. Wealth",          wealthUI("wealth"),             value = "wealth"),
    nav_panel("2. Inequality",      inequalityUI("inequality"),     value = "inequality"),
    nav_panel("3. Public Spending", spendingUI("spending"),         value = "spending"),
    nav_panel("4. Foreign Money",   foreignUI("foreign"),           value = "foreign"),
    nav_panel("5. Wellbeing",       wellbeingUI("wellbeing"),       value = "wellbeing"),
    nav_panel("6. Institutions",    institutionsUI("institutions"), value = "institutions"),
    "----",
    nav_panel("Over Time",            overTimeUI("over_time"),        value = "over_time"),
    nav_panel("Beating Expectations", expectationsUI("expectations"), value = "expectations"),
    nav_panel("Forecast & Models",    forecastUI("forecast"),         value = "forecast"),
    "----",
    nav_panel("Conclusion",           conclusionUI("conclusion"),     value = "conclusion")
  ),

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
