Portal rats + Hartland birds
================
Renata Diaz
2021-05-28

  - [Specs](#specs)
  - [BBS](#bbs)
  - [Portal](#portal)

## Specs

``` r
 ldats_fit = target(fit_ldats_crossval(dataset, buffer = 2, k = ks, lda_seed = seeds, cpts = cpts, nit = 100),
                       transform = cross(
                         dataset = !!rlang::syms(datasets$target),
                         ks = !!c(0,2:3),
                         seeds = !!seq(2, 10, by = 2),
                         cpts = !!c(0:4),
                         return_full = F,
                         return_fits = F,
                         summarize_ll = F
                       ))
)
```

    ## Joining, by = "dat_name"

![](portal_hartland_explore_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

## BBS

    ## Joining, by = "year"

    ## Joining, by = "cpt"

    ## Joining, by = "year"

    ## Joining, by = c("year", "species")

<div class="kable-table">

| k | lda\_seed | cpts | nit | mean\_loglik | se\_loglik | dat\_name          |    Mean | Median | Mode | Lower\_95% | Upper\_95% |   SD | MCMCerr |     AC10 |      ESS | cpt | nyears | width | width\_ratio | modal\_estimate | seg\_before | seg\_after | dissimilarity | overall\_r2 | species\_mean\_r2 |
| -: | --------: | ---: | --: | -----------: | ---------: | :----------------- | ------: | -----: | ---: | ---------: | ---------: | ---: | ------: | -------: | -------: | :-- | -----: | ----: | -----------: | --------------: | ----------: | ---------: | ------------: | ----------: | ----------------: |
| 2 |         6 |    3 | 100 |   \-156.7372 |    2.37215 | bbs\_rtrg\_102\_18 | 1999.59 |   1999 | 1995 |       1995 |       2006 | 3.51 |  0.1110 | \-0.0276 | 289.0591 | 1   |     25 |    11 |         0.44 |            2002 |           1 |          2 |     0.1326849 |   0.9138292 |         0.8895563 |
| 2 |         6 |    3 | 100 |   \-156.7372 |    2.37215 | bbs\_rtrg\_102\_18 | 2005.55 |   2006 | 2006 |       1998 |       2013 | 4.14 |  0.1309 |   0.0708 | 195.7750 | 2   |     25 |    15 |         0.60 |            2013 |           2 |          3 |     0.0872044 |   0.9138292 |         0.8895563 |
| 2 |         6 |    3 | 100 |   \-156.7372 |    2.37215 | bbs\_rtrg\_102\_18 | 2011.60 |   2012 | 2015 |       2004 |       2017 | 3.86 |  0.1221 |   0.1061 | 168.8860 | 3   |     25 |    13 |         0.52 |            2015 |           3 |          4 |     0.0083822 |   0.9138292 |         0.8895563 |

</div>

![](portal_hartland_explore_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->![](portal_hartland_explore_files/figure-gfm/unnamed-chunk-3-2.png)<!-- -->

## Portal

    ## Joining, by = "year"

    ## Joining, by = "cpt"

    ## Joining, by = "year"

    ## Joining, by = c("year", "species")

<div class="kable-table">

| k | lda\_seed | cpts | nit | mean\_loglik | se\_loglik | dat\_name        |    Mean | Median | Mode | Lower\_95% | Upper\_95% |   SD | MCMCerr |   AC10 |      ESS | cpt | nyears | width | width\_ratio | modal\_estimate | seg\_before | seg\_after | dissimilarity | overall\_r2 | species\_mean\_r2 |
| -: | --------: | ---: | --: | -----------: | ---------: | :--------------- | ------: | -----: | ---: | ---------: | ---------: | ---: | ------: | -----: | -------: | :-- | -----: | ----: | -----------: | --------------: | ----------: | ---------: | ------------: | ----------: | ----------------: |
| 2 |         4 |    1 | 100 |   \-207.0134 |   17.37574 | control\_rodents | 1996.58 |   1997 | 1997 |       1993 |       1999 | 1.81 |  0.0572 | 0.0465 | 553.4217 | 1   |     40 |     6 |         0.15 |            1997 |           1 |          2 |      0.400603 |     0.82522 |         0.7036599 |

</div>

![](portal_hartland_explore_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->![](portal_hartland_explore_files/figure-gfm/unnamed-chunk-4-2.png)<!-- -->
