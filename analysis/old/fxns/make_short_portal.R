library(dplyr)
get_rodents_annual <- function() {

abund <- portalr::abundance(time = "year", level = "Treatment")


abund_annual <- abund %>%
  filter(treatment == "control") %>%
  mutate(year = (substr(censusdate, 0, 4))) %>%
  select(-newmoonnumber, -period, -censusdate, -treatment) %>%
  group_by(year) %>%
  summarize_all(sum) %>%
  ungroup() %>%
  mutate(year = as.numeric(year))

abundance <- select(abund_annual, -year)
covariates <- select(abund_annual, year) %>%
  mutate(col2 = "dummycol")

abund_dat <- list(abundance = abundance,
                 covariates = covariates)

return(abund_dat)

#save(abund_dat, file = "portal_annual.RData")
}

# 
# write.csv(abundance, file = here::here("analysis", "toy_datasets", "rodents_annual.csv"), row.names = F)
# 
# 
# rod <- LDATS::rodents
# 
# write.csv(rod$abundance, file = here::here("analysis", "toy_datasets", "rodents_monthly.csv"), row.names = F)
# write.csv(rod$document_covariate_table, file = here::here("analysis", "toy_datasets", "rodents_monthly_covariates.csv"), row.names = F)
