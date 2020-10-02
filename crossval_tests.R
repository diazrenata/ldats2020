library(testthat)

source("crossval_fxns.R")

# Load a known dataset

load("portal_annual.RData")

test_that("portal dat is correct", {
  
  expect_true(!is.null(abund_dat$abundance))
  expect_true(!is.null(abund_dat$covariates))
  
  expect_true(is.data.frame(abund_dat$abundance))
  expect_true(nrow(abund_dat$abundance) == 40)
  expect_true(ncol(abund_dat$abundance) == 21)
  
  
  expect_type((abund_dat$covariates$year), "double")

  expect_true(min(abund_dat$covariates$year) == 1979)
  expect_true(length(abund_dat$covariates$year) == nrow(abund_dat$abundance))
  
  expect_true(max(abund_dat$covariates$year) == 2018)
  
  })