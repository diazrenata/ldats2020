LDATS on Hartland
================

``` r
datasets <- build_bbs_datasets_plan()

h <- which(grepl(datasets$target, pattern = "rtrg_102_18")) # hartland

hartland <- eval(unlist(datasets$command[h][[1]]))
```

This community has a total of 93 species surveyed in 25 years from 1994
to 2018.

``` r
hartland_long <- hartland$abundance %>%
  mutate(year = hartland$covariates$year,
         totalannual = rowSums(hartland$abundance))  %>%
  tidyr::pivot_longer(c(-year, -totalannual),names_to = "species", values_to = "abundance") %>%
  mutate(propannual = abundance / totalannual)


ggplot(hartland_long, aes(year, propannual, color = species)) +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d() +
  theme(legend.position = "none")
```

![](hartland_files/figure-gfm/plot%20hartland-1.png)<!-- -->
