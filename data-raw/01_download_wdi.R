# 01_download_wdi.R
# Purpose: Download World Bank WDI indicators and save each as a raw CSV
# Output:  data-raw/<indicator>.csv (one file per indicator)
# Run from the project root. Re-run to refresh the data.

# Install and call WDI package
install.packages("WDI")
library("WDI")


# Pull datasets
fdi          <- WDI(indicator = c(fdi          = "BM.KLT.DINV.CD.WD"))
life_expect  <- WDI(indicator = c(life_expect  = "SP.DYN.LE00.IN"))
adlt_liter   <- WDI(indicator = c(adlt_liter   = "SE.ADT.LITR.ZS"))
edc_spending <- WDI(indicator = c(edc_spending = "SE.XPD.TOTL.GD.ZS"))
tax_revenue  <- WDI(indicator = c(tax_revenue  = "GC.TAX.TOTL.GD.ZS"))

# Write raw data into csv files
write.csv(fdi,          "data-raw/fdi.csv",          row.names = FALSE)
write.csv(life_expect,  "data-raw/life_expect.csv",  row.names = FALSE)
write.csv(adlt_liter,   "data-raw/adlt_liter.csv",   row.names = FALSE)
write.csv(edc_spending, "data-raw/edc_spending.csv", row.names = FALSE)
write.csv(tax_revenue,  "data-raw/tax_revenue.csv",  row.names = FALSE)