
subset_data_all <- function(full_dataset, buffer_size = 2) {
  
  subsetted_data = lapply(1:nrow(full_dataset$abundance), FUN = subset_data_one, full_dataset = full_dataset, buffer_size = buffer_size)
  
}

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
    
    keep_rows <- subsetted_dataset_item$full$covariates$year %in% subsetted_dataset_item$train$covariates$year
    
    fitted_lda@gamma <- fitted_lda@gamma[ which(keep_rows), ]
    
    fitted_lda@wordassignments <- NULL
    
    fitted_lda@Dim[1] <- sum(keep_rows)
    
    fitted_lda@loglikelihood <- fitted_lda@loglikelihood[ which(keep_rows)]
    
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


get_test_loglik <- function(
  subsetted_dataset_item,
  abund_probabilities
) {
  
  test_logliks <- lapply(abund_probabilities, FUN = get_one_test_loglik, subsetted_dataset_item = subsetted_dataset_item)
  
  return(unlist(test_logliks))
  
}


get_one_test_loglik <- function(
  subsetted_dataset_item,
  abund_probabilities_one
) {
  
  test_dat <- subsetted_dataset_item$test$abundance
  
  test_row_number <- subsetted_dataset_item$test_timestep
  
  test_loglik <- dmultinom(x = test_dat, prob = abund_probabilities_one[test_row_number,], log = TRUE)
  
  return(test_loglik)
}

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
  
  Theta <- softmax(Theta)
  
  Theta <- Theta [ which(tD %in% time_span),]
  
  return(Theta)
}

compose_ts_loglik <- function(many_fits) {
  
  nsims <- many_fits[[1]]$model_info$nit
  
  ts_logliks <- sum(unlist(lapply(many_fits, FUN = function(fits, nsims) return(fits$test_logliks[ sample.int(n = nsims, size = 1)]), nsims = nsims)))
  
}

estimate_ts_loglik <- function(many_fits, nests) {
  
  return(list(
    model_info = many_fits[[1]]$model_info,
    loglik_ests = replicate(n = nests, compose_ts_loglik(many_fits), simplify = T)))
}



bundle_lls <- function(list_of_lls) {
  
  ll_dfs <- lapply(list_of_lls, make_ll_df)
  
  bind_rows(ll_dfs)
}

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
      spec_rhos <- apply(rhos, 2, median)
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

