# page_explorer.R
# =============================================================================
# Explore · Explorer: pick any two indicators and see how they relate across
# countries, with the same numbers the story pages use (Spearman r, r at
# similar income levels, r within each income group).
#
# Every "Explore this yourself ->" link on the story pages opens this page with
# that figure's x and y already chosen (open_in_explorer() in helpers.R sets
# the inputs "explorer-x" and "explorer-y").
#
# Owner: app lead
# Data:  country_period.rds (decade averages: one value per country per decade)
#
# ## Controls (kept deliberately few)
#   X, Y          any of the 31 indicators
#   Decade        which decade's averages (default: the 2010s)
#   Colour by     income group or region
#   Split         one panel per income group
#   Highlight     find one country (bigger dot with its name)
# Log axes are chosen automatically from log_scale in indicator_info.csv.
# =============================================================================

# Data (loaded once) -----------------------------------------------------------
explorer_data <- readRDS("data/country_period.rds")

# Decade choices: "1960s" = "1960-1969", ..., "2020s" = "2020-2025"
explorer_periods <- sort(unique(explorer_data$period))
names(explorer_periods) <- paste0(substr(explorer_periods, 1, 4), "s")

explorer_countries <- sort(unique(explorer_data$country))

income_palette <- c("Low income" = "#86b6ef", "Lower middle income" = "#3987e5",
                    "Upper middle income" = "#1c5cab", "High income" = "#0d366b")
region_palette <- c("East Asia & Pacific" = "#2a78d6", "Europe & Central Asia" = "#eda100",
                    "Latin America & Caribbean" = "#eb6834",
                    "Middle East, North Africa, Afghanistan & Pakistan" = "#8a63d2",
                    "North America" = "#52514e", "South Asia" = "#1baf7a",
                    "Sub-Saharan Africa" = "#e87ba4")


# Statistics -------------------------------------------------------------------
# Spearman r between x and y (NA if fewer than 3 countries)
explorer_r <- function(x, y) {
  ok <- !is.na(x) & !is.na(y)
  if (sum(ok) < 3) return(NA_real_)
  cor(x[ok], y[ok], method = "spearman")
}

# r at similar income levels: remove what GDP per capita explains (in ranks)
# from both variables, then correlate what is left (as in analysis/_setup.R)
explorer_r_beyond <- function(x, y, gdp) {
  ok <- !is.na(x) & !is.na(y) & !is.na(gdp)
  if (sum(ok) < 5) return(NA_real_)
  rx <- resid(lm(rank(x[ok]) ~ rank(gdp[ok])))
  ry <- resid(lm(rank(y[ok]) ~ rank(gdp[ok])))
  cor(rx, ry)
}

# A label inside a sentence: "Life expectancy" -> "life expectancy", but
# names and acronyms stay as they are ("Gini index (SWIID ...)", "GDP growth")
in_sentence <- function(label) {
  first <- sub(" .*", "", label)
  if (first %in% c("Gini", "GDP", "HIV", "FDI") || first == toupper(first)) return(label)
  paste0(tolower(substr(label, 1, 1)), substr(label, 2, nchar(label)))
}

# "strong", "moderate", ... for the plain-English summary
strength_word <- function(r) {
  a <- abs(r)
  if (a >= 0.6) "strong" else if (a >= 0.4) "moderate" else if (a >= 0.2) "weak" else "no clear"
}


# Chart ------------------------------------------------------------------------
# Built like Jacob's scatter: one dot per country, one trend line, hover text
explorer_chart <- function(d, x, y, colour_by, split, highlight) {
  x_info <- info[info$variable == x, ]
  y_info <- info[info$variable == y, ]
  log_x <- isTRUE(x_info$log_scale)
  log_y <- isTRUE(y_info$log_scale)
  colours <- if (colour_by == "income") income_palette else region_palette

  d <- d %>%
    filter(!is.na(.data[[x]]), !is.na(.data[[y]]), !is.na(income)) %>%
    mutate(
      group = as.character(.data[[colour_by]]),
      tip = paste0("<b>", country, "</b>",
                   "<br>", income, ", ", region,
                   "<br>", x_info$label, ": ", round(.data[[x]], 2),
                   "<br>", y_info$label, ": ", round(.data[[y]], 2))
    )

  p <- ggplot(d, aes(x = .data[[x]], y = .data[[y]])) +
    geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    suppressWarnings(geom_point(aes(colour = group, text = tip),
                                size = 2.3, alpha = 0.8)) +
    scale_colour_manual(values = colours, name = NULL) +
    labs(x = paste0(x_info$label, " (", x_info$unit, ")", if (log_x) ", log scale"),
         y = paste0(y_info$label, if (log_y) " (log scale)")) +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())

  # Highlighted country: a large ring and its name
  if (!is.null(highlight) && highlight != "" && highlight %in% d$country) {
    h <- d %>% filter(country == highlight)
    p <- p +
      geom_point(data = h, shape = 21, size = 6, stroke = 1.5,
                 colour = "#e2523a", fill = NA) +
      geom_text(data = h, aes(label = country), vjust = -1.6,
                colour = "#e2523a", fontface = "bold", size = 4)
  }

  if (log_x) p <- p + scale_x_log10()
  if (log_y) p <- p + scale_y_log10()
  if (split) p <- p + facet_wrap(~ income, ncol = 2) + theme(legend.position = "none")
  p
}


# UI ---------------------------------------------------------------------------
explorerUI <- function(id) {
  ns <- NS(id)

  layout_sidebar(
    sidebar = sidebar(
      width = 300,
      open = list(desktop = "open", mobile = "always"),
      selectInput(ns("x"), "X axis", choices = indicator_choices(),
                  selected = "swiid_gini"),
      selectInput(ns("y"), "Y axis", choices = indicator_choices(),
                  selected = "under5_mort"),
      selectInput(ns("period"), "Decade", choices = explorer_periods,
                  selected = "2010-2019"),
      radioButtons(ns("colour_by"), "Colour by",
                   choices = c("Income group" = "income", "Region" = "region"),
                   inline = TRUE),
      checkboxInput(ns("split"), "Split by income group"),
      selectizeInput(ns("highlight"), "Highlight a country",
                     choices = c("None" = "", explorer_countries)),
      p(class = "small text-muted mt-2",
        "Axes switch to a log scale automatically for skewed indicators ",
        "such as GDP and child mortality.")
    ),

    card(
      card_header(textOutput(ns("title"), inline = TRUE)),
      plotlyOutput(ns("chart"), height = "auto")
    ),
    uiOutput(ns("stats")),
    layout_columns(
      col_widths = c(7, 5),
      card(card_header("What it shows"), uiOutput(ns("summary"))),
      card(card_header("Within each income group"), tableOutput(ns("by_income")))
    )
  )
}


# Server -----------------------------------------------------------------------
explorerServer <- function(id) {
  moduleServer(id, function(input, output, session) {

    # Countries with both values in the chosen decade
    data <- reactive({
      explorer_data %>%
        filter(period == input$period, !is.na(.data[[input$x]]), !is.na(.data[[input$y]]))
    })

    labels <- reactive(list(
      x = info$label[info$variable == input$x],
      y = info$label[info$variable == input$y],
      decade = names(explorer_periods)[explorer_periods == input$period]
    ))

    output$title <- renderText(paste0(labels()$y, " vs ", labels()$x, ", ", labels()$decade))

    # The three numbers, calculated once and shared by the outputs below
    stats <- reactive({
      d <- data()
      list(
        n = nrow(d),
        r = explorer_r(d[[input$x]], d[[input$y]]),
        # "at similar income" is meaningless when GDP itself is one of the axes
        beyond = if ("gdp_per_capita" %in% c(input$x, input$y)) NA_real_
                 else explorer_r_beyond(d[[input$x]], d[[input$y]], d$gdp_per_capita)
      )
    })

    output$chart <- renderPlotly({
      d <- data()
      validate(need(nrow(d) >= 3, "Too few countries have both indicators in this decade. Try another decade."))
      height <- if (input$split) 620 else 480
      p <- explorer_chart(d, input$x, input$y, input$colour_by, input$split, input$highlight)
      ggplotly(p, height = height, tooltip = "text") %>%
        layout(legend = list(orientation = "h", x = 0, y = -0.2), font = chart_font) %>%
        config(displayModeBar = FALSE)
    })

    # The stats strip: countries, r, r at similar income
    output$stats <- renderUI({
      s <- stats()
      box <- function(value, label) {
        div(class = "stat-box",
            div(class = "stat-value", value),
            div(class = "stat-label", label))
      }
      fmt <- function(r) if (is.na(r)) "—" else sub("-", "−", sprintf("%.2f", r))
      layout_columns(
        col_widths = c(4, 4, 4), class = "mb-3",
        box(s$n, "countries with both values"),
        box(fmt(s$r), "Spearman r (all countries)"),
        box(fmt(s$beyond), "r at similar income levels")
      )
    })

    # Plain-English summary
    output$summary <- renderUI({
      s <- stats()
      if (is.na(s$r)) return(p("Not enough countries to calculate a correlation."))
      direction <- if (s$r > 0) "higher" else "lower"
      first <- if (strength_word(s$r) == "no clear") {
        paste0("Across ", s$n, " countries in the ", labels()$decade, ", there is no clear link between ",
               in_sentence(labels()$x), " and ", in_sentence(labels()$y), " (r = ", sprintf("%.2f", s$r), ").")
      } else {
        paste0("Across ", s$n, " countries in the ", labels()$decade, ", countries with higher ",
               in_sentence(labels()$x), " tend to have ", direction, " ", in_sentence(labels()$y),
               ": a ", strength_word(s$r), " link (r = ", sprintf("%.2f", s$r), ").")
      }
      second <- if (is.na(s$beyond)) {
        NULL
      } else if (abs(s$beyond) < 0.2) {
        paste0("At similar income levels the link mostly disappears (r = ", sprintf("%.2f", s$beyond),
               "), so it is largely about how rich countries are.")
      } else {
        paste0("It holds at similar income levels (r = ", sprintf("%.2f", s$beyond),
               "), so it is not just about wealth.")
      }
      tagList(p(first), if (!is.null(second)) p(second),
              p(class = "small text-muted", "A correlation shows a link, not a cause."))
    })

    # r within each income group
    output$by_income <- renderTable({
      data() %>%
        filter(!is.na(income)) %>%
        group_by(`Income group` = income) %>%
        summarise(Countries = n(),
                  r = explorer_r(.data[[input$x]], .data[[input$y]]),
                  .groups = "drop") %>%
        mutate(r = ifelse(is.na(r), "—", sprintf("%.2f", r)))
    }, striped = TRUE, spacing = "s")
  })
}
