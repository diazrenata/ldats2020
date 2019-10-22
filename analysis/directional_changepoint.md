Generating sim data
================
10/1/2019

Some ground parameters
----------------------

``` r
nspp <- 7
ntimesteps <- 30
mean_nind <- 200
err_prop <- .2
```

Directional change with a changepoint
-------------------------------------

![](directional_changepoint_files/figure-markdown_github/directional%20changepoint-1.png)

Results
-------

### Directional + changepoint

![](directional_changepoint_files/figure-markdown_github/plot%20directional%20changepoint-1.png)

![](directional_changepoint_files/figure-markdown_github/plot%20dc%20means-1.png)

![](directional_changepoint_files/figure-markdown_github/best-1.png)

The best model looks like it's 0 changepoints, 2 topics, ~timestep.

Looking at it:

![](directional_changepoint_files/figure-markdown_github/best%20lda-1.png)

LOL.

It has effectively modeled a changepoint *without modeling a changepoint* by saying there's one topic pre changepoint and another post.

![](directional_changepoint_files/figure-markdown_github/plot%20ts-1.png) ![](directional_changepoint_files/figure-markdown_github/generate%20species%20predictions-1.png)
