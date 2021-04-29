library(dplyr)
library(ggplot2)
library(LDATS)
source(here::here("analysis", "fxns", "crossval_fxns.R"))
source(here::here("analysis", "fxns", "make_short_portal.R"))

p <- get_rodents_annual()

p_lda <- LDA_set_user_seeds(p$abundance, 2, 6)
p_cpt <- TS_on_LDA(p_lda[[1]], as.data.frame(p$covariates), formulas = ~1, nchangepoints = 1, timename = "year", control = TS_control(nit = 1000))

plot(p_lda)
plot(p_cpt[[1]])

p_cpt_abund_p <- get_abund_probabilities(list(full = p), p_lda[[1]], p_cpt[[1]], max_sims = 1)

one_abund_p <- p_cpt_abund_p[[1]] %>%
  unique()

vegan::vegdist(one_abund_p)
