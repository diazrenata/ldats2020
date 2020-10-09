fit_full_lda_ts <- function(dataset, k, seed, cpts, nit) {
  
  fitted_lda <- LDATS::LDA_set_user_seeds(
    document_term_table = dataset$abundance,
    topics = k,
    seed = seed)[[1]]
  
  fitted_ts <- LDATS::TS_on_LDA(fitted_lda,
                         document_covariate_table = as.data.frame(dataset$covariates),
                         timename = "year",
                         formulas = ~1,
                         nchangepoints = cpts,
                         control = TS_control(nit = nit))[[1]]
  ts_aicc <- LDATS::AICc(fitted_ts)
  
  model_info <- data.frame(
    k = k,
    seed = seed,
    ncpts = ncpts,
    nit = nit,
    aicc = ts_aicc
  )
  
  return(list(
    dataset = dataset,
    fitted_lda = fitted_lda,
    fitted_ts = fitted_ts,
    model_info = model_info
  ))
}

extract_model_info <- function(full_fit) {
  return(full_fit$model_info)
}
