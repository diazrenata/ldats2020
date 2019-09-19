library(drake)
library(ggplot2)
library(dplyr)
library(matssldats)
library(MATSS)
library(LDATS)
source(here::here("fxns", "lda_wrapper.R"))



## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("drake", "drake-cache.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)

loadd(dat_4L, cache = cache)

# do this until you get an error
models <- list()
for(i in 1:50) {
  set.seed(i)
 models[[i]] <- ldats_wrapper(dat_4L, seed = 18, ntopics = 2, ncpts = 2, formulas = "intercept", 
                nit = 100)
}

for(i in 1:50) {
  print(mode(models[[i]]$ts_lliks))
}
