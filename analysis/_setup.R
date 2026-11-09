# analysis/_setup.R
# =============================================================================
# Shared setup for every notebook in analysis/: loads the data and defines the
# same analysis functions for everyone, so all pages report results the same
# way. Each notebook runs source("analysis/_setup.R") in its first chunk.
# =============================================================================

library(dplyr)
library(ggplot2)

country_period <- readRDS("data/country_period.rds")   # country x decade averages
country_change <- readRDS("data/country_change.rds")   # 2000s -> 2010s changes
country_scores <- readRDS("data/country_scores.rds")   # actual vs expected from GDP
info           <- read.csv("data/indicator_info.csv", stringsAsFactors = FALSE)

# One row per country for one decade (default: the 2010s)
decade <- function(period = "2010-2019") {
  country_period %>% filter(.data$period == !!period)
}

# Spearman correlation between x and y: n, r, p-value
spearman <- function(data, x, y) {
  d <- data %>% filter(!is.na(.data[[x]]), !is.na(.data[[y]]))
  if (nrow(d) < 3) return(tibble(n = nrow(d), r = NA_real_, p = NA_real_))
  test <- cor.test(d[[x]], d[[y]], method = "spearman", exact = FALSE)
  tibble(n = nrow(d), r = round(unname(test$estimate), 2), p = signif(test$p.value, 2))
}

# "Beyond GDP": partial Spearman correlation between x and y, controlling for
# a third variable (default log GDP per capita). Method: rank all three, take
# the residuals of x and y after regressing each on the control, and correlate
# the residuals. Use control = "pct_gdp_per_capita" for change data (growth).
beyond <- function(data, x, y, control = "gdp_per_capita") {
  d <- data %>% filter(!is.na(.data[[x]]), !is.na(.data[[y]]), !is.na(.data[[control]]))
  if (nrow(d) < 4) return(tibble(n = nrow(d), partial_r = NA_real_))
  rx <- resid(lm(rank(d[[x]]) ~ rank(d[[control]])))
  ry <- resid(lm(rank(d[[y]]) ~ rank(d[[control]])))
  tibble(n = nrow(d), partial_r = round(cor(rx, ry), 2))
}

# Spearman correlation separately within each income group
by_income <- function(data, x, y) {
  data %>%
    filter(!is.na(income)) %>%
    group_by(income) %>%
    group_modify(~ spearman(.x, x, y)) %>%
    ungroup()
}

# Quick exploratory scatter, for looking at the data (website charts are written in each page file)
quick_scatter <- function(data, x, y, log_x = FALSE, log_y = FALSE) {
  p <- data %>%
    filter(!is.na(.data[[x]]), !is.na(.data[[y]])) %>%
    ggplot(aes(.data[[x]], .data[[y]], colour = income)) +
    geom_point(alpha = 0.8) +
    geom_smooth(aes(group = 1), method = "lm", formula = y ~ x, se = FALSE, colour = "grey30") +
    labs(x = x, y = y, colour = "Income group") +
    theme_minimal()
  if (log_x) p <- p + scale_x_log10()
  if (log_y) p <- p + scale_y_log10()
  p
}

# Everything for one question in one call: overall r, r beyond GDP, by income
summarise_question <- function(data, x, y, control = "gdp_per_capita") {
  list(
    overall    = spearman(data, x, y),
    beyond_gdp = beyond(data, x, y, control),
    by_income  = by_income(data, x, y)
  )
}
