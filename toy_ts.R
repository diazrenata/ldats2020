library(LDATS)
load("portal_annual.RData")

lda <- LDATS::LDA_set_user_seeds(abund_dat$abundance, 2, 2)

ts <- TS_on_LDA(lda[[1]], as.data.frame(abund_dat$covariates), formulas = ~1, nchangepoints = 1, timename = "year", control = TS_control(nit = 100))

ts <- ts[[1]]

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

# AIC and AICc functions for TS objects are using the MEAN LOGLIK ACROSS ALL ITERATIONS