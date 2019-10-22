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
-   But the top models seem to be fairly comparable, given the spread in sum loglikelihoods based on parameter uncertainty (?)

### Best model (2 topics, 0 cpts, ~ 0)

![](bbsreport_files/figure-markdown_github/best%20lda-1.png)

![](bbsreport_files/figure-markdown_github/plot%20ts-1.png)

![](bbsreport_files/figure-markdown_github/generate%20species%20predictions-1.png)

### Best model with time (2 topics, 0 cpts, ~time)

![](bbsreport_files/figure-markdown_github/best%20lda%20with%20time-1.png)

![](bbsreport_files/figure-markdown_github/plot%20ts%20with%20time-1.png) ![](bbsreport_files/figure-markdown_github/generate%20species%20predictions%20with%20time-1.png)

### One with 11 topics (11 topics, 0 cpts, ~ 0)

![](bbsreport_files/figure-markdown_github/best%20lda%2011%20topics-1.png)

![](bbsreport_files/figure-markdown_github/plot%20ts%2011%20topics-1.png) ![](bbsreport_files/figure-markdown_github/generate%20species%20predictions%2011%20topics-1.png)
