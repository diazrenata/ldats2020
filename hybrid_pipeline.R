library(drake)
library(ggplot2)
library(dplyr)
source(here::here("analysis", "fxns", "crossval_fxns.R"))
source(here::here("analysis", "fxns", "hybrid_fxns.R"))
source(here::here("analysis", "fxns", "make_toy_data_objects.R"))
library(MATSS)
library(LDATS)

## include the functions in packages as dependencies
#  - this is to help Drake recognize that targets need to be rebuilt if the
#    functions have changed

## a Drake plan for creating the datasets
#  - these are the default options, which don't include downloaded datasets
datasets <- build_bbs_datasets_plan()


m <- which(grepl(datasets$target, pattern = "rtrg_1_11")) # wants many topics

stories_codes = c("rtrg_304_17",
              "rtrg_102_18",
              "rtrg_105_4",
              "rtrg_133_6",
              "rtrg_19_35",
              "rtrg_172_14")

stories_codes <- vapply(stories_codes, FUN = function(story) return(min(which(grepl(datasets$target, pattern = story)))), FUN.VALUE = 1)

datasets <- datasets[c(m, stories_codes),]

toy_dataset_files <- list.files(here::here("analysis", "toy_datasets"), pattern= ".csv")
toy_dataset_files <- unlist(strsplit(toy_dataset_files, split = ".csv"))

toy_path <- here::here("analysis", "toy_datasets")

toy_datasets <- drake::drake_plan(
  toy = target(get_toy_data(dataset_name, toy_datasets_path = toy_path),
               transform = map(dataset_name = !!toy_dataset_files))
)

#datasets <- bind_rows(datasets, toy_datasets)
datasets <- toy_datasets[7, ]
#if(FALSE){
methods <- drake::drake_plan(
  ldats_fit = target(fit_ldats_hybrid(dataset, use_folds = T, n_folds = 20, n_timesteps = 2, buffer = 2, k = ks, seed = seeds, cpts = c(0:5), nit = 100),
                     transform = cross(
                       dataset = !!rlang::syms(datasets$target),
                       ks = !!c(2:8),
                       seeds = !!seq(4, 22, by = 2)
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


## View the graph of the plan
if (interactive())
{
  config <- drake_config(workflow, cache = cache)
  sankey_drake_graph(config, build_times = "none")  # requires "networkD3" package
  vis_drake_graph(config, build_times = "none")     # requires "visNetwork" package
}


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



all_evals_objs <- methods$target[which(grepl(methods$target, pattern = "all_evals"))]

all_evals_list <- list()

for(i in 1:length(all_evals_objs)) {
  
  all_evals_list[[i]] <- readd(all_evals_objs[i], character_only = T, cache = cache)
  
  all_evals_list[[i]]$dataset = all_evals_objs[i]
  
}

all_evals_df <- bind_rows(all_evals_list)

write.csv(all_evals_df, here::here("analysis", "all_evals_hybrid_portal.csv"), row.names = F)


DBI::dbDisconnect(db)
rm(cache)
