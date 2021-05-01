library(ggplot2)
library(readr)
library(dplyr)
all_evals_portal_annual_cv <- read_csv("all_evals_portal_annual_cv.csv")
#View(all_evals_portal_annual_cv)
#library(ggplot2)
ae <- all_evals_portal_annual_cv %>% group_by(k, seed, cpts, nit, nfolds) %>% summarize(mean_ll = mean(sum_loglik), se_ll = sd(sum_loglik) / sqrt(nfolds)) %>% ungroup() %>% distinct() %>%
  mutate(seed = as.factor(seed))

best_se <- filter(ae, mean_ll == max(ae$mean_ll))

ae <- ae %>%
  group_by_all() %>%
  mutate(good_se = mean_ll >= best_se$mean_ll[1] - best_se$se_ll[1])

ggplot(ae, aes(k, mean_ll, color = good_se)) + geom_point() + facet_wrap(vars(cpts)) + theme(legend.position = "none")

ggplot(filter(ae, good_se), aes(k, mean_ll, color = seed)) + geom_point() + facet_wrap(vars(cpts)) + theme(legend.position = "none")

good_se_configs <- filter(ae, good_se) %>%
  arrange(desc(mean_ll))

ggplot(good_se_configs, aes(k, cpts)) +
  geom_point()

best_se_config <- filter(good_se_configs, cpts == min(good_se_configs$cpts))

best_se_config <- filter(best_se_config, k == min(best_se_config$k)) 

best_se_config <- filter(best_se_config, mean_ll== max(best_se_config$mean_ll))

best_se_config

h <- get_rodents_annual()

an_lda <- cvlt::LDA_set_user_seeds(h$abundance, topics = 2, seed = 4)
ts_2 <- TS_on_LDA(an_lda, as.data.frame(h$covariates), formulas =  ~1, nchangepoints = 1, timename = "year", control = TS_control(nit = 100))


plot_lda_year(an_lda[[1]], covariate_data = portal_annual$covariates$year)
gamma_plot(ts_2[[1]])
rho_plot(ts_2[[1]]) + xlim(min(portal_annual$covariates$year), max(portal_annual$covariates$year))

abund_probs <- get_abund_probabilities(list(full = h), fitted_lda = an_lda[[1]], fitted_ts = ts_2[[1]], max_sims = 100)


one_prob <- abund_probs[[1]] %>%
  unique()

library(vegan)

bc <- vegdist(one_prob)
bc
