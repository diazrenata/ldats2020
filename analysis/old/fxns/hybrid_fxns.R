
fit_ldats_hybrid <- function(dataset, k, cpts, seed, nit, use_folds, n_folds, n_timesteps, buffer, fold_seed = 1977) {
  
  fitted_lda <- LDATS::LDA_set_user_seeds(dataset$abundance, topics = k, seed = seed)
  
  fitted_tss <- LDATS::TS_on_LDA(fitted_lda[[1]], as.data.frame(dataset$covariates), ~1, cpts,"year", control = TS_control(nit = nit))
  
  selected_ts <- LDATS::select_TS(fitted_tss)
  
  selected_ncp <- selected_ts$nchangepoints
  
  crossval_fit <- fit_ldats_crossval(dataset, use_folds = use_folds, seed = seed, k = k, cpts = selected_ncp, nit = nit, n_folds = n_folds, n_timesteps = n_timesteps, buffer = buffer, fold_seed = fold_seed, fit_to_train = F)
  
  return(crossval_fit)
  
}