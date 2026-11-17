# page_wealth.R
# =============================================================================
# The Evidence · 1. Wealth
# Owner: TBD
#
# ## This page is a blank template: write your own questions and graphs
# 1. Choose the page's question (the second argument of story_page() below)
#    and 2-4 figures, each answering one smaller question.
#    Ideas: docs/question_bank.md     Variables: docs/variables.md
# 2. Work out the answer in a notebook in analysis/ (see analysis/README.md).
# 3. Fill in each figure below:
#      title    the FINDING in one sentence ("Richer countries live longer"),
#               not the variables ("GDP vs life expectancy")
#      chart    what the graph shows (displayed until the real graph exists)
#      caption  2-3 sentences: what the graph shows, the key number, what it means
# 4. Add your chart: paste the ggplot code from your notebook into the figure,
#        plot = function(d) { ggplot(d, aes(...)) + ... }
#    d = 2010s data, one row per country. Any chart type works.
#    Optional: x = "...", y = "..." (adds an "Explore this yourself" link),
#    toggle = "...", exclude = c("LUX", ...).
#    Details and examples: header of R/page_story.R.
# 5. Add or remove figures freely (copy a list(...) block). Then write the
#    takeaway: the page's answer in one sentence.
#
# Working example: R/page_inequality.R (Jacob's figure).
#
# ## Data
#   data/country_period.rds (2010s averages): any variable in docs/variables.md.
#   Figure 2 also uses data/wdi_clean.rds (every year), loaded below.
# =============================================================================

# Data for the animated chart: every country, every year (loaded once)
wealth_yearly <- readRDS("data/wdi_clean.rds") %>%
  filter(!is.na(gdp_per_capita), !is.na(life_expect), !is.na(total_pop), !is.na(region)) %>%
  select(country, region, year, gdp_per_capita, life_expect, total_pop)

# Figure 1: the Preston curve --------------------------------------------------
# d: 2010s data, one row per country (given by the template).
preston_chart <- function(d) {
  colours <- c("Low income" = "#86b6ef", "Lower middle income" = "#3987e5",
               "Upper middle income" = "#1c5cab", "High income" = "#0d366b")

  d <- d %>%
    filter(!is.na(gdp_per_capita), !is.na(life_expect), !is.na(income)) %>%
    mutate(tip = paste0("<b>", country, "</b>",
                        "<br>", income,
                        "<br>GDP per capita: $", format(round(gdp_per_capita), big.mark = ","),
                        "<br>Life expectancy: ", round(life_expect, 1), " years"))

  ggplot(d, aes(x = gdp_per_capita, y = life_expect)) +
    # A curve (loess), not a straight line: gains are steep at low incomes and
    # level off at high incomes. That bend is the "Preston curve".
    geom_smooth(method = "loess", formula = y ~ x, se = FALSE,
                colour = "#52514e", linewidth = 0.8) +
    suppressWarnings(geom_point(aes(colour = income, text = tip),
                                size = 2.3, alpha = 0.85)) +
    scale_colour_manual(values = colours, name = NULL) +
    scale_x_log10(labels = scales::label_dollar()) +
    labs(x = "GDP per capita (constant 2015 US$, log scale)",
         y = "Life expectancy (years)") +
    theme_minimal(base_size = 12) +
    theme(panel.grid.minor = element_blank())
}

# Figure 2: animated development path ------------------------------------------
# Built with plot_ly (not ggplot) because plotly can animate: `frame = ~year`
# makes one frame per year and adds a play button and year slider.
# `ids = ~country` tells plotly which bubble is which, so each one glides from
# year to year instead of jumping. Uses wealth_yearly, not d.
development_path_chart <- function() {
  colours <- c("East Asia & Pacific" = "#2a78d6", "Europe & Central Asia" = "#eda100",
               "Latin America & Caribbean" = "#eb6834",
               "Middle East, North Africa, Afghanistan & Pakistan" = "#8a63d2",
               "North America" = "#52514e", "South Asia" = "#1baf7a",
               "Sub-Saharan Africa" = "#e87ba4")

  data <- wealth_yearly %>%
    # Sorted by colour group, then year: plotly splits the data into one trace
    # per region and one frame per year, and the bubble sizes only line up with
    # the right countries when the rows are already in that order
    arrange(region, year, country) %>%
    mutate(year = as.integer(year),
           tip = paste0("<b>", country, "</b> (", year, ")",
                        "<br>GDP per capita: $", format(round(gdp_per_capita), big.mark = ","),
                        "<br>Life expectancy: ", round(life_expect, 1), " years",
                        "<br>Population: ", format(round(total_pop / 1e6, 1), nsmall = 1), " million"))

  plot_ly(data, x = ~gdp_per_capita, y = ~life_expect,
          color = ~region, colors = colours,
          frame = ~year, ids = ~country,
          text = ~tip, hoverinfo = "text",
          type = "scatter", mode = "markers",
          # Bubble AREA proportional to population. sizeref sets the scale:
          # the biggest country (China/India) gets a bubble about 60px across.
          marker = list(size = ~total_pop, sizemode = "area",
                        sizeref = 2 * max(data$total_pop) / 60^2, sizemin = 3,
                        opacity = 0.75),
          height = 560) %>%
    layout(
      # Fixed axis ranges, so the axes don't jump around while it plays
      xaxis = list(type = "log", range = c(log10(100), log10(300000)),
                   title = "GDP per capita (constant 2015 US$, log scale)"),
      yaxis = list(range = c(10, 90), title = "Life expectancy (years)"),
      legend = list(orientation = "h", x = 0, y = 1.15)
    ) %>%
    animation_opts(frame = 150, transition = 100, redraw = FALSE) %>%
    animation_slider(currentvalue = list(prefix = "Year: ")) %>%
    config(displayModeBar = FALSE)
}

wealth_figures <- list(
  list(
    id = "1", title = "Richer countries live much longer",
    chart = "Scatter: GDP per capita (log scale) vs life expectancy, 2010s, with a curved trend",
    x = "gdp_per_capita", y = "life_expect",
    plot = function(d) preston_chart(d),
    caption = "Preliminary: r = 0.87 across 213 countries. Life expectancy rises steeply as countries move out of poverty, then levels off among rich countries (the 'Preston curve'). TODO"
  ),
  list(
    id = "2", title = "Since 1960, countries have grown richer and longer-lived",
    chart = "Animated bubbles: GDP per capita vs life expectancy, 1960-2024, bubble size = population",
    plot = function(d) development_path_chart(),
    height = "560px",
    caption = "Preliminary: press play. Each bubble is a country (size = population, colour = region), moving year by year from 1960 to 2024. TODO"
  ),
  list(
    id = "3", title = "Q3: TODO (write the finding as a headline)",
    chart = "Fig 3: TODO (which graph, which variables)",
    caption = "TODO: 2-3 sentences."
  )
)

wealthUI <- function(id) {
  story_page(
    id, "1. Wealth",
    "TODO: the question this page answers",
    "TODO: the answer in one sentence",
    wealth_figures, next_label = "2. Inequality"
  )
}

wealthServer <- function(id, parent_session) {
  story_server(id, wealth_figures, parent_session, next_page = "inequality")
}
