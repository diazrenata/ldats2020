library(drake)
library(ggplot2)
library(dplyr)
source(here::here("crossval_fxns.R"))
source(here::here("more_fxns.R"))
library(MATSS)
library(LDATS)
load("bbs_1_11.RData")

two_folds <- subset_data_all(bbs_rtrg_1_11, use_folds = T, n_timesteps = 4, n_folds = 2, buffer_size =0)


fitted_lda <- LDATS::LDA_set_user_seeds(bbs_rtrg_1_11$abundance, 5, 4)

plot(fitted_lda)

unfolded_ts <- LDATS::TS_on_LDA(fitted_lda[[1]], as.data.frame(bbs_rtrg_1_11$covariates), ~ 1, c(0:5), timename = "year", control = LDATS::TS_control(nit = 100))

select_TS(unfolded_ts, control = LDATS::TS_control(measurer = AICc))

plot(select_TS(unfolded_ts), selection = "mode")

folded_ldas <- lapply(two_folds, FUN = subset_lda, fitted_lda = fitted_lda[[1]])

# For one fold

ts_on_fold1 <- LDATS::TS_on_LDA(folded_ldas[[1]], as.data.frame(two_folds[[1]]$train$covariates), ~ 1, c(0:5), timename = "year", control = LDATS::TS_control(nit = 100))

ts_on_fold2 <- LDATS::TS_on_LDA(folded_ldas[[2]], as.data.frame(two_folds[[2]]$train$covariates), ~ 1, c(0:5), timename = "year", control = LDATS::TS_control(nit = 100))


plot(folded_ldas[[1]])

plot(select_TS(ts_on_fold1))

plot(folded_ldas[[2]])

plot(select_TS(ts_on_fold2))
