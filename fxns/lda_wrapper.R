ldats_wrapper <- function(data_list, seed, ntopics, ncpts, formulas, nit = 100) {
  data_list$covariates <- as.data.frame( data_list$covariates)
  #data_list$covariates[ ,data_list$metadata$timename] <- as.integer(data_list$covariates[ , data_list$metadata$timename])
  
  thislda <- LDATS::LDA_set_user_seeds(data_list$abundance, topics = ntopics, seed = seed)
  
  
  if(formulas == "time") {
    
    thists <-  LDATS::TS_on_LDA(LDA_models = thislda, document_covariate_table = data_list$covariates, nchangepoints = ncpts, formulas = c(~ year), weights =LDATS::document_weights(data_list$abundance), timename = "year", control = list(nit = nit))
    
  } else (
    
    thists <-  LDATS::TS_on_LDA(LDA_models = thislda, document_covariate_table = data_list$covariates, nchangepoints = ncpts, formulas = c(~ 1), weights =LDATS::document_weights(data_list$abundance), timename = "year", control = list(nit = nit, magnitude = 4))
    
  )
  
  test_liks <- try(loo_ll(ts_model = thists[[1]], lda_model = thislda[[1]], data = data_list))
  
  return(list(data = data_list,
              lda = thislda,
              ts = thists,
              ts_lliks = test_liks))
  
}

loo_ll <- function(ts_model, lda_model, data) {
  
  betas <- exp(lda_model@beta)
  
  full_dat <- dplyr::bind_rows(
    cbind(data$abundance, data$covariates),
    cbind(data$test_abundance, data$test_covariates)
  ) 
  
  full_dat <- full_dat %>%
    dplyr::bind_rows(data.frame(year = setdiff(c(min(data$covariates$year):max(data$covariates$year)), full_dat$year))) %>%
    dplyr::arrange(year)
  
  full_abund <- dplyr::select(full_dat, -year)
  full_cov <- dplyr::select(full_dat, year)
    
  
  heldout_rows <- which(full_cov$year %in% data$test_covariates$year)
  
  all_thetas <- lapply(as.list(1:nrow(ts_model$etas)), 
                       FUN = get_loo_theta, ts_model = ts_model,
                       full_cov = full_cov)
  all_thetas <- lapply(all_thetas, 
                       FUN = function(theta_matrix, heldout_data_rows)
                         return(theta_matrix[heldout_data_rows, ]),
                       heldout_data_rows = heldout_rows)
  all_logLik <- vapply(all_thetas, FUN = get_loglik,
                       beta_matrix = betas, counts_matrix = data$test_abundance,
                       FUN.VALUE = 1000)
  return(all_logLik)
  
}


loo_predict <- function(model_list) {
  ts_model <- model_list$ts[[1]]
  
  lda_model <- model_list$lda[[1]]
  
  data <- model_list$data
  
  betas <- exp(lda_model@beta)
  
  full_dat <- dplyr::bind_rows(
    cbind(data$abundance, data$covariates),
    cbind(data$test_abundance, data$test_covariates)
  ) 
  
  full_dat <- full_dat %>%
    dplyr::bind_rows(data.frame(year = setdiff(c(min(data$covariates$year):max(data$covariates$year)), full_dat$year))) %>%
    dplyr::arrange(year)
  
  full_abund <- dplyr::select(full_dat, -year)
  full_cov <- dplyr::select(full_dat, year)
  
  
  heldout_rows <- which(full_cov$year %in% data$test_covariates$year)
  
  sample_size <- sum(data$test_abundance)
  
  all_thetas <- lapply(as.list(1:nrow(ts_model$etas)), 
                       FUN = get_loo_theta, ts_model = ts_model,
                       full_cov = full_cov)
  all_thetas <- lapply(all_thetas, 
                       FUN = function(theta_matrix, heldout_data_rows)
                         return(theta_matrix[heldout_data_rows, ]),
                       heldout_data_rows = heldout_rows)
  all_p_matrices <- lapply(all_thetas, FUN = function(thetam, betam)
    return(thetam %*% betam), betam = betas)
  
  all_preds <- lapply(all_p_matrices, FUN = function(p_matrix, sample_size) 
    return((rmultinom(n = 1, size = sample_size, prob = p_matrix[1,])) / sample_size), sample_size = sample_size)
  
  names(all_preds) <- 1:length(all_preds)
  
  all_preds <- dplyr::bind_rows(all_preds) %>%
    t() %>%
    as.data.frame()
  
  colnames(all_preds) <- colnames(data$test_abundance)
  
  all_preds <- all_preds %>%
    dplyr::mutate(draw = row_number(),
                  logliks = loo_ll(ts_model, lda_model, data)) %>% 
    tidyr::gather(-draw, -logliks, key = "species", value = "abundance")
  
  
  return(all_preds)
  
}

get_loo_theta <- function(ts_model, full_cov, sim = 1){
  
  covars <- get_relevant_covars(full_cov, ts_model$formula)
  
  ncovar <- ncol(covars)
  nseg <- ifelse(is.null(ts_model$rhos), 1, ncol(ts_model$rhos) + 1)
  ntopics <- ncol(ts_model$data$gamma)
  
  ndocs <- nrow(full_cov)
  
  X <- matrix(nrow = ndocs, ncol = ncovar, data = unlist(covars), byrow = FALSE)
  
  model_Eta <- ts_model$etas[sim, ]
  
  Eta_matrix <- matrix(nrow = ncovar  * nseg, ncol = ntopics,
                       data = c(rep(0, times = ncovar * nseg), model_Eta), byrow = FALSE)
  
  rho = ts_model$rhos[sim,]
  
  tD <- unlist(full_cov[ , ts_model$timename])
  
  Theta <- LDATS::sim_TS_data(X, Eta_matrix, rho, tD, err = 0)
  
  return(Theta) 
}

get_year_ll <- function(ts_result) {
  
  modelinfo <- strsplit(names(ts_result$ts), ", ")[[1]]
  
  k <- as.integer(substr(modelinfo[[1]], 3, nchar(modelinfo[[1]])))
  
  seed <- as.integer(substr(modelinfo[[2]], 6, nchar(modelinfo[[2]])))
  
  form <- modelinfo[[3]]
  
  nchange <- as.integer(strsplit(modelinfo[[4]], " c")[[1]][[1]])
  
  return(data.frame(lglik = ts_result$ts_lliks,
                    test_year = rep(ts_result$data$test_covariates$year[1]),
                    draw = 1:length(ts_result$ts_lliks),
                    k = rep(k),
                    seed = rep(seed),
                    form = rep(form),
                    ncpt = rep(nchange)))
}

combine_year_lls <- function(list_of_ll_dfs) {

  ndraws <- nrow(list_of_ll_dfs[[1]])
  
  big_ll_df <- dplyr::bind_rows(list_of_ll_dfs) %>%
    dplyr::group_by(test_year, k, seed, form, ncpt) %>%
    dplyr::mutate(draw = sample.int(n = ndraws, size = ndraws, replace = F)) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(draw, k, seed, form, ncpt) %>%
    dplyr::summarize(sum_ll = sum(lglik)) %>%
    dplyr::ungroup()
  
  return(big_ll_df)

}
