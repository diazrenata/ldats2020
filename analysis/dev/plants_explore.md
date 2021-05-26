Portal annuals
================
Renata Diaz
2021-05-25

  - [Specs](#specs)
  - [winter](#winter)
  - [summer](#summer)

## Specs

``` r
methods <- drake::drake_plan(
  ldats_fit = target(fit_ldats_crossval(dataset, buffer = 2, k = ks, lda_seed = seeds, cpts = cpts, nit = 100),
                     transform = cross(
                       dataset = !!rlang::syms(datasets$target),
                       ks = !!c(2:5),
                       seeds = !!seq(2, 20, by = 2),
                       cpts = !!c(0:4),
                       return_full = F,
                       return_fits = F,
                       summarize_ll = F
                     )))
```

    ## Joining, by = "dat_name"

![](plants_explore_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

## winter

    ## Joining, by = "year"

    ## Joining, by = "cpt"

    ## Joining, by = "year"

    ## Joining, by = c("year", "species")

<div class="kable-table">

| k | lda\_seed | cpts | nit | mean\_loglik | se\_loglik | dat\_name           |    Mean | Median | Mode | Lower\_95% | Upper\_95% |   SD | MCMCerr |   AC10 |      ESS | cpt | nyears | width | width\_ratio | modal\_estimate | seg\_before | seg\_after | dissimilarity | overall\_r2 | species\_mean\_r2 |
| -: | --------: | ---: | --: | -----------: | ---------: | :------------------ | ------: | -----: | ---: | ---------: | ---------: | ---: | ------: | -----: | -------: | :-- | -----: | ----: | -----------: | --------------: | ----------: | ---------: | ------------: | ----------: | ----------------: |
| 2 |        10 |    2 | 100 |    \-1902.45 |   524.4792 | winter\_CC\_annuals | 1994.94 |   1995 | 1993 |       1990 |       1999 | 2.44 |  0.0772 | 0.0582 | 269.0895 | 1   |     26 |     9 |    0.3461538 |            1993 |           1 |          2 |     0.3554668 |   0.3635679 |         0.2422645 |
| 2 |        10 |    2 | 100 |    \-1902.45 |   524.4792 | winter\_CC\_annuals | 2004.98 |   2003 | 1997 |       1994 |       2017 | 7.29 |  0.2305 | 0.0188 | 278.4256 | 2   |     26 |    23 |    0.8846154 |            1996 |           2 |          3 |     0.3950211 |   0.3635679 |         0.2422645 |

</div>

![](plants_explore_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->![](plants_explore_files/figure-gfm/unnamed-chunk-3-2.png)<!-- -->

## summer

    ## Joining, by = "year"

    ## Joining, by = "cpt"

    ## Joining, by = "year"

    ## Joining, by = c("year", "species")

<div class="kable-table">

| k | lda\_seed | cpts | nit | mean\_loglik | se\_loglik | dat\_name           | Mean | Median | Mode | Lower\_95. | Upper\_95. | SD | MCMCerr | AC10 | ESS | cpt | nyears | width | width\_ratio | modal\_estimate | seg\_before | seg\_after | dissimilarity | overall\_r2 | species\_mean\_r2 |
| -: | --------: | ---: | --: | -----------: | ---------: | :------------------ | :--- | :----- | :--- | :--------- | :--------- | :- | :------ | :--- | --: | :-- | -----: | :---- | :----------- | :-------------- | :---------- | :--------- | :------------ | ----------: | ----------------: |
| 2 |         2 |    0 | 100 |   \-3151.713 |   1201.655 | summer\_CC\_annuals | NA   | NA     | NA   | NA         | NA         | NA | NA      | NA   |   0 | NA  |     25 | NA    | NA           | NA              | NA          | NA         | NA            |   0.2460731 |         0.3089993 |

</div>

![](plants_explore_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->![](plants_explore_files/figure-gfm/unnamed-chunk-4-2.png)<!-- -->
