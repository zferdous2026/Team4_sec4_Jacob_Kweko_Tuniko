# page_about.R
# =============================================================================
# About: sources, definitions, methods, what's already known, how
# robust the findings are, and a data download.
# Owner: TBD
#
# ## Your tasks
# 1. Coverage chart: % of country-years with data per indicator
#    (data/indicator_info.csv: coverage_2010s, coverage_full).
# 2. Indicator table: label, unit, source, code, years, countries, coverage.
# 3. "What's already known": 1 paragraph citing Preston (1975); Wilkinson &
#    Pickett (2009); Avendano (2012); Leigh (& Jencks?); Good Health at Low
#    Cost (1985); "punching above their weight" (2020). CHECK every citation
#    against the paper itself before using it.
# 4. "How fragile are the findings?" (questions G1, G2): single year vs decade
#    average; with/without Europe; World Bank vs SWIID Gini; small states.
# 5. Download button for data/wdi_clean.csv.
# =============================================================================

aboutUI <- function(id) {
  ns <- NS(id)

  tagList(
    h3("About the data and methods"),
    layout_columns(
      col_widths = c(6, 6),
      card(
        card_header("Sources"),
        tags$ul(
          tags$li(tags$b("World Bank, World Development Indicators"),
                  " (R package WDI): income, health, education, spending, aid, FDI."),
          tags$li(HTML("<b>SWIID</b>, Standardized World Income Inequality Database v9.92",
                       "(Solt): harmonised Gini index.")),
          tags$li(tags$b("World Happiness Report 2026"), " (Gallup World Poll): life evaluation."),
          tags$li(HTML("<b>V-Dem</b>, Varieties of Democracy (R package vdemdata):",
                       "democracy, health and education equality, corruption."))
        )
      ),
      card(
        card_header("Methods"),
        tags$ul(
          tags$li("Regional and income-group aggregates are removed; 217 countries remain."),
          tags$li("Each country gets one value per decade (the average of the years with data)."),
          tags$li("Relationships use Spearman correlation (rank-based, robust to outliers)."),
          tags$li("'Beyond GDP' = partial correlation controlling for log GDP per capita."),
          tags$li("Over time = change between the 2000s and 2010s decade averages."),
          tags$li("Expected values = prediction from log GDP per capita (2010s)."),
          tags$li("Income groups and regions are the World Bank's current classifications."),
          tags$li("All results show association, not causation.")
        )
      )
    ),
    card(card_header("How complete is each indicator?"),
         placeholder("Bar chart: % of country-years with data, per indicator", "520px")),
    card(card_header("Indicators"),
         placeholder("Table: name, unit, source, code, years, countries, coverage", "300px")),
    layout_columns(
      col_widths = c(6, 6),
      card(card_header("What's already known, and what we add"),
           placeholder("Literature paragraph + 'what we add' table", "220px")),
      card(card_header("How fragile are the findings?"),
           placeholder("Robustness checks: years, Europe, Gini source, small states (G1, G2)", "220px"))
    ),
    placeholder("Download the data (CSV) button", "60px")
  )
}

aboutServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # TODO: coverage chart, indicator table, CSV download
  })
}
