library(drake)
library(LDATS)
#remotes::install_github("diazrenata/cvlt")
library(cvlt)
library(ggplot2)

## Set up the cache and config
db <- DBI::dbConnect(RSQLite::SQLite(), here::here("analysis", "drake", "drake-cache-cvlt.sqlite"))
cache <- storr::storr_dbi("datatable", "keystable", db)
cache$del(key = "lock", namespace = "session")

loadd(best_config_all_dataset_fits_portal_annual, cache = cache)
loadd(portal_annual, cache = cache)

best_config_modified <- best_config_all_dataset_fits_portal_annual %>%  dplyr::mutate(cpts = 3)
best_config <- best_config_all_dataset_fits_portal_annual
best_mod <- run_best_model(portal_annual, best_config_modified, nit = 1000)



#### summary attributes ####

#### lda ####

ntopics <- best_mod$lda_mod@k

#### ts ####

ncpts <- best_mod$ts_mod$nchangepoints

### changepoint info ###

cpt_summary <- best_mod$ts_mod$rho_summary %>%
  dplyr::mutate(cpt = row.names(best_mod$ts_mod$rho_summary)) %>%
  dplyr::group_by_all() %>%
  dplyr::mutate(cpt = unlist(strsplit(cpt, split = "_"))[2]) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(nyears = length(unique(best_mod$dataset$covariates$year))) %>%
  dplyr::mutate(width =`Upper_95%` - `Lower_95%`) %>%
  dplyr::mutate(width_ratio = width / nyears)

### changepoint change - need abundance probs... ###


## find parameters for modal cpt estimate ##

common_rhos <- best_mod$ts_mod$rhos %>%
  as.data.frame() %>%
  dplyr::group_by_all() %>%
  dplyr::mutate(tally = dplyr::n()) %>%
  dplyr::ungroup() %>%
  dplyr::mutate(draw = dplyr::row_number())

modal_rhos <- common_rhos %>%
  dplyr::filter(tally == max(common_rhos$tally)) %>%
  dplyr::select(-tally, -draw) %>%
  dplyr::distinct()
# 
modal_ts <- LDATS::multinom_TS(data = best_mod$ts_mod$data, best_mod$ts_mod$formula, changepoints = unlist(modal_rhos[1,]), timename = "year")
#modal_ts <- LDATS::multinom_TS(data = best_mod$ts_mod$data, best_mod$ts_mod$formula, changepoints = NULL, timename = "year")

modal_ts_fits <- list()

for(i in 1:length(modal_ts[[1]])) {
  modal_ts_fits[[i]] <- as.data.frame(modal_ts[[1]][[i]]$fitted.values) %>%
    dplyr::mutate(timestep = row.names(.))
}

modal_ts_fits <- dplyr::bind_rows(modal_ts_fits, .id = "seg")

modal_ts_fits <- modal_ts_fits %>%
  dplyr::mutate(year = best_mod$ts_mod$data$year)

## use modal rhos to estimate abundances ##

modal_thetas <- modal_ts_fits %>%
  dplyr::select(-seg, -timestep, -year) %>%
  as.matrix()

modal_betas <- exp(best_mod$lda_mod@beta)

modal_abundance_preds <- modal_thetas %*% modal_betas

fitted_data <- modal_abundance_preds %>%
  as.data.frame()
colnames(fitted_data) <- colnames(best_mod$dataset$abundance)



## use fitted values to calculate magnitude of cpt change ##

segment_fitted_values <- fitted_data %>%
  dplyr::mutate(year = best_mod$dataset$covariates$year) %>%
  dplyr::left_join(dplyr::select(modal_ts_fits, year, seg)) %>%
  dplyr::select(-year) %>%
  dplyr::distinct()

segment_matrix <- segment_fitted_values %>%
  dplyr::select(-seg) %>%
  as.matrix()

segment_bc <- as.matrix(vegan::vegdist(segment_matrix, method = "bray"))

changepoint_distance <- cpt_summary %>%
  dplyr::mutate(seg_before = as.numeric(cpt),
                seg_after = as.numeric(cpt) + 1,
                dissimilarity = NA)

for(i in 1:nrow(changepoint_distance)) {
  changepoint_distance$dissimilarity[i] <- segment_bc[changepoint_distance$seg_before[i], changepoint_distance$seg_after[i]]
}

## use fitted and actual values to calculate various r2s ## 

actual_data <- (best_mod$dataset$abundance) %>%
  dplyr::mutate_all(as.numeric)

for(i in 1:nrow(actual_data)) {
  actual_data[i,] <- actual_data[i,] / sum(actual_data[i,])
}

# 
# for(i in 1:nrow(fitted_data)) {
#   fitted_data[i, ] <- fitted_data[i, ] * sum(actual_data[i, ])
# }

fitted_data <- fitted_data %>%
  dplyr::mutate(year = best_mod$dataset$covariates$year)

actual_data <- as.data.frame(actual_data) %>%
  dplyr::mutate(year = best_mod$dataset$covariates$year)

fitted_data_long <- tidyr::pivot_longer(fitted_data, -c(year), names_to = "species", values_to = "fitted_prop")

actual_data_long <- tidyr::pivot_longer(actual_data, -c(year), names_to = "species", values_to = "actual_prop")

fitted_actual <- dplyr::left_join(fitted_data_long, actual_data_long)

ggplot(fitted_actual, aes(actual_prop, fitted_prop)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0)



ggplot(fitted_actual, aes(actual_prop, fitted_prop, color = species)) +
  geom_point() +
  stat_ellipse() +
  geom_abline(slope = 1, intercept = 0) +
  theme(legend.position = "none") +
  scale_color_viridis_d(option = "mako")


ggplot(fitted_actual, aes(actual_prop, fitted_prop)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  facet_wrap(vars(year))


ggplot(fitted_actual, aes(actual_prop, fitted_prop)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  facet_wrap(vars(species), scales = "free")

## r2 ##
# obs_mean <- mean(obs)
# 
# numer <- sum((obs - pred) ^ 2)
# denom <- sum((obs - obs_mean) ^ 2)
# 1 - (numer/denom)


fitted_actual_r2s <- fitted_actual %>%
  dplyr::mutate(difference = actual_prop - fitted_prop) %>%
  dplyr::mutate(obs_mean_overall = mean(actual_prop)) %>%
  dplyr::group_by(year) %>%
  dplyr::mutate(obs_mean_by_year = mean(actual_prop)) %>% # this equals overall because both are just 1/nspecies. 
  dplyr::ungroup() %>%
  dplyr::group_by(species) %>%
  dplyr::mutate(obs_mean_by_species = mean(actual_prop)) %>%
  dplyr::ungroup()

overall_num <- sum(fitted_actual_r2s$difference ^ 2)
overall_denom <- sum((fitted_actual_r2s$actual_prop - fitted_actual_r2s$obs_mean_overall) ^ 2)

1 - (overall_num / overall_denom)


annual_r2 <- fitted_actual_r2s %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(num = sum(difference ^ 2),
                   denom = sum((actual_prop - obs_mean_by_year) ^ 2)) %>%
  dplyr::mutate(r2 = 1 - (num / denom))

species_r2 <- fitted_actual_r2s %>%
  dplyr::group_by(species) %>%
  dplyr::summarize(num = sum(difference ^ 2),
                   denom = sum((actual_prop - obs_mean_by_species) ^ 2)) %>%
  dplyr::mutate(r2 = 1 - (num / denom))
