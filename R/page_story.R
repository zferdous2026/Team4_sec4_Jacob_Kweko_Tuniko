# page_story.R
# =============================================================================
# Shared template for every guided story page: the six Evidence pages,
# Over Time, Beating Expectations and Forecast & Models.
#
# A story page is an illustrated article: a sub-question, a takeaway, then
# 2-4 figures in a fixed order, each with a headline that STATES the finding.
# The viewer scrolls and reads; nothing to choose. Free exploration lives in
# the Explorer, reached through each figure's "Explore this yourself" link.
#
# Owner: app lead. Change the LAYOUT here; page owners change the CONTENT
# (figures, captions, takeaway) in their own page_<name>.R file.
#
# ## A figure is a list with:
#   id       figure number shown on the page, e.g. "1"
#   title    the headline: the finding in one short sentence
#            (e.g. "More unequal countries have higher child mortality")
#   chart    what the chart shows; displayed in the grey box until `plot` is set
#   caption  2-3 sentences explaining what the viewer sees ("TODO" until written)
#   plot     (optional) YOUR chart code: function(d) { ... } returning a
#            ggplot (or a plotly chart). Without it, the figure shows the
#            grey placeholder. See below.
#   x, y     (optional) the two indicators the figure compares: adds an
#            "Explore this yourself" link that opens them in the Explorer
#   toggle   (optional) label of one checkbox, e.g. "Show by income group"
#   control  (optional) function(ns) returning one extra input, e.g. a
#            country dropdown. Keep these rare.
#   height   (optional) chart height, default "420px"
#   exclude  (optional) iso3c codes to leave out of d, e.g. financial hubs
#
# ## Your chart: plot = function(d) { ... }
# Write the chart in your notebook first, then paste the ggplot code into the
# figure. `d` is the 2010s data (one row per country, minus any `exclude`d
# countries). The chart becomes interactive (hover) automatically.
#
#   plot = function(d) {
#     ggplot(d, aes(x = region, y = life_expect)) +
#       geom_boxplot()
#   }
#
# - Working example: R/page_inequality.R (Jacob's chart, written once as a
#   function and used by two figures).
# - Hover text: by default it shows the plotted values. For your own text,
#   add aes(text = ...) to a layer (as Jacob's chart does); then only that
#   text is shown.
# - Other data (changes, scores, yearly data): load it ONCE at the top of
#   your page file, e.g.  change_data <- readRDS("data/country_change.rds"),
#   and use that inside the function instead of d.
# - With a toggle: write function(d, toggle) { ... }; `toggle` is TRUE when
#   the checkbox is ticked, so you can change the chart with an if.
# =============================================================================

# The `d` every chart receives: one row per country, 2010s averages (loaded once)
story_data <- readRDS("data/country_period.rds") %>% filter(period == "2010-2019")

# Does a ggplot set its own hover text with aes(text = ...)?
has_hover_text <- function(p) {
  mappings <- c(list(p$mapping), lapply(p$layers, function(layer) layer$mapping))
  any(vapply(mappings, function(m) "text" %in% names(m), logical(1)))
}

# One figure: headline, chart, caption, optional toggle/control and link
figure_card <- function(ns, fig) {
  height <- if (is.null(fig$height)) "420px" else fig$height

  card(
    class = "mb-4",
    card_header(tags$span(class = "text-muted me-2", paste0("Figure ", fig$id)),
                tags$b(fig$title)),
    if (!is.null(fig$control)) fig$control(ns),
    if (!is.null(fig$plot)) {
      # height = "auto": the chart sets its own height (see story_server)
      plotlyOutput(ns(paste0("plot_", fig$id)), height = "auto")
    } else {
      placeholder(fig$chart, height)
    },
    p(class = "mt-3 mb-1", fig$caption),
    div(
      class = "d-flex justify-content-between align-items-center",
      if (!is.null(fig$toggle)) checkboxInput(ns(paste0("toggle_", fig$id)), fig$toggle) else span(),
      if (!is.null(fig$x)) actionLink(ns(paste0("explore_", fig$id)), "Explore this yourself →")
    )
  )
}

story_page <- function(id, title, subquestion, takeaway, figures, next_label = NULL) {
  ns <- NS(id)

  div(
    class = "container-lg py-3", style = "max-width: 960px;",
    h2(title),
    p(class = "lead", subquestion),
    div(class = "alert alert-primary", tags$b("Takeaway: "), takeaway),
    lapply(figures, function(fig) figure_card(ns, fig)),
    if (!is.null(next_label)) next_button(ns, next_label)
  )
}

story_server <- function(id, figures, parent_session, next_page = NULL) {
  moduleServer(id, function(input, output, session) {
    if (!is.null(next_page)) go_to_next(input, parent_session, next_page)

    for (fig in figures) {
      local({
        f <- fig

        # "Explore this yourself" link
        if (!is.null(f$x)) {
          observeEvent(input[[paste0("explore_", f$id)]],
                       open_in_explorer(parent_session, f$x, f$y))
        }

        # The chart
        if (is.null(f$plot)) return()

        data <- story_data
        if (!is.null(f$exclude)) data <- filter(data, !iso3c %in% f$exclude)
        height <- if (is.null(f$height)) 420 else as.numeric(sub("px", "", f$height))

        output[[paste0("plot_", f$id)]] <- renderPlotly({
          toggle <- isTRUE(input[[paste0("toggle_", f$id)]])

          # The owner's chart code: give it the toggle only if it asks for it
          chart <- if (length(formals(f$plot)) >= 2) f$plot(data, toggle) else f$plot(data)

          # A ggplot becomes an interactive plotly chart
          if (inherits(chart, "ggplot")) {
            chart <- ggplotly(chart, height = height,
                              tooltip = if (has_hover_text(chart)) "text" else "all") %>%
              layout(legend = list(orientation = "h", x = 0, y = -0.18)) %>%
              config(displayModeBar = FALSE)
          }
          chart
        })
      })
    }
  })
}
