abund <- portalr::abundance(time = "year")

library(dplyr)

abund_annual <- abund %>%
  mutate(year = (substr(censusdate, 0, 4))) %>%
  select(-newmoonnumber, -period, -censusdate) %>%
  group_by(year) %>%
  summarize_all(sum) %>%
  ungroup() %>%
  mutate(year = as.numeric(year))

abundance <- select(abund_annual, -year)
covariates <- select(abund_annual, year) %>%
  mutate(col2 = "dummycol")

abund_dat <- list(abundance = abundance,
                  covariates = covariates)

save(abund_dat, file = "portal_annual.RData")
