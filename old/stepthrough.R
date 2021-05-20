library(MATSS)
library(drake)
library(LDATS)
source(here::here("analysis", "fxns", "crossval_fxns.R"))



## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-cv.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")


h = readd(bbs_rtrg_102_18, cache = cache)


h_subsets <- subset_data_all(h, use_folds = F, buffer_size = 2)

all_ldats_fits <- lapply(h_subsets, FUN = ldats_subset_one, k = 2, seed = 16, cpts = 1, nit = 100, fit_to_train = FALSE)

estimates <- estimate_ts_loglik(all_ldats_fits, nests = 1000)

ll_df <- make_ll_df(estimates)

single_ll <- singular_ll(all_ldats_fits)

ll_df <- dplyr::left_join(ll_df, single_ll)


# OR

ll_df_folds <- make_folds_loglik_df(all_ldats_fits) # ll_df$meanloglik column is the samea s the sum of ll_df_folds$sum_loglik. This is the SUM of the MEAN LOGLIKELIHOODS OF EACH TEST STEP. So for test step 1, there rare 100 estimates of the loglikelihood. Take the mean. Then add up all the means for each time step to a single estimate of the overall ts loglikelihood. THIS IN CONTRAST TO, draw 1 estimate of the loglikelihood for each test timestep and add them up, then repeat a bunch of times. THAT is what ll_df$loglik is. 
