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

## Visualize how the targets depend on one another
if (interactive())
{
  config <- drake_config(workflow)
  sankey_drake_graph(config, build_times = "none", targets_only = TRUE)  # requires "networkD3" package
  vis_drake_graph(config, build_times = "none", targets_only = TRUE)     # requires "visNetwork" package
}

## Run the workflow
make(workflow)



