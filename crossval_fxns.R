#' Subset data - all subsets
#'
#' Wrapper for `subset_data_one` to create a list of all data subsets using 1 timestep of test data per subset and a buffer on either side
#'
#' @param full_dataset MATSS-style dataset. A list with elements `$abundance`, `$covariates`
#' @param buffer_size number of timesteps to withold on either side of the test timestep. Defaults 2
#'
#' @return a list of ntimesteps lists, if ntimesteps is the number of timesteps in `full_dataset`. each list in the list is the output of `subset_data_one` with the test timestep as one of the timesteps in the full dataset. 
#' @export
#'
subset_data_all <- function(full_dataset, buffer_size = 2) {
  
  subsetted_data = lapply(1:nrow(full_dataset$abundance), FUN = subset_data_one, full_dataset = full_dataset, buffer_size = buffer_size)
  
}

#' Subset data - one subset
#' 
#' Creates a *single* training/test subset for a dataset. 
#' Witholds a single timestep for testing, and a buffer of timesteps around that timestep.
#'
#' @param full_dataset MATSS style dataset. A list with elements `$abundance`, `$covariates`
#' @param test_timestep Which timestep (row) to withold and use for test
#' @param buffer_size How many rows to withold on either side (not used for test)
#'
#' @return list with elements train (list of $abundance, $covariates), test (list of $abundance, $covariates), full (unaltered full_dataset), test_timestep (which tstep is the test one), buffer_size (buffer size)
#' @export
#'
subset_data_one <- function(full_dataset, test_timestep, buffer_size) {
  
  timesteps_to_withold <- c((test_timestep - 2):(test_timestep + 2))
  timesteps_to_withold <- timesteps_to_withold[ 
    which(timesteps_to_withold %in% 1:nrow(full_dataset$abundance))]
  
  timesteps_to_keep <- 1:nrow(full_dataset$abundance)
  timesteps_to_keep <- timesteps_to_keep[ which(!(timesteps_to_keep %in% timesteps_to_withold  ))]
  
  test_data <- list(
    abundance = full_dataset$abundance[ test_timestep, ],
    covariates = full_dataset$covariates[ test_timestep, ]
  )
  
  train_data <- list(
    abundance = full_dataset$abundance[ timesteps_to_keep, ],
    covariates = full_dataset$covariates[ timesteps_to_keep, ])
  
  subsetted_dataset <- list(
    train = train_data,
    test = test_data,
    full = full_dataset,
    test_timestep = test_timestep,
    buffer_size = buffer_size
  )
  
  return(subsetted_dataset)
  
}

#' Subset an LDA model
#'
#' Takes an LDA model fit to an ENTIRE dataset and strips it down to the rows present in the TRAIN data for a subsetted data item
#'
#' @param fitted_lda lda fit to FULL dataset
#' @param subsetted_dataset_item result of subset_data_one, test and train
#'
#' @return fitted_lda cut and pasted to be just the rows present in the train data
#' @export
#'
subset_lda <- function(fitted_lda, subsetted_dataset_item) {
  
  keep_rows <- subsetted_dataset_item$full$covariates$year %in% subsetted_dataset_item$train$covariates$year
  
  fitted_lda@gamma <- fitted_lda@gamma[ which(keep_rows), ]
  
  fitted_lda@wordassignments <- NULL
  
  fitted_lda@Dim[1] <- sum(keep_rows)
  
  fitted_lda@loglikelihood <- fitted_lda@loglikelihood[ which(keep_rows)]
  
  return(fitted_lda)
}

#' Run LDATs on a single subsetted dataset
#'
#' This is the big wrapper function.
#' 
#' Fits an LDA to a subsetted dataset item.
#' 
#' IF fit_to_train, fits LDA to the train data. IF fit_to_train == FALSE, fits LDA to FULL dataset.
#' 
#' IF fit_to_train == FALSE, then SUBSETS the lda to contain only the gammas (and loglikelihoods) for the timesteps in the TRAIN dataset.
#'
#' Fits a TS model with specified ncpts, nit
#' 
#' Extracts from TS, predicted abundances (as multinom probability distribution) for each species at each timestep. There is a matrix of abundance probabilities *for every draw in the posterior, so nit*
#' 
#' Calculates the *loglikelihood of the test row* given abundance probabiltiies. There is a test loglikelihood for every draw in the posterior, so nit.
#' 
#' 
#'
#' @param subsetted_dataset_item result of subset_data_one
#' @param k ntopics for lda
#' @param seed seed for lda. only use even numbers.
#' @param cpts how many changepoints for ts?
#' @param nit how many iterations? (draws from posterior)
#' @param fit_to_train fit LDA to TRAINING DATA ONLY (default) or set to FALSE to fit to ALL DATA and then subset
#'
#' @return list. subsetted_dataset_item with the following appended. fitted_lda; fitted_ts; abund_probabilities; test_logliks, model_info
#' @export
#'
ldats_subset_one <- function(subsetted_dataset_item, 
                             k,
                             seed,
                             cpts,
                             nit,
                             fit_to_train = TRUE) {
  
  if(fit_to_train) {
    
    fitted_lda <- LDA_set_user_seeds(
      document_term_table = subsetted_dataset_item$train$abundance,
      topics = k,
      seed = seed)[[1]]
    
  }  else {
    
    fitted_lda <- LDA_set_user_seeds(
      document_term_table = subsetted_dataset_item$full$abundance,
      topics = k,
      seed = seed)[[1]]
    
    fitted_lda <- subset_lda(fitted_lda, subsetted_dataset_item)
    
  } 
  
  fitted_ts <- TS_on_LDA(fitted_lda,
                         document_covariate_table = as.data.frame(subsetted_dataset_item$train$covariates),
                         timename = "year",
                         formulas = ~1,
                         nchangepoints = cpts,
                         control = TS_control(nit = nit))[[1]]
  
  abund_probabilities <- get_abund_probabilities(
    subsetted_dataset_item,
    fitted_lda,
    fitted_ts
  )
  
  test_logliks  <- get_test_loglik(
    subsetted_dataset_item,
    abund_probabilities
  )
  
  subsetted_dataset_item$fitted_lda <- fitted_lda
  subsetted_dataset_item$fitted_ts <- fitted_ts
  subsetted_dataset_item$abund_probabilities <- abund_probabilities
  subsetted_dataset_item$test_logliks <- test_logliks
  subsetted_dataset_item$model_info <- list(k = k, seed = seed, cpts = cpts, nit = nit)
  
  return(subsetted_dataset_item)
  
}


#' Get test loglikelihood (all)
#'
#' Wrapper for get_one_test_loglik. Gets loglikelihood estimate for every draw from the posterior.
#'
#' @param subsetted_dataset_item result of subset_data_one
#' @param abund_probabilities list of abund_probabilities; one element for every draw from posterior
#'
#' @return vector of loglikelihood of test data given every abund_probability estimate
#' @export
#'
get_test_loglik <- function(
  subsetted_dataset_item,
  abund_probabilities
) {
  
  test_logliks <- lapply(abund_probabilities, FUN = get_one_test_loglik, subsetted_dataset_item = subsetted_dataset_item)
  
  return(unlist(test_logliks))
  
}


#' Get test row logliklihood (for one draw)
#' 
#' Get loglikelihood of observed abundances for test row given abundance probabilties. For one draw from the posterior
#'
#' @param subsetted_dataset_item result of subset_data_one
#' @param abund_probabilities_one ONE matrix of abundance probabilities
#'
#' @return loglikelihood of obs abundances in test row given abund_probabilities
#' @export
#'
get_one_test_loglik <- function(
  subsetted_dataset_item,
  abund_probabilities_one
) {
  
  test_dat <- subsetted_dataset_item$test$abundance
  
  test_row_number <- subsetted_dataset_item$test_timestep
  
  test_loglik <- dmultinom(x = test_dat, prob = abund_probabilities_one[test_row_number,], log = TRUE)
  
  return(test_loglik)
}

#' Get abundance probabilities
#' 
#' Get probabilities of abundances for each species at each time step as predicted by a TS model. 
#' 
#' Gets one matrix of probabiltiies for each draw from the posterior for estimates of changepoint locations and model parameters (in this case just the intercept)
#'
#' @param subsetted_dataset_item dat
#' @param fitted_lda fitted lda
#' @param fitted_ts fitted ts
#'
#' @return list of abund prob matrices for each draw from posterior
#' @export
#'
get_abund_probabilities <- function(
  subsetted_dataset_item,
  fitted_lda,
  fitted_ts
) {
  
  betas <- exp(fitted_lda@beta)
  
  nsims = nrow(fitted_ts$etas)
  
  thetas <- lapply(1:nsims, FUN = get_one_theta, subsetted_dataset_item = subsetted_dataset_item, fitted_ts = fitted_ts)
  
  abund_probabilities <- lapply(thetas, FUN = function(theta, betas) return(theta %*% betas), betas = betas)
}

#' Get one theta matrix
#' 
#' The theta matrix is the predicted proportions of each LDA topic at each time step. There is one theta matrix for every estimate of Eta (model pars) and rho (changepoint locations). This gets the theta matrix for *one* estimate.
#'
#' @param subsetted_dataset_item dat
#' @param fitted_ts fitted ts to get thetas from
#' @param sim which draw from posterior
#'
#' @return matrix of predicted proportions for each LDA topic at each timestep
#' @export
#'
get_one_theta <- function(subsetted_dataset_item,
                          fitted_ts,
                          sim = 1) {
  covars <- subsetted_dataset_item$full$covariates$year
  
  ncovar <- 1
  
  nseg <- ifelse(is.null(fitted_ts$rhos), 1, ncol(fitted_ts$rhos) + 1)
  
  ntopics <- ncol(fitted_ts$data$gamma)
  
  ndocs <- nrow(subsetted_dataset_item$full$covariates)
  
  time_span <- min(subsetted_dataset_item$full$covariates$year):max(subsetted_dataset_item$full$covariates$year)
  
  time_span_length <- length(time_span)
  
  X <- matrix(nrow = time_span_length, ncol = ncovar, data = time_span, byrow = FALSE)
  
  model_Eta <- fitted_ts$etas[sim, ]
  
  Eta_matrix <- matrix(nrow = ncovar  * nseg, ncol = ntopics,
                       data = c(rep(0, times = ncovar * nseg), model_Eta), byrow = FALSE)
  
  rho = fitted_ts$rhos[sim,]
  
  tD <- unlist(subsetted_dataset_item$full$covariates$year)
  
  Theta <- LDATS::sim_TS_data(X, Eta_matrix, rho, time_span, err = 0)
  
  #Theta <- softmax(Theta)
  
  Theta <- Theta [ which(tD %in% time_span),]
  
  return(Theta)
}

#' Stitch together aggregate loglik over a TS
#' 
#' Given a list of length ntimesteps,
#' 
#' where each element in the list is the vector of length ndraws of test logliklihoods for a model fit to a train/test subset focused on a single timestep,
#' 
#' stitch together a ts of loglikelihoods by randomly drawing one loglikelihood for each time step.
#'
#' @param many_fits list described above
#'
#' @return summed loglik across entire ts
#' @export
#'
compose_ts_loglik <- function(many_fits) {
  
  nsims <- many_fits[[1]]$model_info$nit
  
  ts_logliks <- sum(unlist(lapply(many_fits, FUN = function(fits, nsims) return(fits$test_logliks[ sample.int(n = nsims, size = 1)]), nsims = nsims)))
  
}

#' Repeatedly estimate loglik for a ts fit
#' 
#' Wrapper for compose_ts_loglik to get many estimates fo the loglikelihood for a TS fit.
#' 
#' @param many_fits list, one element per timestep, of loglik estimates for the ts model fit with that timestep as the test timestep
#' @param nests how many estimates to generate 
#'
#' @return vector of nests estimated aggregate logliks
estimate_ts_loglik <- function(many_fits, nests) {
  
  return(list(
    model_info = many_fits[[1]]$model_info,
    loglik_ests = replicate(n = nests, compose_ts_loglik(many_fits), simplify = T)))
}



#' Bundle loglilihood estimates into a df
#'
#' Wrapper for make_ll_df
#' 
#' @param list_of_lls multiple outputs of estimate_ts_loglik
#'
#' @return data frame of loglik, model info
#' @export
#'
bundle_lls <- function(list_of_lls) {
  
  ll_dfs <- lapply(list_of_lls, make_ll_df)
  
  bind_rows(ll_dfs)
}

#' Title
#'
#' @param ll 
#'
#' @return
#' @export
#'
#' @examples
make_ll_df <- function(ll) {
  
  cbind(data.frame(loglik = ll$loglik_ests), as.data.frame(ll$model_info))
  
}

gamma_plot <- function (x, selection = "median", cols = set_gamma_colors(x), 
          xname = NULL, together = FALSE, LDATS = FALSE) 
{
  oldpar <- par(no.readonly = TRUE)
  on.exit(par(oldpar))
  if (LDATS) {
    par(fig = c(0, 1, 0, 0.3), new = TRUE)
  }
  else if (together) {
    par(fig = c(0, 1, 0, 0.52), new = TRUE)
  }
  else {
    par(fig = c(0, 1, 0, 1))
  }
  rhos <- x$rhos
  nrhos <- ncol(rhos)
  if (!is.null(nrhos)) {
    if (selection == "median") {
      spec_rhos <- ceiling(apply(rhos, 2, median))
    }
    else if (selection == "mode") {
      spec_rhos <- apply(rhos, 2, modalvalue)
    }
    else {
      stop("selection input not supported")
    }
  } else {
    spec_rhos <- NULL
  }
  x$control$timename <- NULL
  seg_mods <- multinom_TS(x$data, x$formula, spec_rhos, x$timename, 
                          x$weights, x$control)
  nsegs <- length(seg_mods[[1]])
  t1 <- min(x$data[, x$timename])
  t2 <- max(x$data[, x$timename])
  if (is.null(xname)) {
    xname <- x$timename
  }
  par(mar = c(4, 5, 1, 1))
  plot(1, 1, type = "n", bty = "L", xlab = "", ylab = "", 
       xaxt = "n", yaxt = "n", ylim = c(0, 1), xlim = c(t1 - 
                                                          1, t2 + 1))
  yax <- round(seq(0, 1, length.out = 5), 3)
  axis(2, at = yax, las = 1)
  axis(1)
  mtext(side = 2, line = 3.5, cex = 1.25, "Proportion")
  mtext(side = 1, line = 2.5, cex = 1.25, xname)
  ntopics <- ncol(as.matrix(x$data[[x$control$response]]))
  seg1 <- c(0, spec_rhos[-length(rhos)])
  seg2 <- c(spec_rhos, t2)
  time_obs <- rep(NA, nrow(x$data))
  pred_vals <- matrix(NA, nrow(x$data), ntopics)
  sp1 <- 1
  for (i in 1:nsegs) {
    mod_i <- seg_mods[[1]][[i]]
    spec_vals <- sp1:(sp1 + nrow(mod_i$fitted.values) - 
                        1)
    pred_vals[spec_vals, ] <- mod_i$fitted.values
    time_obs[spec_vals] <- mod_i$timevals
    sp1 <- sp1 + nrow(mod_i$fitted.values)
  }
  for (i in 1:ntopics) {
    points(time_obs, pred_vals[, i], type = "l", lwd = 3, 
           col = cols[i])
  }
  if (!is.null(spec_rhos)) {
    rho_lines(spec_rhos)
  }
}


fit_ldats_crossval <- function(dataset, buffer = 2, k, seed, cpts, nit, fit_to_train = FALSE) {
  
  all_subsets <- subset_data_all(dataset, buffer_size = buffer)
  
  all_ldats_fits <- lapply(all_subsets, FUN = ldats_subset_one, k = k, seed = seed, cpts = cpts, nit = nit, fit_to_train = fit_to_train)
  
  return(all_ldats_fits)
}

eval_ldats_crossval <- function(ldats_fits, nests = 100) {
  estimates <- estimate_ts_loglik(ldats_fits, nests = nests)
  
  ll_df <- make_ll_df(estimates)
  
  return(ll_df)
  
}

plot_lda_comp <- function(fitted_lda) {
 
  lda_betas <- data.frame(t(fitted_lda[[1]]@beta))
  
  colnames(lda_betas) <- c(1:ncol(lda_betas))
  
  lda_betas$species <- (unlist(fitted_lda[[1]]@terms))
  
  lda_betas <- tidyr::pivot_longer(lda_betas, -species, names_to = "topic", values_to = "beta")
  
  lda_betas$beta <- exp(lda_betas$beta)
  
  betas_plot <- ggplot(lda_betas, aes(species, beta, fill = topic)) +
    geom_col(position = "stack") +
    theme_void() +
    scale_fill_viridis_d(end = .7)
}

plot_lda_year <- function(fitted_lda, covariate_data) {
  
  lda_preds <- data.frame(fitted_lda[[1]]@gamma)
  
  colnames(lda_preds) <- c(1:ncol(lda_preds))
  
  stopifnot(nrow(lda_preds) == length(covariate_data))
  
  lda_preds$year <- covariate_data
  
  lda_preds <- tidyr::pivot_longer(lda_preds, -year, names_to = "topic",values_to = "proportion")
  
  
  pred_plot <- ggplot(lda_preds, aes(year, proportion, color = topic)) +
    geom_line(size = 2) +
    theme_bw() +
    scale_color_viridis_d(end = .7)
  
  return(pred_plot)
  }