library(dplyr)

holes <- read.csv(here::here("analysis", "bbs_holes.csv"))

route_info <- read.csv(here::here("analysis", "routes.csv"))

no_holes <- filter(holes, n_missing == 0) %>%
  rename(StateNum = region,
         Route = route) %>%
  dplyr::left_join(route_info)

write.csv(no_holes, here::here("analysis", "no_holes.csv"))
