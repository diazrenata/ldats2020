find_holes <- function(bbs_dataset) {
  
  outdat <- data.frame(route = bbs_dataset$metadata$route,
                       region = bbs_dataset$metadata$region,
                       matssname = paste0("bbs_rtrg_", bbs_dataset$metadata$route, "_", bbs_dataset$metadata$region))
  
  years <- bbs_dataset$covariates$year
  
  all_possible_years <- seq(min(years), max(years), by = 1)
  
  if(all(years == all_possible_years)) {
    outdat$complete = T
    outdat$n_missing = 0
    outdat$prop_missing = 0
    outdat$n_possible_years = length(all_possible_years)
    
    return(outdat)
  } else {
    missing_years <- all_possible_years[ which(!(all_possible_years %in% years))]
    
    n_missing_years <- length(missing_years)
    
    prop_missing_years = n_missing_years / length(all_possible_years)
    
    outdat$complete = F
    outdat$n_missing = n_missing_years
    outdat$prop_missing = prop_missing_years
    outdat$n_possible_years = length(all_possible_years)
    
    return(outdat)    
  }
}