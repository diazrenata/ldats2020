library(drake)
library(ggplot2)
library(dplyr)
source(here::here("crossval_fxns.R"))
source(here::here("hybrid_fxns.R"))
library(MATSS)
library(LDATS)
# load("bbs_1_11.RData")
# 
# 
# 
# hybrid_fit <- fit_ldats_hybrid(bbs_rtrg_1_11, k = 2, cpts = c(0:1), seed = 2, nit = 100, use_folds = T, n_folds = 2, n_timesteps = 2, buffer = 2, fold_seed = 1977)
# 
# hybrid_eval <- eval_ldats_crossval(hybrid_fit, use_folds = T)

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
  ldats_fit = target(fit_ldats_hybrid(dataset, use_folds = T, n_folds = 20, n_timesteps = 2, buffer = 2, k = ks, seed = seeds, cpts = c(0:5), nit = 500),
                     transform = cross(
                       dataset = !!rlang::syms(datasets$target),
                       ks = !!c(2:10),
                       seeds = !!seq(2, 10, by = 2)
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
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-hybrid.sqlite"))
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
       cache_log_file = here::here("analysis", "drake", "cache_log_hybrid.txt"),
       verbose = 1,
       parallelism = "clustermq",
       jobs = 50,
       caching = "master", memory_strategy = "autoclean") # Important for DBI caches!
} else {
  
  # Run the pipeline on multiple local cores
  system.time(make(workflow, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log_hybrid.txt")))
}


loadd(all_evals_bbs_rtrg_1_11, cache = cache)
write.csv(all_evals_bbs_rtrg_1_11, "all_evals_bbs_rtrg_1_11_hybrid.csv")

DBI::dbDisconnect(db)
rm(cache)
