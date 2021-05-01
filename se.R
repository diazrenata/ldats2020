library(ggplot2)
library(readr)
library(dplyr)
all_evals_bbs_rtrg_102_18_cv <- read_csv("all_evals_bbs_rtrg_102_18_cv.csv")
#View(all_evals_bbs_rtrg_102_18_cv)
#library(ggplot2)
ae <- all_evals_bbs_rtrg_102_18_cv %>% group_by(k, seed, cpts, nit, nfolds) %>% summarize(mean_ll = mean(sum_loglik), se_ll = sd(sum_loglik) / sqrt(nfolds)) %>% ungroup() %>% distinct() %>%
  mutate(seed = as.factor(seed))

best_se <- filter(ae, mean_ll == max(ae$mean_ll))

ae <- ae %>%
  group_by_all() %>%
  mutate(good_se = mean_ll >= best_se$mean_ll[1] - best_se$se_ll[1])

ggplot(ae, aes(k, mean_ll, color = good_se)) + geom_point() + facet_wrap(vars(cpts)) + theme(legend.position = "none")

ggplot(filter(ae, good_se), aes(k, mean_ll, color = seed)) + geom_point() + facet_wrap(vars(cpts)) + theme(legend.position = "none")

good_se_configs <- filter(ae, good_se) %>%
  filter(k == 2,
         cpts == 3) %>%
  arrange(desc(mean_ll))

library(MATSS)
library(drake)
library(LDATS)
library(cvlt)
source(here::here("analysis", "fxns", "crossval_fxns.R"))

## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-cv.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")


h = readd(bbs_rtrg_102_18, cache = cache)

h <- MATSS::get_bbs_route_region_data(route = 102, region = 18)
an_lda <- cvlt::LDA_set_user_seeds(h$abundance, topics = 2, seed = 6)
ts_2 <- TS_on_LDA(an_lda, as.data.frame(h$covariates), formulas =  ~1, nchangepoints = 3, timename = "year", control = TS_control(nit = 100))


plot(an_lda)
gamma_plot(ts_2[[1]])
rho_plot(ts_2[[1]])

abund_probs <- get_abund_probabilities(list(full = h), fitted_lda = an_lda[[1]], fitted_ts = ts_2[[1]], max_sims = 100)


one_prob <- abund_probs[[1]] %>%
  unique()

library(vegan)

bc <- vegdist(one_prob)
bc
