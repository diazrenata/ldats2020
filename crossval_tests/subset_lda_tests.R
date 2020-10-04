library(testthat)

source("crossval_fxns.R")

# Load a known dataset

load("portal_annual.RData")

# Create a data subset

abund_dat_subset <- subset_data_one(abund_dat, 5, 2)

# Fit an LDA

library(LDATS)

lda_on_full <- LDA_set_user_seeds(
  document_term_table = abund_dat_subset$full$abundance,
  topics = 2,
  seed = 2)[[1]]

test_that("lda subset works", {
  
  subsetted_lda <- subset_lda(lda_on_full, abund_dat_subset)
  
  train_years <- abund_dat_subset$train$covariates$year

  train_row_indices <- which(abund_dat_subset$full$covariates$year %in% train_years)
  
  all_gammas <- lda_on_full@gamma
  
  train_gammas <- all_gammas[ train_row_indices, ]
  train_loglik <- lda_on_full@logLiks[ train_row_indices]
  
  
  expect_true(all(subsetted_lda@gamma == train_gammas))
  expect_true(all(subsetted_lda@logLiks == train_loglik))
  
  expect_true(subsetted_lda@Dim[1] == length(train_years))
  
  })


# Fit a TS

fitted_ts <- TS_on_LDA(subsetted_lda,
                       document_covariate_table = as.data.frame(abund_dat_subset$train$covariates),
                       timename = "year",
                       formulas = ~1,
                       nchangepoints = 0,
                       control = TS_control(nit = 100))[[1]]

test_that("ts was fit to subsetted data", {
  
  expect_true(all(fitted_ts$data$year == abund_dat_subset$train$covariates$year))
  
  expect_true(all(fitted_ts$data[,3:ncol(fitted_ts$data)] ==
                    subsetted_lda@gamma))
  
})