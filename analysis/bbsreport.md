Composite LL
================

Premise
-------

Returning to the issue we were having with the LDA in weecology/MATSS-LDATS: selecting the LDA and TS models sequentially allows the LDA to over-fit and choose a ridiculously large number of topics, which the TS model then fits as just the mean for everyone for the entire timeseries. This issue was what initially prompted us to develop the overall-likelihood and then the leave-one-out crossvalidation pipelines in this repo.

Here I am using one of the (many) datasets that had the many-topics problem with the sequential selection method, to see if the leave-one-out method reduces the number of LDA topics and improves the TS model's ability to describe dynamics.

Raw timeseries data
-------------------

![](bbsreport_files/figure-markdown_github/load%20and%20plot%20actual%20ts%20data-1.png)

Models
------

-   3 seeds
-   0 or 1 changepoint
-   2, 3, 4, 7, 11 topics
-   ~1 or ~year
-   1000 iterations

![](bbsreport_files/figure-markdown_github/load%20composite%20ll-1.png)![](bbsreport_files/figure-markdown_github/load%20composite%20ll-2.png)![](bbsreport_files/figure-markdown_github/load%20composite%20ll-3.png)

-   The changepoint models are consistently worse than the no changepoint models
-   11 topics isn't *terrible*, but 2 topics wins based on the mean sum loglikelihood
-   But even the top 20 (of 60!) models seem to be fairly comparable, given the spread in sum loglikelihoods based on parameter uncertainty (?)

<!-- -->

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model k: 2, seed: 2

![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-1.png)![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-2.png)

    ## Running LDA with 2 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ timestep on LDA model k: 2, seed: 2

![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-3.png)![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-4.png)

    ## Running LDA with 3 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model k: 3, seed: 2

![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-5.png)![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-6.png)

    ## Running LDA with 11 topics (seed 2)

    ## Running TS model with 0 changepoints and equation gamma ~ 1 on LDA model k: 11, seed: 2

![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-7.png)![](bbsreport_files/figure-markdown_github/2%203%2011%20topic%20LDAS-8.png)
