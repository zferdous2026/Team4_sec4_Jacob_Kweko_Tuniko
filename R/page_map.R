# page_map.R
# =============================================================================
# Explore · World Map: one indicator for every country, in a chosen year.
# Built from Jacob's FINALGiniMap.Rmd (plotly choropleth, year slider, compare
# two countries), rebuilt on our cleaned data so it works for every indicator.
#
# Owner: TBD
# Data:  wdi_clean.rds (every country, every year), group_trends.rds (income-
#        group medians, for the country profile)
#
# ## How it works
# 1. Map: for each country, the value in the chosen year. With "latest
#    available", a country with no value that year shows its most recent value
#    from up to 5 years earlier (the hover says which year). Many indicators,
#    like the Gini, aren't measured every year, so this fills most gaps.
# 2. Colours: light to dark blue, scaled to the indicator's real range (5th to
#    95th percentile over all years, so the colours stay comparable when the
#    year slider plays). Skewed indicators (log_scale in indicator_info.csv)
#    use a log colour scale. DARK = WORSE whenever we know which direction is
#    better (higher_is_better); otherwise dark = higher. Grey = no data.
# 3. Country profile: click a country (or pick it in the sidebar) to see its
#    values over time next to its income group's median, and compare it with
#    a second country (Jacob's "compare two countries").
#
# ## Ideas for later
# - Map modes: "Change" (2000s to 2010s, country_change.rds) and "Beating
#   expectations" (country_scores.rds), both with a diverging blue/red scale.
# - Zoom buttons per region: layout(geo = list(scope = "africa")).
#
# Note: plotly downloads the country outlines from the internet when the map
# first loads.
# =============================================================================

# Data (loaded once) -----------------------------------------------------------
map_yearly <- readRDS("data/wdi_clean.rds") %>%
  select(iso3c, country, region, income, year, all_of(info$variable)) %>%
  mutate(year = as.integer(year))

map_groups <- readRDS("data/group_trends.rds") %>%
  filter(group_type == "Income group") %>%
  mutate(year = as.integer(year))

# Dropdown choices: "Ghana" = "GHA", ...
map_country_choices <- map_yearly %>%
  distinct(iso3c, country) %>%
  arrange(country) %>%
  { setNames(.$iso3c, .$country) }

map_colours <- c("#eaf2fc", "#86b6ef", "#3987e5", "#1c5cab", "#0d366b")


# Helpers ----------------------------------------------------------------------

# 1234.5 -> "1,235"; 41.23 -> "41.2"; 0.576 -> "0.58"
format_value <- function(x) {
  vapply(x, function(v) {
    if (is.na(v)) return("no data")
    if (abs(v) >= 1000) return(format(round(v), big.mark = ",", scientific = FALSE))
    if (abs(v) >= 10) return(formatC(v, format = "f", digits = 1))
    formatC(v, format = "f", digits = 2)
  }, character(1))
}

# Value with its unit: "64.5 years", "31.9 (0-100)", "0.58 (index ...)"
# (`unit` is one string for the whole indicator, so this uses if/else, not
# ifelse(): ifelse() with a single TRUE/FALSE would return only ONE value)
with_unit <- function(x, unit) {
  if (grepl("^[0-9]|^index|^score", unit)) {
    paste0(format_value(x), " (", unit, ")")
  } else {
    paste0(format_value(x), " ", unit)
  }
}

# One value per country: the value in `yr`, or (window > 0) the most recent
# value from up to `window` years earlier
map_values <- function(var, yr, window) {
  map_yearly %>%
    filter(year <= yr, year >= yr - window, !is.na(.data[[var]])) %>%
    group_by(iso3c) %>%
    slice_max(year, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    transmute(iso3c, country, region, income, measured = year, value = .data[[var]]) %>%
    # Rank 1 = highest value
    mutate(rank = rank(-value, ties.method = "min"))
}

# Colour range for an indicator: 5th to 95th percentile over all years, so one
# extreme country doesn't wash out the rest, and colours stay comparable
# between years
colour_limits <- function(var, log) {
  v <- map_yearly[[var]]
  v <- v[!is.na(v)]
  if (log) v <- log10(v[v > 0])
  quantile(v, c(0.05, 0.95), names = FALSE)
}

# Legend ticks for a log colour scale: 1, 2, 5, 10, 20, 50, ... in real units
log_ticks <- function(lims) {
  nice <- as.vector(outer(c(1, 2, 5), 10^(-2:6)))
  nice <- nice[log10(nice) >= lims[1] & log10(nice) <= lims[2]]
  list(tickvals = log10(nice), ticktext = prettyNum(nice, big.mark = ","))
}

# The choropleth --------------------------------------------------------------
# source: plotly's name for this chart, so the server can listen for clicks
map_chart <- function(values, var, source) {
  row <- info[info$variable == var, ]
  log <- isTRUE(row$log_scale)
  lims <- colour_limits(var, log)

  values <- values %>%
    mutate(
      z = if (log) ifelse(value > 0, log10(value), NA) else value,
      tip = paste0("<b>", country, "</b>",
                   "<br>", row$label, ": ", with_unit(value, row$unit),
                   "<br>Measured in ", measured,
                   "<br>Rank ", rank, " of ", n(), " (1 = highest)",
                   "<br>", income)
    )

  colorbar <- list(title = list(text = paste0(row$label, "<br>(", row$unit, ")"),
                                font = list(size = 11)),
                   len = 0.75, thickness = 14)
  if (log) colorbar <- c(colorbar, log_ticks(lims))

  plot_ly(values, type = "choropleth", source = source,
          locations = ~iso3c, locationmode = "ISO-3",
          z = ~z, zmin = lims[1], zmax = lims[2],
          colorscale = lapply(seq_along(map_colours), function(i)
            list((i - 1) / (length(map_colours) - 1), map_colours[i])),
          # Dark = worse: if higher is better, flip the scale so LOW values are dark
          reversescale = isTRUE(row$higher_is_better),
          text = ~tip, hoverinfo = "text",
          customdata = ~iso3c,          # which country was clicked
          marker = list(line = list(color = "white", width = 0.4)),
          colorbar = colorbar, height = 520) %>%
    layout(
      geo = list(showframe = FALSE, showcoastlines = FALSE,
                 showland = TRUE, landcolor = "#e3e3e0",    # grey = no data
                 projection = list(type = "natural earth")),
      margin = list(l = 0, r = 0, t = 0, b = 0)
    ) %>%
    config(displayModeBar = FALSE) %>%
    event_register("plotly_click")
}

# Country profile: the country over time, its income group's median, and an
# optional second country
profile_chart <- function(var, iso, compare_iso) {
  row <- info[info$variable == var, ]
  series <- function(code) {
    map_yearly %>% filter(iso3c == code, !is.na(.data[[var]])) %>%
      transmute(year, value = .data[[var]], name = country)
  }

  main <- series(iso)
  group <- map_yearly$income[match(iso, map_yearly$iso3c)]
  median_line <- map_groups %>%
    filter(variable == var, group == !!group, pct_reporting >= 50) %>%
    transmute(year, value = median, name = paste(group, "(median)"))

  p <- plot_ly(height = 320) %>%
    add_lines(data = main, x = ~year, y = ~value, name = ~name[1],
              line = list(color = "#1c5cab", width = 3),
              text = ~paste0(name, ", ", year, ": ", format_value(value)), hoverinfo = "text")

  if (nrow(median_line) > 0) {
    p <- p %>% add_lines(data = median_line, x = ~year, y = ~value, name = ~name[1],
                         line = list(color = "#8a8985", dash = "dash", width = 2),
                         text = ~paste0(name, ", ", year, ": ", format_value(value)), hoverinfo = "text")
  }
  if (!is.null(compare_iso) && compare_iso != "" && compare_iso != iso) {
    other <- series(compare_iso)
    if (nrow(other) > 0) {
      p <- p %>% add_lines(data = other, x = ~year, y = ~value, name = ~name[1],
                           line = list(color = "#eb6834", width = 3),
                           text = ~paste0(name, ", ", year, ": ", format_value(value)), hoverinfo = "text")
    }
  }

  p %>%
    layout(xaxis = list(title = ""),
           yaxis = list(title = paste0(row$label, " (", row$unit, ")"),
                        type = if (isTRUE(row$log_scale)) "log" else "linear"),
           legend = list(orientation = "h", x = 0, y = 1.15),
           margin = list(t = 10)) %>%
    config(displayModeBar = FALSE)
}


# UI ---------------------------------------------------------------------------
mapUI <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      open = list(desktop = "open", mobile = "always"),
      selectInput(ns("var"), "Indicator", choices = indicator_choices(),
                  selected = "swiid_gini"),
      sliderInput(ns("year"), "Year", min = year_range[1], max = year_range[2],
                  value = 2019, step = 1, sep = "",
                  animate = animationOptions(interval = 800)),
      radioButtons(ns("window"), "Countries without data that year",
                   choices = c("Show latest value (up to 5 years earlier)" = 5,
                               "Leave them grey" = 0)),
      hr(),
      selectInput(ns("country"), "Country profile",
                  choices = c("Click the map or choose..." = "", map_country_choices)),
      selectInput(ns("compare"), "Compare with",
                  choices = c("None" = "", map_country_choices))
    ),
    card(
      card_header(textOutput(ns("title"), inline = TRUE)),
      p(class = "text-muted small mb-1", textOutput(ns("summary"), inline = TRUE)),
      plotlyOutput(ns("map"), height = "520px")
    ),
    card(
      card_header("Country profile"),
      uiOutput(ns("profile_text")),
      plotlyOutput(ns("profile"), height = "320px")
    )
  )
}


# Server -----------------------------------------------------------------------
mapServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    source_id <- session$ns("map")
    label <- reactive(info$label[info$variable == input$var])

    values <- reactive(map_values(input$var, input$year, as.numeric(input$window)))

    output$title <- renderText(paste0(label(), ", ", input$year))

    # "Showing 163 of 217 countries · Highest: ... · Lowest: ..."
    output$summary <- renderText({
      v <- values()
      if (nrow(v) == 0) return("No country has data for this year.")
      hi <- v[which.max(v$value), ]
      lo <- v[which.min(v$value), ]
      paste0("Showing ", nrow(v), " of ", n_distinct(map_yearly$iso3c), " countries",
             " · Highest: ", hi$country, " (", format_value(hi$value), ")",
             " · Lowest: ", lo$country, " (", format_value(lo$value), ")")
    })

    output$map <- renderPlotly({
      v <- values()
      validate(need(nrow(v) > 0, "No country has data for this indicator in this year."))
      map_chart(v, input$var, source_id)
    })

    # Clicking a country selects it in the "Country profile" dropdown
    observeEvent(event_data("plotly_click", source = source_id), {
      clicked <- event_data("plotly_click", source = source_id)$customdata[[1]]
      if (!is.null(clicked)) updateSelectInput(session, "country", selected = clicked)
    })

    output$profile_text <- renderUI({
      if (is.null(input$country) || input$country == "") {
        return(p(class = "text-muted", "Click a country on the map to see its history."))
      }
      info_row <- map_yearly[match(input$country, map_yearly$iso3c), ]
      v <- values()
      now <- v[v$iso3c == input$country, ]
      unit <- info$unit[info$variable == input$var]
      # HTML(paste0(...)) builds each line as one string, so no stray spaces
      tagList(
        h5(class = "mb-1", info_row$country),
        p(class = "text-muted mb-2", paste0(info_row$income, " · ", info_row$region)),
        if (nrow(now) == 1) {
          p(HTML(paste0(label(), ": <b>", with_unit(now$value, unit), "</b> in ", now$measured,
                        " (rank ", now$rank, " of ", nrow(v), ", 1 = highest)")))
        } else {
          p(paste0(label(), ": no data around ", input$year))
        }
      )
    })

    output$profile <- renderPlotly({
      req(input$country)
      validate(need(any(!is.na(map_yearly[[input$var]][map_yearly$iso3c == input$country])),
                    "No data for this country and indicator."))
      profile_chart(input$var, input$country, input$compare)
    })
  })
}
