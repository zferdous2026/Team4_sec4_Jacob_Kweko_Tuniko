# 01_download_wdi.R
# Purpose: Download World Bank WDI indicators and save each as a raw CSV
# Output:  data-raw/<indicator>.csv (one file per indicator)
# Run from the project root. Re-run to refresh the data.

# Install and call WDI package
if (!requireNamespace("WDI", quietly = TRUE)) install.packages("WDI")
library("WDI")


# Pull datasets

# Contols and scaling

gdp_per_capita <- WDI(extra = TRUE, indicator = c(gdp_per_capita = "NY.GDP.PCAP.KD"))
total_pop      <- WDI(extra = TRUE, indicator = c(total_pop      = "SP.POP.TOTL"))
gdp_growth     <- WDI(extra = TRUE, indicator = c(gdp_growth     = "NY.GDP.MKTP.KD.ZG"))
tax_revenue    <- WDI(extra = TRUE, indicator = c(tax_revenue    = "GC.TAX.TOTL.GD.ZS"))
urban_pop      <- WDI(extra = TRUE, indicator = c(urban_pop      = "SP.URB.TOTL.IN.ZS"))

# Education

gross_prim_enrol <- WDI(extra = TRUE, indicator = c(gross_prim_enrol = "SE.PRM.ENRR"))
gross_sec_enrol  <- WDI(extra = TRUE, indicator = c(gross_sec_enrol  = "SE.SEC.ENRR"))
prim_comp_rate   <- WDI(extra = TRUE, indicator = c(prim_comp_rate   = "SE.PRM.CMPT.ZS"))
edc_spending     <- WDI(extra = TRUE, indicator = c(edc_spending     = "SE.XPD.TOTL.GD.ZS"))
adlt_liter       <- WDI(extra = TRUE, indicator = c(adlt_liter       = "SE.ADT.LITR.ZS"))

# Health

life_expect  <- WDI(extra = TRUE, indicator = c(life_expect  = "SP.DYN.LE00.IN"))
infant_mort  <- WDI(extra = TRUE, indicator = c(infant_mort  = "SP.DYN.IMRT.IN"))
under5_mort  <- WDI(extra = TRUE, indicator = c(under5_mort  = "SH.DYN.MORT"))
health_spend <- WDI(extra = TRUE, indicator = c(health_spend ="SH.XPD.CHEX.GD.ZS"))

# Fiscal and governance

gov_rev_nogrant  <- WDI(extra = TRUE, indicator = c(gov_rev_nogrant  = "GC.REV.XGRT.GD.ZS"))
gov_expense      <- WDI(extra = TRUE, indicator = c(gov_expense      = "GC.XPN.TOTL.GD.ZS"))
aid_received_gni <- WDI(extra = TRUE, indicator = c(aid_received_gni = "DT.ODA.ODAT.GN.ZS"))
fdi              <- WDI(extra = TRUE, indicator = c(fdi              = "BX.KLT.DINV.WD.GD.ZS"))


# Inequality and poverty

gini_index    <- WDI(extra = TRUE, indicator = c(gini_index    = "SI.POV.GINI"))
pov_headcount <- WDI(extra = TRUE, indicator = c(pov_headcount = "SI.POV.DDAY"))




# Write raw data into csv files (one file per dataset, named after the object)
datasets <- c(
  # Controls and scaling
  "gdp_per_capita", "total_pop", "gdp_growth", "tax_revenue", "urban_pop",
  # Education
  "gross_prim_enrol", "gross_sec_enrol", "prim_comp_rate", "edc_spending", "adlt_liter",
  # Health
  "life_expect", "infant_mort", "under5_mort", "health_spend",
  # Fiscal and governance
  "gov_rev_nogrant", "gov_expense", "aid_received_gni", "fdi",
  # Inequality and poverty
  "gini_index", "pov_headcount"
)

for (d in datasets) {
  write.csv(get(d), file.path("data-raw", paste0(d, ".csv")), row.names = FALSE)
}

```{r}
library(WDI)
library(tidyverse)

# Download Gini coefficient data from World Bank
gini_data <- WDI(
  country = "all",
  indicator = "SI.POV.GINI",
  start = 2010,
  end = 2024
)

# Save dataset as CSV
write_csv(gini_data, "gini_world_data.csv")

# Check the data
head(gini_data)
dim(gini_data)
```





