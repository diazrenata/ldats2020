Generating sim data
================
10/1/2019

Renata working through how to generate a sim dataset with specified characteristics.

``` r
nspp = 5
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

X <- matrix(nrow = ntimesteps, ncol = 2, data = c(rep(1, ntimesteps), 1:ntimesteps))

Eta <- matrix(nrow = 2, ncol = ntopics, data = runif(n =2* ntopics, min = 0.0000001, max = 1.5))

rho <- NULL

tD <- 1:ntimesteps

err <- 0

seed <- 410
    
simData <- LDATS::sim_LDA_TS_data(N, Beta,X, Eta, rho, tD, err = 0, seed)
```

``` r
simdat_toplot <- as.data.frame(simData)

simdat_toplot <- simdat_toplot %>%
  mutate(timestep = row_number(), 
         total_abundance = rowSums(simdat_toplot)) %>%
  tidyr::gather(-timestep, -total_abundance, key = "species", value = "abundance") %>%
  mutate(rel_abund = abundance / total_abundance)


relabund_plot <- ggplot(data = simdat_toplot, aes(x = timestep, y = rel_abund, color = species)) +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d(end = .8)

relabund_plot
```

![](sim_data_files/figure-markdown_github/plot%20sim%20data-1.png)

``` r
topics_dat <- as.data.frame(Beta) %>%
  mutate(topic = row_number()) %>%
  tidyr::gather(-topic, key = "species", value = "proportion") %>%
  mutate(source = "simulated")

topics_plot <- ggplot(data = topics_dat, aes(x = species, y = proportion, fill = species)) +
  geom_col() +
  facet_grid(cols = vars(topic)) +
  theme_bw() +
  scale_fill_viridis_d(end = .8)

#topics_plot
```

``` r
source(here::here("fxns", "lda_wrapper.R"))

simDataList <- list(document_term_table = simData, document_covariate_table = data.frame(timestep = 1:ntimesteps))

simLDA <- LDA_TS(data = simDataList, topics = c(2, 3), nseeds = 50, formulas = c(~1, ~timestep), nchangepoints = c(0, 1, 2), timename = "timestep", control = list(nit = 1000, quiet = TRUE))

lda_beta <- simLDA$`Selected LDA model`[[1]]@beta %>%
  exp() %>%
  as.data.frame() %>%
  mutate(topic = row_number()) %>%
  tidyr::gather(-topic, key = "species", value = "proportion") %>%
  mutate(source = "model") %>%
  bind_rows(topics_dat)

all_topics_plot <-  ggplot(data = lda_beta, aes(x = species, y = proportion, fill = species)) +
  geom_col() +
  facet_grid(cols = vars(topic), rows = vars(source), switch = "y") +
  theme_bw() +
  scale_fill_viridis_d(end = .8)

all_topics_plot
```

![](sim_data_files/figure-markdown_github/run%20lda%20ts%20on%20fit-1.png)

``` r
sim_theta <- sim_TS_data(X, Eta, rho, err = 0, tD, seed) %>%
  as.data.frame %>%
  mutate(timestep = row_number()) %>%
  tidyr::gather(-timestep, key = "topic", value = "relabund") %>%
  mutate(source = "simulated")

ts_theta <- get_theta(simLDA$`Selected TS model`) %>%
  as.data.frame %>%
  mutate(timestep = row_number()) %>%
  tidyr::gather(-timestep, key = "topic", value = "relabund") %>%
  mutate(source = "model") %>%
  bind_rows(sim_theta)

ts_plot <- ggplot(data = ts_theta, aes(x = timestep, y = relabund, color = topic)) +
  geom_line() +
  theme_bw() +
  facet_grid(rows = vars(source), switch = "y") +
  scale_color_viridis_d(option = "magma", begin = .2, end = .8)

ts_plot
```

![](sim_data_files/figure-markdown_github/lda%20topics%20over%20ts-1.png)
