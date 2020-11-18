# toy_dataset_names <- list.files("toy_datasets", pattern = ".csv") 
# 
# directional <- list()
# 
# directional$abundance <- read.csv(here::here("toy_datasets", "directional.csv"), stringsAsFactors = F)
# 
# directional$covariates <- data.frame(year = 1:nrow(directional$abundance), dummycol = "ignore_me")
# 
# save(directional, file = here::here("toy_datasets", "directional.RData"))
# 
# 
# directional <- list()
# 
# directional$abundance <- read.csv(here::here("toy_datasets", "directional.csv"), stringsAsFactors = F)
# 
# directional$covariates <- data.frame(year = 1:nrow(directional$abundance), dummycol = "ignore_me")
# 
# save(directional, file = here::here("toy_datasets", "directional.RData"))
# 
# 
# directional_changepoint <- list()
# 
# directional_changepoint$abundance <- read.csv(here::here("toy_datasets", "directional_changepoint.csv"), stringsAsFactors = F)
# 
# directional_changepoint$covariates <- data.frame(year = 1:nrow(directional_changepoint$abundance), dummycol = "ignore_me")
# 
# save(directional_changepoint, file = here::here("toy_datasets", "directional_changepoint.RData"))
# 
# 
# noise_seed1 <- list()
# 
# noise_seed1$abundance <- read.csv(here::here("toy_datasets", "noise_seed1.csv"), stringsAsFactors = F)
# 
# noise_seed1$covariates <- data.frame(year = 1:nrow(noise_seed1$abundance), dummycol = "ignore_me")
# 
# save(noise_seed1, file = here::here("toy_datasets", "noise_seed1.RData"))
# 
# 
# static <- list()
# 
# static$abundance <- read.csv(here::here("toy_datasets", "static.csv"), stringsAsFactors = F)
# 
# static$covariates <- data.frame(year = 1:nrow(static$abundance), dummycol = "ignore_me")
# 
# save(static, file = here::here("toy_datasets", "static.RData"))
# 
# 
# static_changepoint <- list()
# 
# static_changepoint$abundance <- read.csv(here::here("toy_datasets", "static_changepoint.csv"), stringsAsFactors = F)
# 
# static_changepoint$covariates <- data.frame(year = 1:nrow(static_changepoint$abundance), dummycol = "ignore_me")
# 
# save(static_changepoint, file = here::here("toy_datasets", "static_changepoint.RData"))

get_toy_data <- function(toy_dataset_name, toy_datasets_path) {
  
  dat <- list()
  
  dat$abundance <- read.csv(file.path(toy_datasets_path, paste0(toy_dataset_name, ".csv")), stringsAsFactors = F)
  
  if(toy_dataset_name != "rodents") {
  
  dat$covariates <- data.frame(year = 1:nrow(dat$abundance), dummycol = "ignore_me")
  } else {
    dat$covariates <- read.csv(file.path(toy_datasets_path, "rodents_covariates.csv"), stringsAsFactors = F)
  }
dat}