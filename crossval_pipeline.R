library(MATSS)
library(drake)
library(LDATS)
source("crossval_fxns.R")
## include the functions in packages as dependencies
#  - this is to help Drake recognize that targets need to be rebuilt if the
#    functions have changed

## a Drake plan for creating the datasets
#  - these are the default options, which don't include downloaded datasets
datasets <- build_bbs_datasets_plan()


m <- which(grepl(datasets$target, pattern = "rtrg_1_11")) # wants many topics

datasets <- datasets[m,]



methods <- drake::drake_plan(
  ldats_fit = target(fit_ldats_crossval(dataset, buffer = 2, k = ks, seed = seeds, cpts = cpts, nit = 100, fit_to_train = FALSE),
                     transform = cross(
                       dataset = !!rlang::syms(datasets$target),
                       ks = !!c(2:5, 10:15),
                       seeds = !!seq(2, 10, by = 2),
                       cpts = !!c(0:2)
                     )),
  ldats_eval = target(eval_ldats_crossval(ldats_fit, nests = 100),
                       transform = map(ldats_fit)
  ),
  all_evals = target(dplyr::bind_rows(ldats_eval),
                     transform = combine(ldats_eval))
)  
  

## The full workflow
workflow <- dplyr::bind_rows(
  datasets,
  methods
)


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)

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
       cache_log_file = here::here("analysis", "drake", "cache_log.txt"),
       verbose = 2,
       parallelism = "clustermq",
       jobs = 50,
       caching = "master", memory_strategy = "autoclean") # Important for DBI caches!
} else {
  library(clustermq)
  options(clustermq.scheduler = "multicore")
  # Run the pipeline on multiple local cores
  system.time(make(workflow, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log.txt"), parallelism = "clustermq", jobs = 2))
}


loadd(all_evals, cache = cache)
write.csv(all_evals, "all_evals.csv")

DBI::dbDisconnect(db)
rm(cache)


