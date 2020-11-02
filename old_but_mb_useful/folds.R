library(drake)
library(ggplot2)
library(dplyr)
source(here::here("crossval_fxns.R"))
source(here::here("more_fxns.R"))
library(MATSS)

#load("bbs_1_11.RData")
# subsetted <- subset_data_all(bbs_rtrg_1_11, use_folds = T)
# 
# for(i in 1:length(subsetted)) {
#   print(subsetted[[i]]$test_timestep)
# }
# 
# seed = 2
# k = 2
# cpts = 1
# nit = 100
# fit_to_train = F
# nests = 100
# 
# all_ldats_fits <- lapply(subsetted, FUN = ldats_subset_one, k = k, seed = seed, cpts = cpts, nit = nit, fit_to_train = fit_to_train)
# 
# evals <- eval_ldats_crossval(all_ldats_fits, use_folds = T)
#   
# 
source("crossval_fxns.R")
## include the functions in packages as dependencies
#  - this is to help Drake recognize that targets need to be rebuilt if the
#    functions have changed

## a Drake plan for creating the datasets
#  - these are the default options, which don't include downloaded datasets
datasets <- build_bbs_datasets_plan()


m <- which(grepl(datasets$target, pattern = "rtrg_1_11")) # wants many topics

datasets <- datasets[m,]


#if(FALSE){
  methods <- drake::drake_plan(
    ldats_fit = target(fit_ldats_crossval(dataset, use_folds = T, n_folds = 10, n_timesteps = 2, buffer = 3, k = ks, seed = seeds, cpts = cpts, nit = 500, fit_to_train = FALSE),
                       transform = cross(
                         dataset = !!rlang::syms(datasets$target),
                         ks = !!c(2:10),
                         seeds = !!seq(2, 50, by = 2),
                         cpts = !!c(0:5)
                       )),
    ldats_eval = target(eval_ldats_crossval(ldats_fit, use_folds = T),
                        transform = map(ldats_fit)
    ),
    all_evals = target(dplyr::bind_rows(ldats_eval),
                       transform = combine(ldats_eval, .by = dataset))
  )  
# } else {
#   methods <- drake::drake_plan(
#     ldats_fit = target(fit_ldats_crossval(dataset, buffer = 4, k = ks, seed = seeds, cpts = cpts, nit = 1000, fit_to_train = FALSE),
#                        transform = cross(
#                          dataset = !!rlang::syms(datasets$target),
#                          ks = !!c(2:5),
#                          seeds = !!seq(2, 50, by = 2),
#                          cpts = !!c(0:5)
#                        )),
#     ldats_eval = target(eval_ldats_crossval(ldats_fit, nests = 1000),
#                         transform = map(ldats_fit)
#     ),
#     all_evals = target(dplyr::bind_rows(ldats_eval),
#                        transform = combine(ldats_eval, .by = dataset))
#   )
# }


## The full workflow
workflow <- dplyr::bind_rows(
  datasets,
  methods
)


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-folds.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")

## Run the pipeline
nodename <- Sys.info()["nodename"]
if(grepl("ufhpc", nodename)) {
  print("I know I am on the HiPerGator!")
  library(clustermq)
  options(clustermq.scheduler = "slurm", clustermq.template = "slurm_clustermq.tmpl")
  ## Run the pipeline parallelized for HiPerGator
  make(workflow,
       force = TRUE,
       cache = cache,
       cache_log_file = here::here("analysis", "drake", "cache_log_folds.txt"),
       verbose = 1,
       parallelism = "clustermq",
       jobs = 50,
       caching = "master", memory_strategy = "autoclean") # Important for DBI caches!
} else {
  
  # Run the pipeline on multiple local cores
  system.time(make(workflow, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log_folds.txt")))
}


loadd(all_evals_bbs_rtrg_1_11, cache = cache)
write.csv(all_evals_bbs_rtrg_1_11, "all_evals_bbs_rtrg_1_11_folds.csv")
# 
# all_evals_bbs_rtrg_1_11 <- read.csv("all_evals_bbs_rtrg_1_11_folds.csv")
# 
# 
# all_evals_bbs_rtrg_1_11 <- all_evals_bbs_rtrg_1_11 %>%
#   group_by(cpts, k, seed) %>%
#   summarize(mean_sum_loglik = mean(sum_loglik)) %>%
#   arrange(desc(mean_sum_loglik))
# 
#   head(all_evals_bbs_rtrg_1_11)
# 
# ggplot(filter(all_evals_bbs_rtrg_1_11), aes(cpts, group = cpts, y = mean_sum_loglik)) + geom_point() + facet_wrap(vars( k))
# 
# 
# ggplot(filter(all_evals_bbs_rtrg_1_11), aes(cpts, group = cpts, y = mean_sum_loglik, color = as.factor(k))) + geom_point()
# 
# 
# 
# sd_score <- sd(all_evals_bbs_rtrg_1_11$mean_sum_loglik) / sqrt(nrow(all_evals_bbs_rtrg_1_11))
# sd_cutoof <-  max(all_evals_bbs_rtrg_1_11$mean_sum_loglik) - 113
# 
# 
# ggplot(filter(all_evals_bbs_rtrg_1_11), aes(cpts, group = cpts, y = mean_sum_loglik, color = as.factor(k))) + geom_point() + geom_hline(yintercept = c(sd_cutoof, quantile(all_evals_bbs_rtrg_1_11$mean_sum_loglik, probs = .95)))
# 
# 
# ggplot(filter(all_evals_bbs_rtrg_1_11, mean_sum_loglik >sd_cutoof), aes(cpts, group = cpts, y = mean_sum_loglik, color = as.factor(k))) + geom_point()
# 
# ggplot(all_evals_bbs_rtrg_1_11, aes(cpts, group = cpts, y = mean_sum_loglik, color = test_steps)) + geom_point() 
# 
# summary <- all_evals_bbs_rtrg_1_11 %>%
#   group_by(cpts, k) %>%
#   summarize(mean_score = mean(mean_sum_loglik)) %>%
#   arrange(desc(mean_score))
# 
# 
# ggplot(filter(summary), aes(cpts, group = cpts, y = mean_score, color = as.factor(k))) + geom_point()

DBI::dbDisconnect(db)
rm(cache)
