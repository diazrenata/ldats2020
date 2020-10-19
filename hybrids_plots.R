library(dplyr)
library(ggplot2)

all_evals_bbs_rtrg_1_11 <- read.csv("all_evals_bbs_rtrg_1_11_hybrid.csv")

all_evals_bbs_rtrg_1_11 <- all_evals_bbs_rtrg_1_11 %>%
  mutate(k_seed = paste(k,seed, sep = "_"))

ggplot(all_evals_bbs_rtrg_1_11, aes(as.factor(k), sum_loglik, color = as.factor(cpts), group = k_seed)) + geom_boxplot()
