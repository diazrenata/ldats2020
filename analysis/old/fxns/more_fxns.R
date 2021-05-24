get_preds <- function(subsetted_dataset_item, fitted_ts, sim = 1, rho = NULL) { 
  if(is.null(rho)) {
  pred <- get_one_mn_theta(subsetted_dataset_item, fitted_ts, sim = sim) %>%
    as.data.frame() %>%
    mutate(year = subsetted_dataset_item$full$covariates$year) %>%
    tidyr::pivot_longer(-year, names_to = "topic", names_prefix = "V", values_to = "prop") %>%
    mutate(
      estimate = sim)
  } else {
    pred <- mn_from_rho(subsetted_dataset_item, fitted_ts, rho) %>%
      as.data.frame() %>%
      mutate(year = subsetted_dataset_item$full$covariates$year) %>%
      tidyr::pivot_longer(-year, names_to = "topic", names_prefix = "V", values_to = "prop") %>%
      mutate(
        estimate = "rho_supplied")
  }
  return(pred)
}

mn_from_rho <- function(subsetted_dataset_item, ts_model, rho) 
  {
    
    x <- ts_model
    
    seg_mods <- LDATS::multinom_TS(x$data, x$formula, rho, x$timename, 
                                   x$weights, x$control)
    nsegs <- length(seg_mods[[1]])
    
    
    full_timespan <- min(subsetted_dataset_item$full$covariates$year):
      max(subsetted_dataset_item$full$covariates$year)
    
    full_segs <- data.frame(year = full_timespan,
                            segment = NA)
    
    for(i in 1:nsegs) {
      if(nsegs == 1) {
        these_boundaries <- full_timespan
      } else if(i == 1) {
        these_boundaries <- 
          min(full_timespan):
          rho[1]
      } else if (i == nsegs) {
        these_boundaries <- (rho[i - 1]+1):max(full_timespan)
      } else {
        these_boundaries <- (rho[i - 1] + 1):rho[i]
      }
      
      full_segs$segment[ which(full_segs$year %in% these_boundaries)] <- i
    }
    
    segment_estimates <- list()
    fitted_values <- list()
    
    for(i in 1:nsegs) {
      
      this_seg <- seg_mods[[1]][i]
      
      this_fit <- as.data.frame(this_seg[[1]]$fitted.values)
      these_years <- (this_seg[[1]]$timevals)
      
      this_fit <- cbind(this_fit, year = these_years)
      
      fitted_values[[i]] <- this_fit
      
      segment_estimates[[i]] <- this_fit %>%
        dplyr::mutate(segment = i) %>%
        dplyr::select(-year) %>%
        dplyr::distinct()
    }
    
    fitted_values <- dplyr::bind_rows(fitted_values)
    segment_estimates <- dplyr::bind_rows(segment_estimates)
    
    predicted_values <- dplyr::left_join(full_segs, segment_estimates) %>%
      select(-segment)
    
    
    predicted_values <- dplyr::filter(predicted_values, year %in% subsetted_dataset_item$full$covariates$year)
    
    predicted_values <- dplyr::select(predicted_values, -year)
    
    predicted_values <- as.matrix(predicted_values)
    
    predicted_values
}
