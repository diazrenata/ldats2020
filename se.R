library(ggplot2)
library(readr)
all_evals_bbs_rtrg_102_18_cv <- read_csv("all_evals_bbs_rtrg_102_18_cv.csv")
View(all_evals_bbs_rtrg_102_18_cv)
library(ggplot2)
ae <- all_evals_bbs_rtrg_102_18_cv %>% group_by(k, seed, cpts, nit, nfolds) %>% summarize(mean_ll = mean(sum_loglik), se_ll = sd(sum_loglik) / sqrt(nfolds)) %>% ungroup()
ae <- all_evals_bbs_rtrg_102_18_cv %>% group_by(k, seed, cpts, nit, nfolds) %>% summarize(mean_ll = mean(sum_loglik), se_ll = sd(sum_loglik) / sqrt(nfolds)) %>% ungroup() %>% distinct()
ggplot(ae, aes(k, mean_ll, color = seed)) + geom_point() + facet_wrap(vars(cpts))
ae <- ae %>% arrange(desc(mean_ll))
filter(ae, mean_ll >= ae$mean_ll[1] - ae$se_ll[1])
one_se = filter(ae, mean_ll >= ae$mean_ll[1] - ae$se_ll[1])
ggplot(one_se, aes(k, mean_ll, color = as.factor(seed))) + geom_point() + facet_wrap(vars(cpts))

# this is taking the mean and se loglik over the 25 estimates achieved as the mean for each test step. not sure if this converges with sampling to the mean and se if you were to generate many ts's from a SINGLE eta etc for each timestep and then stitch them together and then do this.
# the means converged with about 1000 estimates the more computey way. the current df is using 100.
# but, it does give a sensiscal se and allow you to find the simplest models within 1 se of the best one.


# kkkk now se is many estimates per test step. PLOT TWIST, if there are 0 cpts there is only ONE estimate.

ae <- all_evals_bbs_rtrg_102_18_cv %>%
  group_by(k, seed, cpts, mean_loglik) %>%
  summarize(mean_estimates_loglik = mean(loglik),
            se_estimates_loglik = sd(loglik) / sqrt(dplyr::n()),
            n_estimates_loglik = dplyr::n()) %>%
  ungroup()

ggplot(ae, aes(k, mean_estimates_loglik, color = as.factor(seed))) + geom_point() + facet_wrap(vars(cpts))
ae <- ae %>% arrange(desc(mean_estimates_loglik))
one_se = filter(ae, mean_estimates_loglik >= ae$mean_estimates_loglik[1] - 6 *ae$se_estimates_loglik[1])
ggplot(one_se, aes(k, mean_estimates_loglik, color = as.factor(seed))) + geom_point() + facet_wrap(vars(cpts))

library(MATSS)
library(drake)
library(LDATS)
source(here::here("analysis", "fxns", "crossval_fxns.R"))

## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-cv.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")


h = readd(bbs_rtrg_102_18, cache = cache)
an_lda <- LDA_set_user_seeds(h$abundance, topics = 2, seed = 6)
ts_2 <- TS_on_LDA(an_lda, as.data.frame(h$covariates), formulas =  ~1, nchangepoints = 2, timename = "year", control = TS_control(nit = 1000))

plot(an_lda)
gamma_plot(ts_2[[1]])
rho_plot(ts_2[[1]])

topic1 <-data.frame(
  spec = 1:ncol(an_lda[[1]]@beta),
  prop = exp(an_lda[[1]]@beta[1,]),
  topic =1)

topic2 <- data.frame(
  spec = 1:ncol(an_lda[[1]]@beta),
  prop = exp(an_lda[[1]]@beta[2,]),
  topic = 2)

topics_df <- bind_rows(topic1, topic2)


ggplot(topics_df, aes(as.factor(spec), prop, color = topic)) +
  geom_point()

majspec <- c(30, 42, 57, 92, 19, 84)

propabunds <- h$abundance / rowSums(h$abundance)

maj_abunds <- propabunds[,majspec]

maj_abunds_long <- maj_abunds %>%
  mutate(tstep = dplyr::row_number()) %>%
  tidyr::pivot_longer(-tstep, names_to ="spec", values_to = "abund")
ggplot(maj_abunds_long, aes(tstep, abund, color = as.factor(spec))) +
  geom_line()

abund_probs <- get_abund_probabilities(list(full = h), fitted_lda = an_lda[[1]], fitted_ts = ts_2[[1]], max_sims = 100)


one_prob <- abund_probs[[1]] %>%
  unique()

library(vegan)

bc <- vegdist(one_prob)
bc
