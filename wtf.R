library(LDATS)
load("portal_annual.RData")
source("crossval_fxns.R")
#ldats_fits <- fit_ldats_crossval(abund_dat, k = 3, seed = 2, cpts = 1, nit = 100)

#save(ldats_fits, file = "wtf_fits.RData")
load("wtf_fits.RData")

one_fit <- ldats_fits[[10]]

library(ggplot2)
library(dplyr)
one_fit$fitted_ts
rho_df <- data.frame(rhos = one_fit$fitted_ts$rhos, it = 1:length(one_fit$fitted_ts$rhos), lls = one_fit$fitted_ts$lls)
                     
ggplot(rho_df, aes(it, rhos)) +
  geom_point()

ggplot(rho_df, aes(rhos, lls)) +
  geom_point(alpha = .1)

eta_df <- data.frame(one_fit$fitted_ts$etas) %>%
  mutate(it = 1:nrow(rho_df))
ggplot(eta_df, aes(it, X1_2..Intercept.)) +
  geom_point() +
  geom_point(aes(it, X2_2..Intercept.), color = "blue")

ggplot(eta_df, aes(it, X1_3..Intercept.)) +
  geom_point() +
  geom_point(aes(it, X2_3..Intercept.), color = "blue")

theta1 <- get_one_theta(one_fit, one_fit$fitted_ts, 100)
theta2 <- get_one_theta(one_fit, one_fit$fitted_ts, 1)
