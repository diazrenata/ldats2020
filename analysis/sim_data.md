Generating sim data
================
10/1/2019

Renata working through how to generate a sim dataset with specified characteristics.

``` r
nspp = 15
mean_nind = 200
ntimesteps = 30
ntopics = 2
nchangepoints = 0
```

``` r
set.seed(1977)

N <- floor(rnorm(n = ntimesteps,
                 mean = mean_nind,
                 sd = 50))

gen_beta <- function(nspp) {
  beta_sample <- sample(x = 1000, size = nspp, replace = T)
  beta_sample <- beta_sample / sum(beta_sample)
}

Beta <- replicate(n = ntopics, expr = gen_beta(nspp = nspp), simplify = T) %>%
  t()

X <- matrix(nrow = ntimesteps, ncol = 1, data = 1:ntimesteps)

Eta <- matrix(nrow = 1, ncol = ntopics, data = runif(n = ntopics, min = 0.0000001, max = 1.5))

rho <- NULL

tD <- 1:ntimesteps

err <- 0

seed <- 410
    
simData <- LDATS::sim_LDA_TS_data(N, Beta,X, Eta, rho, tD, err = 0)
```

``` r
source(here::here("fxns", "lda_wrapper.R"))

simDataList <- list(document_term_table = simData, document_covariate_table = data.frame(timestep = 1:ntimesteps))

simLDA <- LDA_TS(data = simDataList, topics = c(2, 3), nseeds = 2, formulas = c(~1), nchangepoints = c(0, 1, 2), timename = "timestep", control = list(nit = 100))
```

    ## ----Latent Dirichlet Allocation----

    ## Running LDA with 2 topics (seed 2)

    ## Running LDA with 2 topics (seed 4)

    ## Running LDA with 3 topics (seed 2)

    ## Running LDA with 3 topics (seed 4)

    ## ----Time Series Models----

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model k: 2, seed: 4

    ## Running TS model with 1 changepoints and equation gamma ~ 1 on LDA model k: 2, seed: 4

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

    ## Running TS model with 2 changepoints and equation gamma ~ 1 on LDA model k: 2, seed: 4

    ##   Estimating changepoint distribution

    ##   Estimating regressor distribution

``` r
plot(simLDA$`Selected LDA model`)
```

![](sim_data_files/figure-markdown_github/run%20lda%20ts%20on%20fit-1.png)

``` r
plot(simLDA$`Selected TS model`)
```

![](sim_data_files/figure-markdown_github/run%20lda%20ts%20on%20fit-2.png)
