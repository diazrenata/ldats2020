library(dplyr)
library(ggplot2)

all_evals_bbs_rtrg_1_11 <- read.csv("all_evals_bbs_rtrg_1_11_hybrid.csv")

all_evals_bbs_rtrg_1_11 <- all_evals_bbs_rtrg_1_11 %>%
  mutate(k_seed = paste(k,seed, sep = "_"))

ggplot(all_evals_bbs_rtrg_1_11, aes(as.factor(k), sum_loglik, color = as.factor(cpts), group = k_seed)) + geom_boxplot()

all_evals_bbs_rtrg_1_11 <- all_evals_bbs_rtrg_1_11 %>%
  group_by_all() %>%
  mutate(s1 = min(as.numeric(strsplit(test_steps, split = ",")[[1]])),
         s2 =  max(as.numeric(strsplit(test_steps, split = ",")[[1]]))) %>%
  mutate(ordered_steps=  paste(s1, s2, sep = "_")) %>%
  ungroup()

length(unique(all_evals_bbs_rtrg_1_11$ordered_steps))

all_evals_bbs_rtrg_1_11_summary <- all_evals_bbs_rtrg_1_11 %>%
  group_by(k, seed, cpts) %>%
  summarize(mean_sum_ll = mean(sum_loglik)) %>%
  arrange(desc(mean_sum_ll))

head(all_evals_bbs_rtrg_1_11_summary)

View(all_evals_bbs_rtrg_1_11_summary[1:25, ])

ggplot(all_evals_bbs_rtrg_1_11_summary, aes(as.factor(k), mean_sum_ll, color = as.factor(cpts))) +
  geom_point()


ggplot(all_evals_bbs_rtrg_1_11_summary, aes(as.factor(k), mean_sum_ll, color = as.factor(cpts))) +
  geom_point(alpha = .2)




load("bbs_1_11.RData")

library(LDATS)

lda_fit <- LDATS::LDA_set_user_seeds(bbs_rtrg_1_11$abundance, 3, 8)

ts_fit <- LDATS::TS_on_LDA(lda_fit[[1]], as.data.frame(bbs_rtrg_1_11$covariates), ~1, 2, "year", control = TS_control(nit = 100))

plot(lda_fit)
plot(ts_fit[[1]])
