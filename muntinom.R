load("portal_annual.RData")
source("crossval_fxns.R")
library(LDATS)

dataset <- abund_dat

one_subset <- subset_data_one(abund_dat, 10,buffer_size = 2)


fitted_lda <- LDATS::LDA_set_user_seeds(
  document_term_table = one_subset$full$abundance,
  topics = 2,
  seed = 2)[[1]]

fitted_lda <- subset_lda(fitted_lda, one_subset)
fitted_ts <- LDATS::TS_on_LDA(fitted_lda,
                       document_covariate_table = as.data.frame(one_subset$train$covariates),
                       timename = "year",
                       formulas = ~1,
                       nchangepoints = 1,
                       control = LDATS::TS_control(nit = 100))[[1]]
abund_probabilities <- get_abund_probabilities(
  one_subset,
  fitted_lda,
  fitted_ts
)


test_logliks  <- get_test_loglik(
  one_subset,
  abund_probabilities
)
