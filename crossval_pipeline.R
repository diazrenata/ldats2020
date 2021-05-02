library(MATSS)
library(drake)
library(LDATS)
source(here::here("analysis", "fxns", "crossval_fxns.R"))
source(here::here("analysis", "fxns", "make_short_portal.R"))
## include the functions in packages as dependencies
#  - this is to help Drake recognize that targets need to be rebuilt if the
#    functions have changed

## a Drake plan for creating the datasets
#  - these are the default options, which don't include downloaded datasets
datasets <- build_bbs_datasets_plan()


m <- which(grepl(datasets$target, pattern = "rtrg_102_18")) # wants many topics

datasets <- datasets[m,]

portal_dat <- drake::drake_plan(
  portal_annual = target(get_rodents_annual()),
  portal_winter_plants = target(cvlt::get_plants_annual("winter")),
  portal_summer_plants = target(cvlt::get_plants_annual("summer"))
)

datasets <- bind_rows(datasets, portal_dat)

if(FALSE){
  methods <- drake::drake_plan(
    ldats_fit = target(fit_ldats_crossval(dataset, buffer = 2, k = ks, seed = seeds, cpts = cpts, nit = 100, fit_to_train = FALSE),
                       transform = cross(
                         dataset = !!rlang::syms(datasets$target),
                         ks = !!c(2),
                         seeds = !!seq(2, 2, by = 2),
                         cpts = !!c(0:1)
                       )),
    ldats_eval = target(eval_ldats_crossval(ldats_fit, nests = 100, use_folds = T),
                        transform = map(ldats_fit)
    ),
    all_evals = target(dplyr::bind_rows(ldats_eval),
                       transform = combine(ldats_eval, .by = dataset))
  )  
} else {
  methods <- drake::drake_plan(
    # ldats_fit = target(fit_ldats_crossval(dataset, buffer = 2, k = ks, seed = seeds, cpts = cpts, nit = 1000, fit_to_train = FALSE),
    #                    transform = cross(
    #                      dataset = !!rlang::syms(datasets$target),
    #                      ks = !!c(2:5),
    #                      seeds = !!seq(2, 20, by = 2),
    #                      cpts = !!c(0:4)
    #                    )),
    # ldats_eval_f = target(eval_ldats_crossval(ldats_fit, nests = 1000, use_folds = T),
    #                     transform = map(ldats_fit)
    # ),
    # all_evals_f = target(dplyr::bind_rows(ldats_eval_f),
    #                    transform = combine(ldats_eval_f, .by = dataset)),
    ldats_fit_hasty = target(fit_ldats_crossval(dataset, buffer = 2, k = ks, seed = seeds, cpts = cpts, nit = 100, fit_to_train = FALSE),
                       transform = cross(
                         dataset = !!rlang::syms(datasets$target),
                         ks = !!c(2:5),
                         seeds = !!seq(2, 20, by = 2),
                         cpts = !!c(0:4)
                       )),
    ldats_eval_f_hasty = target(eval_ldats_crossval(ldats_fit_hasty, nests = 1000, use_folds = T),
                          transform = map(ldats_fit_hasty)
    ),
    all_evals_f_hasty = target(dplyr::bind_rows(ldats_eval_f_hasty),
                         transform = combine(ldats_eval_f_hasty, .by = dataset))
  )
}


## The full workflow
workflow <- dplyr::bind_rows(
  datasets,
  methods
)


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-cv.sqlite"))
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
       cache_log_file = here::here("analysis", "drake", "cache_log.txt"),
       verbose = 1,
       parallelism = "clustermq",
       jobs = 20,
       caching = "master", memory_strategy = "autoclean") # Important for DBI caches!
} else {
 
  # Run the pipeline on multiple local cores
  system.time(make(workflow, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log.txt"), verbose = 1, memory_strategy = "autoclean"))
}

# 
# loadd(all_evals_f_bbs_rtrg_102_18, cache = cache)
# write.csv(all_evals_f_bbs_rtrg_102_18, "all_evals_bbs_rtrg_102_18_cv.csv")
# 
# loadd(all_evals_f_portal_annual, cache = cache)
# write.csv(all_evals_f_portal_annual, "all_evals_portal_annual_cv.csv")


loadd(all_evals_f_hasty_bbs_rtrg_102_18, cache = cache)
write.csv(all_evals_f_hasty_bbs_rtrg_102_18, "all_evals_f_hasty_bbs_rtrg_102_18_cv.csv")

loadd(all_evals_f_hasty_portal_annual, cache = cache)
write.csv(all_evals_f_hasty_portal_annual, "all_evals_f_hasty_portal_annual_cv.csv")

loadd(all_evals_f_hasty_portal_winter_plants, cache = cache)
write.csv(all_evals_f_hasty_portal_winter_plants, "all_evals_f_hasty_portal_winter_plants_cv.csv")

loadd(all_evals_f_hasty_portal_summer_plants, cache = cache)
write.csv(all_evals_f_hasty_portal_summer_plants, "all_evals_f_hasty_portal_summer_plants_cv.csv")



DBI::dbDisconnect(db)
rm(cache)


