library(MATSS)
library(drake)
source(here::here("find_holes.R"))
## include the functions in packages as dependencies
#  - this is to help Drake recognize that targets need to be rebuilt if the
#    functions have changed

## a Drake plan for creating the datasets
#  - these are the default options, which don't include downloaded datasets
datasets <- build_bbs_datasets_plan()


methods <- drake::drake_plan(
  holes = target(find_holes(dataset),
                 transform = map(
                   dataset = !!rlang::syms(datasets$target)
                 )),
  all_holes = target(dplyr::bind_rows(holes),
                     transform = combine(holes))
)


## The full workflow
workflow <- dplyr::bind_rows(
  datasets,
  methods
)


## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-holes.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")

# Run the pipeline on multiple local cores
system.time(make(workflow, cache = cache, cache_log_file = here::here("analysis", "drake", "cache_log.txt"), verbose = 1, memory_strategy = "autoclean"))
#}


loadd(all_holes, cache = cache)
write.csv(all_holes, "bbs_holes.csv", row.names = F)

DBI::dbDisconnect(db)
rm(cache)


