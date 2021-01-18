Classic January 2021
================
Renata Diaz
18 January, 2021

As an example, working with this BBS dataset (`rtrg_1_11`):

![](orig_results_files/figure-gfm/plot%20bbs%20data-1.png)<!-- -->
\#\#\# Classic LDATS

Initially, LDATs was set up to select a combination of an LDA and a TS
model sequentially using AIC(c). First we fit many LDA models with a
variety of `k` and `seed`, and select the best-fitting LDA model based
on AIC. Then we use the topic proportions (`gamma`) from that model to
fit several TS models with a variety of `nchangepoints` and `formula`.
We select the best TS model based on AIC(c).

``` r
classic_LDAs <- LDATS::LDA_set(bbs_rtrg_1_11$abundance, topics = c(2,3,5,6,9,11,13,15), nseeds = 1)
```

    ## Running LDA with 2 topics (seed 2)

    ## Running LDA with 3 topics (seed 2)

    ## Running LDA with 5 topics (seed 2)

    ## Running LDA with 6 topics (seed 2)

    ## Running LDA with 9 topics (seed 2)

    ## Running LDA with 11 topics (seed 2)

    ## Running LDA with 13 topics (seed 2)

    ## Running LDA with 15 topics (seed 2)

``` r
classic_LDA_select <- LDATS::select_LDA(classic_LDAs)

plot_lda_comp(classic_LDA_select)
```

![](orig_results_files/figure-gfm/classic%20LDATs%20LDAs-1.png)<!-- -->

``` r
plot_lda_year(classic_LDA_select, bbs_rtrg_1_11$covariates$year)
```

![](orig_results_files/figure-gfm/classic%20LDATs%20LDAs-2.png)<!-- -->

Right away this illustrates an issue, which we did not have with Portal.
The best-fitting LDA, using AIC, has **eleven** topics. This is
dimensionality reduction from \>80 species, which is what we start with
in this dataset, but is still not intuitive. Also, as is evident from
the plot of the gammas over time, the topics behave idiosyncratically
over time and several topics appear to be precisely fit to one or a few
time steps. These are **very complicated** temporal dynamics, and it’s
going to be hard for a changepoint model to distill any kind of pattern
out of them:

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model k: 11, seed: 2

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model k: 11, seed: 2

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model k: 11, seed: 2

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running TS model with 3 changepoints and equation gamma ~ 1 on LDA model k: 11, seed: 2

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

![](orig_results_files/figure-gfm/classic%20LDATs%20TS-1.png)<!-- -->
