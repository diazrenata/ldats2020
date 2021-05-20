library(ggplot2)
library(readr)
library(dplyr)
library(cvlt)

#### change vals here #### 

this_season <- "summer"
this_trt <- "CC"

all_evals <- read_csv(paste0("all_evals_f_hasty_soar_plants_", this_season, "_", this_trt, "_cv.csv"))

#library(ggplot2)
ae <- all_evals %>% group_by(k, seed, cpts, nit, nfolds) %>% summarize(mean_ll = mean(sum_loglik), se_ll = sd(sum_loglik) / sqrt(nfolds)) %>% ungroup() %>% distinct() %>%
  mutate(seed = as.factor(seed))

best_se <- filter(ae, mean_ll == max(ae$mean_ll))

ae <- ae %>%
  group_by_all() %>%
  mutate(good_se = mean_ll >= best_se$mean_ll[1] - best_se$se_ll[1])

ggplot(ae, aes(k, mean_ll, color = good_se)) + geom_point() + facet_wrap(vars(cpts)) + theme(legend.position = "none")

ggplot(filter(ae, good_se), aes(k, mean_ll, color = seed)) + geom_point() + facet_wrap(vars(cpts)) + theme(legend.position = "none")

good_se_configs <- filter(ae, good_se)

good_se_configs <- good_se_configs %>%
  filter(cpts == min(good_se_configs$cpts))

good_se_configs <- good_se_configs %>%
  filter(k == min(good_se_configs$k))

good_se_configs <- good_se_configs %>%
  filter(mean_ll == max(good_se_configs$mean_ll))

library(MATSS)
library(drake)
library(LDATS)
library(cvlt)
source(here::here("analysis", "fxns", "crossval_fxns.R"))


h = soar::get_plants_annual_ldats(this_season, this_trt)

an_lda <- cvlt::LDA_set_user_seeds(h$abundance, topics = good_se_configs$k[1], seed = as.numeric(good_se_configs$seed[1]))
ts_2 <- TS_on_LDA(an_lda, as.data.frame(h$covariates), formulas =  ~1, nchangepoints = good_se_configs$cpts[1], timename = "year", control = TS_control(nit = 100))


plot(an_lda)
plot_lda_year(an_lda, covariate_data = h$covariates$year)
gamma_plot(ts_2[[1]])
rho_plot(ts_2[[1]])

abund_probs <- get_abund_probabilities(list(full = h), fitted_lda = an_lda[[1]], fitted_ts = ts_2[[1]], max_sims = 100)


one_prob <- abund_probs[[1]] %>%
  unique()

library(vegan)

bc <- vegdist(one_prob)
bc
