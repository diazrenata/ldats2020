abund <- portalr::abundance(time = "year")

library(dplyr)

abund_annual <- abund %>%
  mutate(year = (substr(censusdate, 0, 4))) %>%
  select(-newmoonnumber, -period, -censusdate) %>%
  group_by(year) %>%
  summarize_all(sum) %>%
  ungroup() %>%
  mutate(year = as.numeric(year))

abund_dat <- list(abundance = select(abund_annual, -year),
                  covariates = as.data.frame(select(abund_annual, year)))

save(abund_dat, file = "portal_annual.RData")
