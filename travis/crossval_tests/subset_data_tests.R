library(testthat)

source("crossval_fxns.R")

# Load a known dataset

load("portal_annual.RData")

test_that("portal dat is correct", {
  
  expect_true(!is.null(abund_dat$abundance))
  expect_true(!is.null(abund_dat$covariates))
  
  expect_true(is.data.frame(abund_dat$abundance))
  expect_true(nrow(abund_dat$abundance) == 39)
  
  expect_true(ncol(abund_dat$abundance) == 21)
  
  
  expect_type((abund_dat$covariates$year), "double")
  
  expect_true(min(abund_dat$covariates$year) == 1979)
  expect_true(length(abund_dat$covariates$year) == nrow(abund_dat$abundance))
  
  expect_true(max(abund_dat$covariates$year) == 2018)
  
})

test_that("subset one works", {
  
  y1_subset <- subset_data_one(abund_dat, 1, 2)
  
  expect_true(length(y1_subset) == 5)
  
  expect_true(nrow(y1_subset$train$abundance) == 
                nrow(y1_subset$train$covariates))
  
  expect_true(nrow(y1_subset$train$abundance) == 
                (nrow(y1_subset$full$abundance) - 3))
  
  expect_true(all(y1_subset$test$abundance[1, ] == y1_subset$full$abundance[1, ]))
  
  expect_true(all(y1_subset$train$abundance == y1_subset$full$abundance[4:39, ]))
  
  expect_true(all(y1_subset$test$covariates[1] == y1_subset$full$covariates$year[1]))
  
  expect_true(all(y1_subset$train$covariates == y1_subset$full$covariates[4:39, ]))
  
  y5_subset <- subset_data_one(abund_dat, 5, 2)
  
  expect_true(length(y5_subset) == 5)
  
  expect_true(nrow(y5_subset$train$abundance) == 
                nrow(y5_subset$train$covariates))
  
  expect_true(nrow(y5_subset$train$abundance) == 
                (nrow(y5_subset$full$abundance) - 5))
  
  expect_true(all(y5_subset$test$abundance[1, ] == y5_subset$full$abundance[5, ]))
  
  expect_true(all(y5_subset$train$abundance == y5_subset$full$abundance[c(1:2, 8:39), ]))
  
  expect_true(all(y5_subset$test$covariates[1] == y5_subset$full$covariates$year[5]))
  
  expect_true(all(y5_subset$train$covariates == y5_subset$full$covariates[c(1:2, 8:39), ]))
  
  
})

test_that("subset all works", {
  
  all_subset <- subset_data_all(abund_dat, 2)
  
  
  for(i in 1:length(all_subset)) {
    
    this_subset <- all_subset[[i]]
    
    full_length <- nrow(this_subset$full$abundance)
    
    expect_true(length(this_subset) == 5)
    
    expect_true(nrow(this_subset$train$abundance) == 
                  nrow(this_subset$train$covariates))
    
    should_be_dropped <- c((i - 2):(i+2))
    
    should_be_dropped <- should_be_dropped[ which(should_be_dropped %in% c(1:full_length))]
    
    should_be_kept <- c(1:full_length)[ which(!(c(1:full_length) %in% should_be_dropped))]
    
    expect_true(nrow(this_subset$train$abundance) == 
                  (nrow(this_subset$full$abundance) - length(should_be_dropped)))
    
    expect_true(all(this_subset$test$abundance[1, ] == this_subset$full$abundance[i, ]))
    
    expect_true(all(this_subset$train$abundance == this_subset$full$abundance[should_be_kept, ]))
    
    expect_true(all(this_subset$test$covariates[1] == this_subset$full$covariates$year[i]))
    
    expect_true(all(this_subset$train$covariates == this_subset$full$covariates[should_be_kept,]))
    
  }
})


