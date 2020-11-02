library(testthat)

source("crossval_fxns.R")

library(LDATS)

# Load a known dataset

load("portal_annual.RData")
all_subsets <- subset_data_all(abund_dat)

test_that("wrapper works on one", {
 
  abund_dat_subset <- all_subsets[[1]] 
  

  one_mod <- ldats_subset_one(abund_dat_subset, 2, 2, 0, 100,fit_to_train = F)
  
  expect_true(length(one_mod) == 10)
  
  
  lda_on_full <- LDA_set_user_seeds(
    document_term_table = abund_dat_subset$full$abundance,
    topics = 2,
    seed = 2)[[1]]
  
  subsetted_lda <- subset_lda(lda_on_full, abund_dat_subset)
  
  fitted_ts <- TS_on_LDA(subsetted_lda,
                         document_covariate_table = as.data.frame(abund_dat_subset$train$covariates),
                         timename = "year",
                         formulas = ~1,
                         nchangepoints = 0,
                         control = TS_control(nit = 100))[[1]]
  
  expect_true(all(subsetted_lda@beta == one_mod$fitted_lda@beta))
  
  }

)

test_that("ldats wrapper works", {
  
  all_mods <- lapply(all_subsets, FUN = ldats_subset_one, k = 2, seed = 2, cpt = 0, nit = 100, fit_to_train = F)
  
})

