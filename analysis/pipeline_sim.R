library(drake)
library(MATSS)
library(LDATS)
library(matssldats)
source(here::here("fxns", "lda_wrapper.R"))
## make sure the package functions in MATSS and matssldats are loaded in as
##   dependencies
expose_imports(MATSS)
expose_imports(matssldats)


seed <- seq(from = 2, to = 4, by = 2)
ncpts <- c(0, 1)

ntopics <- c(2, 3, 4, 7)

forms <- c("intercept", "time")


dats_touse <- list.files(path = here::here("data"), full.names = FALSE)
dats_touse <- unlist(strsplit(dats_touse, split = ".csv"))
dats_touse <- dats_touse[c(1, 2)]


njobs <- min(length(seed) * length(ncpts) * length(ntopics) * length(forms) * length(dats_touse) * 30, 100)

pipeline <- drake_plan(
  rdat = target(get_sim_dat(dat_to_use),
                transform = map(dat_to_use = !!dats_touse)),
  dat = target(subset_data(rdat, n_segs = 30, sequential = T, buffer = 2, which_seg = this_seg),
               transform = cross(rdat, this_seg = !!c(1:30))),
  model_lls = target(ldats_wrapper(dat, seed = sd, ntopics = k, ncpts = cpts, formulas = form, nit = 1000),
                  transform = cross(dat, sd = !!seed, k = !!ntopics,
                                    cpts = !!ncpts, form = !!forms)),
  composite_ll = target(combine_timestep_lls(list(model_lls), ncombos = 10000),
                        transform = combine(model_lls, .by = rdat))
)


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("drake", "drake-cache-sim.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)


## View the graph of the plan
if (interactive())
{
  config <- drake_config(pipeline, cache = cache)
  sankey_drake_graph(config, build_times = "none")  # requires "networkD3" package
  vis_drake_graph(config, build_times = "none")     # requires "visNetwork" package
}


## Run the pipeline
nodename <- Sys.info()["nodename"]
if(grepl("ufhpc", nodename)) {
  library(future.batchtools)
  print("I know I am on SLURM!")
  ## Run the pipeline parallelized for HiPerGator
  future::plan(batchtools_slurm, template = "slurm_batchtools.tmpl")
  make(pipeline,
       force = TRUE,
       cache = cache,
       cache_log_file = here::here("drake", "cache_log.txt"),
       verbose = 2,
       parallelism = "future",
       jobs = njobs,
       caching = "master") # Important for DBI caches!
} else {
  # Run the pipeline on a single local core
  system.time(make(pipeline, cache = cache, cache_log_file = here::here("drake", "cache_log.txt")))
}

