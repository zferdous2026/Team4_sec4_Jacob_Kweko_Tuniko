# 01_download_wdi.R
# =============================================================================
# Purpose: Download World Bank WDI indicators and save each as a raw CSV
# Output:  data-raw/<name>.csv (one file per indicator; the file name is also
#          the column name used everywhere else in the project)
# Run from the project root. Pipeline:
#   01_download_wdi.R -> 01b_external_data.R -> 02_clean_join.R ->
#   03_summaries.R -> 04_changes_scores.R
#
# By default only indicators WITHOUT a CSV yet are downloaded, so re-running
# the script doesn't silently change data the team is already using.
# Set refresh <- TRUE to re-download everything (e.g. once, before submitting).
# =============================================================================

if (!requireNamespace("WDI", quietly = TRUE)) install.packages("WDI")
library(WDI)

refresh <- FALSE

# Name = column name in our data, value = World Bank indicator code.
# To add an indicator: add a line here, run this script and 02-04, then add a
# row for it in the dictionary in 03_summaries.R.
indicators <- c(
  # Controls and scaling
  gdp_per_capita   = "NY.GDP.PCAP.KD",
  total_pop        = "SP.POP.TOTL",
  gdp_growth       = "NY.GDP.MKTP.KD.ZG",
  tax_revenue      = "GC.TAX.TOTL.GD.ZS",
  urban_pop        = "SP.URB.TOTL.IN.ZS",

  # Education
  gross_prim_enrol = "SE.PRM.ENRR",
  gross_sec_enrol  = "SE.SEC.ENRR",
  prim_comp_rate   = "SE.PRM.CMPT.ZS",
  edc_spending     = "SE.XPD.TOTL.GD.ZS",
  adlt_liter       = "SE.ADT.LITR.ZS",
  test_scores      = "HD.HCI.HLOS",         # NEW: harmonized learning outcomes (2010-2020)

  # Health
  life_expect      = "SP.DYN.LE00.IN",
  infant_mort      = "SP.DYN.IMRT.IN",
  under5_mort      = "SH.DYN.MORT",
  health_spend     = "SH.XPD.CHEX.GD.ZS",
  oop_health       = "SH.XPD.OOPC.CH.ZS",   # NEW: out-of-pocket share of health spending
  hiv_prev         = "SH.DYN.AIDS.ZS",      # NEW: HIV prevalence, ages 15-49

  # Fiscal, governance and foreign money
  gov_rev_nogrant  = "GC.REV.XGRT.GD.ZS",
  gov_expense      = "GC.XPN.TOTL.GD.ZS",
  aid_received_gni = "DT.ODA.ODAT.GN.ZS",
  fdi              = "BX.KLT.DINV.WD.GD.ZS",
  resource_rents   = "NY.GDP.TOTL.RT.ZS",   # NEW: natural resource rents (% of GDP)

  # Inequality and poverty
  gini_index       = "SI.POV.GINI",
  pov_headcount    = "SI.POV.DDAY"
)
# Not available from the current World Bank API (tested Nov 2026), so not used:
#   SH.UHC.SRVS.CV.XD (UHC service coverage) -> use V-Dem health equality instead
#   GE.EST (government effectiveness)        -> use V-Dem corruption index instead

for (name in names(indicators)) {
  path <- file.path("data-raw", paste0(name, ".csv"))
  if (file.exists(path) && !refresh) next

  message("Downloading ", name, " (", indicators[[name]], ")")
  data <- WDI(indicator = setNames(indicators[[name]], name), extra = TRUE)
  write.csv(data, path, row.names = FALSE)
}
