LDA behavior in odd situations
================
10/7/2019

Imagine a) no relationship amongst the different species, b) a fixed relationship amongst the species.

``` r
mean_nind = 200
nspp = 7
ntimesteps = 30
nchangepoints = 0
```

#### "Noisy" community

A lot probably depends on the assumptions about how to build the noisy community. First I'm going with each species' abundance at each timestep is `runif(0, 100)`. Next I might try giving each species a mean and sd.

``` r
set.seed(1977)

noisyAbund <- matrix(nrow = ntimesteps, ncol = nspp, data = floor(runif(ntimesteps * nspp, 0, 100)))
```

``` r
noisyAbund_toplot <- as.data.frame(noisyAbund)

noisyAbund_toplot <- noisyAbund_toplot %>%
  mutate(timestep = row_number(), 
         total_abundance = rowSums(noisyAbund_toplot)) %>%
  tidyr::gather(-timestep, -total_abundance, key = "species", value = "abundance") %>%
  mutate(rel_abund = abundance / total_abundance)


noisy_relabund_plot <- ggplot(data = noisyAbund_toplot, aes(x = timestep, y = rel_abund, color = species)) +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d(end = .8) +
  ggtitle("Relative abundances - noisy data")

noisy_relabund_plot
```

![](lda_edge_files/figure-markdown_github/plot%20sim%20data-1.png)

#### LDATS sim, 1 species == 1 topic

``` r
N <- floor(rnorm(n = ntimesteps,
                 mean = mean_nind,
                 sd = 50))

Beta <- matrix(nrow = nspp, ncol = nspp, data = 0)

for(i in 1:nspp) {
  for(j in 1:nspp) {
    if(i == j) {
      Beta[i, j] <- 1
    }
  }
}

X <- matrix(nrow = ntimesteps, ncol = 2, data = c(rep(1, ntimesteps), 1:ntimesteps))

Eta <- matrix(nrow = 2, ncol = nspp, data = runif(n =2* nspp, min = 0.0000001, max = 1.5))

rho <- NULL

tD <- 1:ntimesteps

err <- 0

seed <- 410
    
simData <- LDATS::sim_LDA_TS_data(N, Beta,X, Eta, rho, tD, err = 0, seed)

simData_toplot <- as.data.frame(simData)

simData_toplot <- simData_toplot %>%
  mutate(timestep = row_number(), 
         total_abundance = rowSums(simData_toplot)) %>%
  tidyr::gather(-timestep, -total_abundance, key = "species", value = "abundance") %>%
  mutate(rel_abund = abundance / total_abundance)


sim_relabund_plot <- ggplot(data = simData_toplot, aes(x = timestep, y = rel_abund, color = species)) +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d(end = .8) +
  ggtitle("Relative abundances - LDATS sim data")

sim_relabund_plot
```

![](lda_edge_files/figure-markdown_github/use%20LDATS%20sim-1.png)

#### "Fixed" relative abundances

``` r
fixed_props <- runif(n = nspp, 0, 100)

fixed_props <- fixed_props / sum(fixed_props)

fixedAbund <- matrix(nrow = ntimesteps, ncol = nspp, data  = fixed_props, byrow = TRUE)

mean_nind = 1000

N <- floor(rnorm(n = ntimesteps,
                 mean = mean_nind,
                 sd = 50))

for(i in 1:ntimesteps) {
fixedAbund[i, ] <- round(fixedAbund[i, ] * N[i])
  #fixedAbund[i, ] <- round(fixedAbund[i, ] * 200)
}

fixedAbund_toplot <- as.data.frame(fixedAbund)

fixedAbund_toplot <- fixedAbund_toplot %>%
  mutate(timestep = row_number(), 
         total_abundance = rowSums(fixedAbund_toplot)) %>%
  tidyr::gather(-timestep, -total_abundance, key = "species", value = "abundance") %>%
  mutate(rel_abund = abundance / total_abundance)


fixed_relabund_plot <- ggplot(data = fixedAbund_toplot, aes(x = timestep, y = rel_abund, color = species)) +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d(end = .8) +
  ggtitle("Relative abundances - fixed data")

fixed_relabund_plot
```

![](lda_edge_files/figure-markdown_github/fixed%20relative%20abundance%20data-1.png)

``` r
lda_fits <- lapply(dats, FUN = function(a_dat) return(LDATS::LDA_set(a_dat$document_term_table, topics = c(2:nspp), nseeds = 100, control = list(quiet = TRUE))))

lda_dat <- lapply(lda_fits, FUN = function(some_ldas)
  return(data.frame(
    seed = vapply(as.matrix(names(some_ldas)), FUN = function(one_lda_name)
      return(as.integer((unlist(strsplit(one_lda_name, split = "seed: ")[[1]][[2]]))
      )), FUN.VALUE = 2),
    k = vapply(some_ldas, FUN = function(one_lda)
      return(one_lda@k), FUN.VALUE = 2),
    sum_loglik = vapply(some_ldas, FUN = function(one_lda)
      return(sum(one_lda@loglikelihood)), FUN.VALUE = -100),
    AICc = vapply(some_ldas, FUN = LDATS::AICc, FUN.VALUE = 10)))
)

all_lda_dat <- bind_rows(lda_dat, .id = "dat_source") %>%
  mutate(k = as.factor(k))
```

``` r
lda_result_plot <- ggplot(data = all_lda_dat, aes(x = k, y = AICc, color = k)) +
  geom_boxplot() +
  theme_bw() +
  scale_color_viridis_d(end = .8) +
  facet_wrap(vars(dat_source), scales = "free", strip.position = "top") 

lda_result_plot
```

![](lda_edge_files/figure-markdown_github/plot%20LDA%20results-1.png)
