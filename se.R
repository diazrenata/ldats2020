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