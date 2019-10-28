library(LDATS)
library(MATSS)
library(matssldats)
source(here::here("fxns", "lda_wrapper.R"))


noise <- get_sim_dat(datname = "noise_reprex")

rdat_1 <- subset_data(noise, n_segs = 30, sequential = T, buffer = 2, which_seg = 1)
rdat_2 <- subset_data(noise, n_segs = 30, sequential = T, buffer = 2, which_seg = 2)
rdat_10 <- subset_data(noise, n_segs = 30, sequential = T, buffer = 2, which_seg = 10)

#### These fail with this message:
# Fails: 
# Error in package_LDA_set(mods, mod_topics, mod_seeds) : 
#   mods not of class LDA_VEM
# In addition: Warning message:
#   In method(x, k, control, model, mycall, ...) :
#   problem selecting best fitting model

lda_rdat_1_k7 <- LDATS::LDA_set_user_seeds(document_term_table = rdat_1$abundance, topics = 7, seed = 2)

lda_rdat_1_k7 <- LDATS::LDA_set_user_seeds(document_term_table = rdat_1$abundance, topics = 7, seed = 10)

lda_rdat_2_k6 <- LDATS::LDA_set(document_term_table = rdat_2$abundance, topics = 6, nseeds = 1)

# Trying a different seed

lda_rdat_1_k7 <- LDATS::LDA_set_user_seeds(document_term_table = rdat_1$abundance, topics = 7, seed = 20) # seed = 20 works
lda_rdat_2_k6 <- LDATS::LDA_set_user_seeds(document_term_table = rdat_2$abundance, topics = 6, seed = 20) # seed = 20 works


#### These all run with seed = 2: 
lda_rdat_1_k8 <- LDATS::LDA_set(document_term_table = rdat_1$abundance, topics = 8, nseeds = 1)

lda_rdat_1_k6 <- LDATS::LDA_set(document_term_table = rdat_1$abundance, topics = 6, nseeds = 1)

lda_rdat_2_k7 <- LDATS::LDA_set(document_term_table = rdat_2$abundance, topics = 7, nseeds = 1)

lda_rdat_2_k8 <- LDATS::LDA_set(document_term_table = rdat_2$abundance, topics = 8, nseeds = 1)

lda_rdat_10_k7 <- LDATS::LDA_set(document_term_table = rdat_10$abundance, topics = 7, nseeds = 1)

lda_rdat_10_k8 <- LDATS::LDA_set(document_term_table = rdat_10$abundance, topics = 8, nseeds = 1)

lda_rdat_10_k6 <- LDATS::LDA_set(document_term_table = rdat_10$abundance, topics = 6, nseeds = 1)


### Trying to find one that won't fail

rm(list=ls())
nspp <- 7
ntimesteps <- 30
mean_nind <- 200
source(here::here("fxns", "lda_wrapper.R"))
library(matssldats)

for(i in 1:500){

set.seed(i)
N <- matrix(nrow = 1, data = rnorm(n = ntimesteps, mean = mean_nind, sd = .25 * mean_nind))

mean_abund <- mean_nind / nspp

abund_mat <- matrix(nrow = nspp, ncol = ntimesteps, data = rnorm(n = nspp * ntimesteps, mean = mean_abund, sd = .5 * mean_abund))

abund_mat <- t(floor(abund_mat))

sim_dat <- list(abundance = abund_mat, covariates = data.frame(timestep = 1:ntimesteps), metadata = list(timename = "timestep"))

rdat <- lapply(as.list(1:30), FUN = subset_data, data = sim_dat, n_segs = 30, sequential = T, buffer = 2)

ldas <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 2, control = list(seed = 2)))))
ldas2 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 2, control = list(seed = 4)))))

ldask3 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 3, control = list(seed = 2)))))
ldas2k3 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 3, control = list(seed = 4)))))

ldask4 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 4, control = list(seed = 2)))))
ldas2k4 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 4, control = list(seed = 4)))))

ldask7 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 7, control = list(seed = 2)))))
ldas2k7 <- (lapply(rdat, FUN = function(dat_list) return(
  topicmodels::LDA(dat_list$abundance, k = 7, control = list(seed = 4)))))
success <- TRUE
for(j in 1:30) {
  if(any(is.list(ldas[[j]]), is.list(ldas2[[j]]),
         is.list(ldask3[[j]]), is.list(ldas2k3[[j]]),
         is.list(ldask4[[j]]), is.list(ldas2k4[[j]]),
         is.list(ldask7[[j]]), is.list(ldas2k7[[j]]))) {
    success <- FALSE
  }
}

if(success) {
  print(i)
  break
}

}

# seed 20 works