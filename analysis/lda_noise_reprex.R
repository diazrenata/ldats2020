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


