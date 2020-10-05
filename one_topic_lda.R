# fit an lda with 2 topics - we will then mess with it

library(LDATS)
# 
# load("portal_annual.RData")
# 
# k2 <- LDA_set_user_seeds(abund_dat$abundance, topics =  2, seed = 2)
# 
# k1 <- k2
# 
# prop_abund <- abund_dat$abundance / rowSums(abund_dat$abundance)
# 
# species_means <- apply(prop_abund, 2, FUN = mean)
# 
# k1[[1]]@k <- as.integer(1)
# k1[[1]]@beta <- matrix(data = species_means, nrow =1 )
# k1[[1]]@gamma <- matrix(data = 1, ncol = 1, nrow = nrow(k1[[1]]@gamma))
# k1[[1]]@loglikelihood <- 0
# k1[[1]]@logLiks <- 0
# k1[[1]]@wordassignments <- NULL
# k1[[1]]@alpha <- 0
# 
# k2_ts <- TS_on_LDA(k1[[1]], as.data.frame(abund_dat$covariates),  ~ 1, nchangepoints = 0, timename = "year")
# 
# # need two or more classes to fit a multinom model
# 
# # skip directly to loglik?
# 
# k1_ll <- apply(abund_dat$abundance, 1, FUN = function(row) 
#   return(dmultinom(row, prob = species_means, log = T)))
# 
# k1_ll

one_topic_ll <- function(subsetted_dataset_item) {
  
  prop_abund <- subsetted_dataset_item$train$abundance / rowSums(subsetted_dataset_item$train$abundance)
  
  species_means <- apply(prop_abund, 2, FUN = mean)
  
  k1_ll <- dmultinom(subsetted_dataset_item$test$abundance, prob = species_means, log = T)
  
  return(k1_ll)
}

all_ll_subsets <- function(full_dat) {
  all_subsets <- subset_data_all(full_dat, 2)
  all_ll <- lapply(all_subsets, one_topic_ll)
  return(sum(unlist(all_ll)))
}


#all_ll_subsets(abund_dat)
