# helpers.R
# =============================================================================
# Shared pieces used by every page: indicator lists, placeholders, shared
# controls and the "Next ->" navigation.
#
# Shiny automatically runs every file in the R/ folder (in alphabetical order)
# before app.R, so everything defined here is available to all pages.
#
# Owner: app lead. Other team members: please ask before changing this file,
# because every page depends on it. Charts go in each page file, not here.
# =============================================================================

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)


# -----------------------------------------------------------------------------
# 1. Indicator list (for dropdowns)
# -----------------------------------------------------------------------------
# Data dictionary: labels, units, sources, coverage (built by 03_summaries.R)
info <- read.csv("data/indicator_info.csv", stringsAsFactors = FALSE)

year_range <- c(min(info$first_year), max(info$last_year))

# World Bank regions (for region filters)
regions <- c("East Asia & Pacific", "Europe & Central Asia",
             "Latin America & Caribbean",
             "Middle East, North Africa, Afghanistan & Pakistan",
             "North America", "South Asia", "Sub-Saharan Africa")

# "infant_mort" -> "Infant mortality"
var_label <- function(var) info$label[match(var, info$variable)]

# Dropdown choices grouped by theme, e.g. list(Health = c("Life expectancy" = "life_expect", ...))
indicator_choices <- function(variables = info$variable) {
  rows <- info[info$variable %in% variables, ]
  split(setNames(rows$variable, rows$label), rows$theme)
}

# Colour-by options shown in dropdowns: label -> column name
colour_options <- c("Income group" = "income", "Continent" = "continent")


# -----------------------------------------------------------------------------
# 2. Placeholders (replaced by real charts and tables as pages are built)
# -----------------------------------------------------------------------------

# Grey dashed box marking where a chart or table will go
placeholder <- function(label, height = "300px") {
  div(
    class = "d-flex align-items-center justify-content-center text-muted text-center p-3",
    style = paste0("height:", height, "; border:2px dashed #c8c7c1;",
                   "border-radius:8px; background:#f7f7f5;"),
    label
  )
}


# -----------------------------------------------------------------------------
# 3. Shared controls
# -----------------------------------------------------------------------------

# Which years to use and how to turn them into one value per country
year_controls <- function(ns, value = c(2010, 2019)) {
  tagList(
    sliderInput(ns("years"), "Years", min = year_range[1], max = year_range[2],
                value = value, step = 1, sep = ""),
    radioButtons(ns("method"), "One value per country",
                 choices = c("Average over the years" = "average",
                             "Latest available year" = "latest"))
  )
}



# -----------------------------------------------------------------------------
# 4. Story navigation
# -----------------------------------------------------------------------------
# The story pages are meant to be read in order (see app.R). Each one ends
# with a "Next ->" button, and each scatter figure has an "Explore this
# yourself" link that opens the Explorer with the same two indicators.
# parent_session is the app's main session (passed in from app.R): a module's
# own session can't see the navbar or the Explorer, which belong to the main app.

next_button <- function(ns, label) {
  div(class = "d-flex justify-content-end mt-3 mb-4",
      actionButton(ns("next_page"), paste("Next:", label, "→"), class = "btn-primary"))
}

go_to_next <- function(input, parent_session, page) {
  observeEvent(input$next_page, nav_select("main_nav", page, session = parent_session))
}

# Open the Explorer with x and y preselected
open_in_explorer <- function(parent_session, x, y) {
  updateSelectInput(parent_session, "explorer-x", selected = x)
  updateSelectInput(parent_session, "explorer-y", selected = y)
  nav_select("main_nav", "explorer", session = parent_session)
}
