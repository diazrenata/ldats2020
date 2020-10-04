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

subsetted_lda <- subset_lda(lda_on_full, abund_dat_subset)


test_that("get a theta works on 0 cpt model", {
  
  fitted_ts <- TS_on_LDA(subsetted_lda,
                         document_covariate_table = as.data.frame(abund_dat_subset$train$covariates),
                         timename = "year",
                         formulas = ~1,
                         nchangepoints = 0,
                         control = TS_control(nit = 100))[[1]]
  
  one_theta <- get_one_theta(abund_dat_subset, fitted_ts, sim = 10)
  
  expect_true(nrow(one_theta) == nrow(abund_dat_subset$full$abundance))
  
  expect_true(ncol(one_theta) == subsetted_lda@k)
  
  
  time_span <- min(abund_dat_subset$full$covariates$year):max(abund_dat_subset$full$covariates$year)
  
  time_span_length <- length(time_span)
  
  X <- matrix(nrow = time_span_length, ncol = ncovar, data = time_span, byrow = FALSE)
  
  Eta<- fitted_ts$etas[10, ]
  
  Eta_matrix <- matrix(nrow = 1, ncol = 2,
                       data = c(rep(0, times = ncovar * nseg), model_Eta), byrow = FALSE)
  
  
  rho = NULL
  
  Theta <- LDATS::sim_TS_data(X, Eta_matrix, rho, time_span, err = 0)
  
  Theta <- softmax(Theta)
  
  expect_true(all(one_theta == Theta))
  
})


test_that("get one theta works for model with 2 cpts", {
  
  fitted_ts <- TS_on_LDA(subsetted_lda,
                         document_covariate_table = as.data.frame(abund_dat_subset$train$covariates),
                         timename = "year",
                         formulas = ~1,
                         nchangepoints = 2,
                         control = TS_control(nit = 100))[[1]]
  
  one_theta <- get_one_theta(abund_dat_subset, fitted_ts, sim = 15)

  ncovar <- 1
  
  nseg <- 3
  
  ntopics <- ncol(fitted_ts$data$gamma)
  
  ndocs <- nrow(abund_dat_subset$full$covariates)
  
  time_span <- min(abund_dat_subset$full$covariates$year):max(abund_dat_subset$full$covariates$year)
  
  time_span_length <- length(time_span)
  
  X <- matrix(nrow = time_span_length, ncol = ncovar, data = time_span, byrow = FALSE)
  
  model_Eta <- fitted_ts$etas[15, ]
  
  Eta_matrix <- matrix(nrow = ncovar  * nseg, ncol = ntopics,
                       data = c(rep(0, times = ncovar * nseg), model_Eta), byrow = FALSE)
  
  rho = fitted_ts$rhos[15,]
  
  tD <- unlist(abund_dat_subset$full$covariates$year)
  
  Theta <- LDATS::sim_TS_data(X, Eta_matrix, rho, time_span, err = 0)
  
  Theta <- softmax(Theta)
  
  Theta <- Theta [ which(tD %in% time_span),]
  
  expect_true(all(Theta == one_theta))
  
  
  })
