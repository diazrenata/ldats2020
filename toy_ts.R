library(LDATS)
load("portal_annual.RData")

lda <- LDATS::LDA_set_user_seeds(abund_dat$abundance, 2, 2)

ts <- TS_on_LDA(lda[[1]], as.data.frame(abund_dat$covariates), formulas = ~1, nchangepoints = 0, timename = "year", control = TS_control(nit = 100))

ts <- ts[[1]]

mn <- nnet::multinom(gamma ~ 1, data = ts$data)

mnn <- LDATS::multinom_TS(ts$data, gamma ~ 1, changepoints = NULL, timename = "year")

ts$logLik
mean(ts$lls)
ts$logLik


AICcS <- function (ts_object) 
{
  lls <- ts_object$lls
  loglik_info <- logLik(ts_object)
  np <- attr(loglik_info, "df")
  no <- attr(loglik_info, "nobs")
  aic <- -2 * lls + 2 * np
  aiccs <- aic + (2 * np^2 + 2 * np)/(no - np - 1)
}

hist(AICcS(ts))
AICc(ts)
mean(AICcS(ts))

ts_info <- data.frame(aiccs = AICcS(ts),
                      aic = AICc(ts))

# AIC and AICc functions for TS objects are using the MEAN LOGLIK ACROSS ALL ITERATIONS

source("crossval_fxns.R")

ldats_fits <- fit_ldats_crossval(abund_dat, k = 2, seed = 2, cpts = 1, nit = 100)
ldats_evals <- eval_ldats_crossval(ldats_fits)

library(ggplot2)

ggplot(ts_info, aes(y = aiccs)) +
  geom_boxplot() +
  geom_hline(yintercept = ts_info$aic)

ggplot(ldats_evals, aes(y = loglik)) +
  geom_boxplot() +
  geom_hline(yintercept = ldats_evals$mean_loglik)


par_ests <- ts$etas

### pulling out test ts probs

one_ts <- ldats_fits[[10]]

ts_pred <- lapply(one_ts$abund_probabilities, FUN = function(some_abund, row_to_pull) return(some_abund[ row_to_pull, ]), row_to_pull = one_ts$test_timestep)

