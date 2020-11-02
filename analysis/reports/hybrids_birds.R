library(dplyr)
library(ggplot2)

library(LDATS)
source(here::here("crossval_fxns.R"))
source(here::here("hybrid_fxns.R"))

#### 105_4: a clear winner ####

head(filter(all_evals_summary, dataset == "all_evals_bbs_rtrg_105_4"))

# the winner for this dataset is 3 topics, seed = 12, 1 cpt.

long_105_4 <- bbs_rtrg_105_4$abundance %>%
  mutate(year = bbs_rtrg_105_4$covariates$year) %>%
  tidyr::pivot_longer(-year, names_to = "species", values_to  = "abundance")

ggplot(long_105_4, aes(year, abundance, color = species)) +
  geom_line() +
  theme(legend.position = "none") +
  scale_color_viridis_d()

lda_105_4 <- LDATS::LDA_set_user_seeds(bbs_rtrg_105_4$abundance, topics = 3, seed = 12)

plot_lda_comp(lda_105_4)
plot_lda_year(lda_105_4, bbs_rtrg_105_4$covariates$year)

ts_105_4 <- LDATS::TS_on_LDA(lda_105_4, as.data.frame(bbs_rtrg_105_4$covariates), formulas = ~1, nchangepoints = 1, timename = "year", control = LDATS::TS_control(nit = 100))

gamma_plot(ts_105_4[[1]])
