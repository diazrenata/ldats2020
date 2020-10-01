LDATS on a dataset that likes lots of topics
================

``` r
datasets <- build_bbs_datasets_plan()

m <- which(grepl(datasets$target, pattern = "rtrg_1_11")) # wants many topics

dat <- eval(unlist(datasets$command[m][[1]]))
```

This community has a total of 82 species surveyed in 23 years from 1974
to 2014.

``` r
dat_long <- dat$abundance %>%
  mutate(year = dat$covariates$year,
         totalannual = rowSums(dat$abundance))  %>%
  tidyr::pivot_longer(c(-year, -totalannual),names_to = "species", values_to = "abundance") %>%
  mutate(propannual = abundance / totalannual)


ggplot(dat_long, aes(year, propannual, color = species)) +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d() +
  theme(legend.position = "none") +
  ggtitle("Proportional abundance of all species")
```

![](crossvalidation_one_lda_files/figure-gfm/plot%20dat-1.png)<!-- -->

### Training/test subsetting

From this data structure, we want to split it into \[many\]
training/test subsets.

For now, I will allow *each timestep* to be a test year. For the subset
for which a given year is the test year, I will additionally withhold 2
timesteps on either side as a buffer.

Each training/test object must have the following components:

  - Training data + covariates table/vector
  - Test data + covariates table/vector

<!-- end list -->

``` r
subsetted_dat <- subset_data_all(dat)
```

### Fitting a LDA + TS model to every subset

``` r
ldats_one <- ldats_subset_one(subsetted_dat[[1]], 2, 2, 0, 100)

ldats_all <- lapply(subsetted_dat, FUN = ldats_subset_one, k = 2, seed = 2, cpts = 0, nit = 100)

ldats_all_logliks <- estimate_ts_loglik(ldats_all, nests = 100)

ldats_all_logliks
```

``` r
ldats_0_cpts <- lapply(subsetted_dat, FUN = ldats_subset_one, k = 2, seed = 2, cpts = 0, nit = 100, fit_to_train = F)
```

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model

``` r
ldats_0_cpts_ll <- estimate_ts_loglik(ldats_0_cpts, nests = 1000)

ldats_1_cpts <- lapply(subsetted_dat, FUN = ldats_subset_one, k = 2, seed = 2, cpts = 1, nit = 100, fit_to_train = F)
```

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

``` r
ldats_1_cpts_ll <- estimate_ts_loglik(ldats_1_cpts, nests = 1000)


ldats_2_cpts <- lapply(subsetted_dat, FUN = ldats_subset_one, k = 2, seed = 2, cpts = 2, nit = 100)
```

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

``` r
ldats_2_cpts_ll <- estimate_ts_loglik(ldats_2_cpts, nests = 1000)



bundle_lls <- function(list_of_lls) {
  
  ll_dfs <- lapply(list_of_lls, make_ll_df)
  
  bind_rows(ll_dfs)
}

make_ll_df <- function(ll) {
  
  cbind(data.frame(loglik = ll$loglik_ests), as.data.frame(ll$model_info))
  
}

ll_comparison <- bundle_lls(list(ldats_0_cpts_ll, ldats_1_cpts_ll))


library(ggplot2)

ggplot(ll_comparison, aes(x = loglik, group = as.factor(cpts), color = as.factor(cpts))) +
  geom_density() +
  theme_bw()
```

![](crossvalidation_one_lda_files/figure-gfm/comparison-1.png)<!-- -->

K, let’s plot these as panels…

``` r
ts_bottom_plot <- function (x, cols = set_TS_summary_plot_cols(), bin_width = 1, 
                            xname = NULL, border = NA, selection = "median", LDATS = FALSE) 
{
  rc <- cols$rho
  rho_cols <- set_rho_hist_colors(x$rhos, rc$cols, rc$option, 
                                  rc$alpha)
  rho_hist(x, rho_cols, bin_width, xname, border, TRUE, LDATS)
  gc <- cols$gamma
  gamma_cols <- set_gamma_colors(x, gc$cols, gc$option, gc$alpha)
  gamma_plot(x, selection, gamma_cols, xname, TRUE, 
                     LDATS)
}

plot_panels <- function(section_index = 1, no_cpt_list, one_cpt_list, two_cpt_list = NULL){
  
  plot(no_cpt_list[[section_index]]$fitted_lda)
  plot.new()
   ts_bottom_plot(no_cpt_list[[section_index]]$fitted_ts)
   plot.new()
   ts_bottom_plot(one_cpt_list[[section_index]]$fitted_ts, selection = "mode")
   if(!is.null(two_cpt_list)) {
     plot.new()
        ts_bottom_plot(two_cpt_list[[section_index]]$fitted_ts, selection = "mode")

   }
}



for(i in 1:23) {
  plot_panels(i, ldats_0_cpts, ldats_1_cpts, ldats_2_cpts)
}
```

![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-1.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-2.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-3.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-4.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-5.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-6.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-7.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-8.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-9.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-10.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-11.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-12.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-13.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-14.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-15.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-16.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-17.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-18.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-19.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-20.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-21.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-22.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-23.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-24.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-25.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-26.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-27.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-28.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-29.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-30.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-31.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-32.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-33.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-34.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-35.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-36.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-37.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-38.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-39.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-40.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-41.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-42.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-43.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-44.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-45.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-46.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-47.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-48.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-49.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-50.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-51.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-52.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-53.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-54.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-55.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-56.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-57.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-58.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-59.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-60.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-61.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-62.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-63.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-64.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-65.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-66.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-67.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-68.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-69.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-70.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-71.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-72.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-73.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-74.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-75.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-76.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-77.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-78.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-79.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-80.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-81.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-82.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-83.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-84.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-85.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-86.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-87.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-88.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-89.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-90.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-91.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-92.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-93.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-94.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-95.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-96.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-97.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-98.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-99.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-100.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-101.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-102.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-103.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-104.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-105.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-106.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-107.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-108.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-109.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-110.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-111.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-112.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-113.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-114.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-115.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-116.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-117.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-118.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-119.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-120.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-121.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-122.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-123.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-124.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-125.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-126.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-127.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-128.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-129.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-130.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-131.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-132.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-133.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-134.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-135.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-136.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-137.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-138.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-139.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-140.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-141.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-142.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-143.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-144.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-145.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-146.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-147.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-148.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-149.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-150.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-151.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-152.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-153.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-154.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-155.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-156.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-157.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-158.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-159.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-160.png)<!-- -->![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-161.png)<!-- -->

``` r
plot(LDA_set_user_seeds(
      document_term_table = dat$abundance,
      topics = 2,
      seed = 2)[[1]])
```

    ## Running LDA with 2 topics (seed 2)

![](crossvalidation_one_lda_files/figure-gfm/panel%20plots-162.png)<!-- -->

``` r
one_with_cpt <- ldats_1_cpts[[2]]$fitted_ts

plot(one_with_cpt)
```

![](crossvalidation_one_lda_files/figure-gfm/trying%20to%20do%20ts%20plots-1.png)<!-- -->

``` r
all_thetas <- (lapply(1:100, FUN =  get_one_theta, subsetted_dataset_item = subsetted_dat[[2]], fitted_ts = one_with_cpt))
for(i in 1:length(all_thetas)) {
  all_thetas[[i]] <- as.data.frame(all_thetas[[i]])
  all_thetas[[i]]$timestep = dat$covariates$year
  all_thetas[[i]]$sim = i
}


names(all_thetas) <- 1:100
all_thetas <- bind_rows(all_thetas) 

all_thetas <- all_thetas %>%
  mutate(sim = as.factor(sim)) #%>%
# tidyr::pivot_longer(cols = c(V1, V2), names_to = "topic", values_to = "prop")

ggplot(all_thetas, aes(timestep, V1, group = sim)) +
  geom_line(alpha = .1, size = 2) +
  geom_line(aes(timestep, V2, group = sim), alpha = .1, size = 2, color = "green") +
  theme_bw() +
  theme(legend.position = "none") +
  ylim(0, 1)
```

![](crossvalidation_one_lda_files/figure-gfm/trying%20to%20do%20ts%20plots-2.png)<!-- -->

### How do the betas vary over time?

``` r
extract_betas <- function(ldats_fit) {
  betas_t <- as.data.frame(t(ldats_fit$fitted_lda@beta))
  colnames(betas_t) <- c("t1", "t2")
  betas_t$species <- 1:nrow(betas_t)
  betas_t  
}


betas <- lapply(ldats_0_cpts, extract_betas)

betas <- bind_rows(betas, .id = "tstep")

ggplot(betas, aes(tstep, t1)) +
  geom_point() +
  geom_point(aes(tstep, t2), color = "blue") +
  facet_wrap(vars(as.factor(species)))
```

![](crossvalidation_one_lda_files/figure-gfm/all%20ldas-1.png)<!-- -->
