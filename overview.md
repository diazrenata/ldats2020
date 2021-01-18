Overview January 2021
================
Renata Diaz
18 January, 2021

  - [Overview](#overview)
      - [Usefulness of the approach](#usefulness-of-the-approach)
      - [Applied to BBS](#applied-to-bbs)
  - [Technical details](#technical-details)
      - [Details on model selection](#details-on-model-selection)
          - [Christensen/original LDATS](#christensenoriginal-ldats)
          - [Combined goodness of fit](#combined-goodness-of-fit)
          - [What I’m doing now - “Hybrid” (Crossval +
            AIC)](#what-im-doing-now---hybrid-crossval-aic)
  - [Sample results](#sample-results)
      - [What changepoints mean now](#what-changepoints-mean-now)
      - [What topics mean now](#what-topics-mean-now)

# Overview

## Usefulness of the approach

I am now thinking of LDATS as a tool for detecting & describing temporal
structure in timeseries of community composition. Community composition
may be relatively static over time, or might shift gradually or rapidly
between two or more states. A major challenge in detecting, let alone
explaining or predicting, such shifts relates to the high dimensionality
of most community data. The researcher has to choose whether to focus on
a few abundant or apparent species, use a dimensionality reduction
algorithm, or use a distance metric - neither of which approaches is
inherently suited to temporal community data. LDATS accomplishes
dimensionality reduction and temporal analysis, and (now) optimizes the
dimensionality reduction to facilitate accurate, but parsimonious,
description of specifically temporal dynamics.

## Applied to BBS

Applied to a large number of communities sampled with consistent
methodology (BBS), LDATS can tell us:

  - How common it is to have a) relatively little temporal structure,
    meaning static or temporally randomish dynamics, b) multiple states
    for the community over time
  - How many states is common
  - Potentially, how rapidly we tend to see these transitions occurring
  - If, as with Portal, we see periods of change coinciding with periods
    of low abundance
  - If there are patterns at regional or national scale in a) how many
    states occur and b) when the transitions occurred
      - e.g. has New England been static but the Southeast changed a
        bunch of times
      - or, was there a period of ubiuitous change from 1990-1995

Beyond the scope here, this method could also be useful combined with
other data streams & community-specific hypotheses to ask:

  - Which species are responsible for the change
  - What endogenous or exogenous factors coincide with periods of change

<!-- Specifically, a standard change-point model approach is intractable for community data because there are too many species to effectively model simultaneously. We use LDA to condense the full community abundance data into a set of 2-5ish topics that occur in varying proportions over time, and fit the changepoint model to the topic proportions. We explore varying numbers of changepoints - 0 changepoint corresponding to no strong temporal structure, 1 to there being a transition between two different states, 2 to there being 3 states, etc - and varying numbers of topics. We identify the combined changepoint and topic structure that achieves the best combination of model fit and parsimony.  -->

# Technical details

  - Following Christensen et al (and in a change from past years in
    MATSS-LDATS), we do not try to fit temporal dynamics - i.e. slope -
    within a time chunk. This is because fitting slopes allows the model
    to fit even very rapid, changepoint like dynamics within a single
    chunk. All models are fit as intercept-only within chunks. (`formula
    = response ~ 1`)
  - Also following C., we may be able to use the (un)certainty of the
    changepoint model’s estimates of when the changepoints occur to
    infer how rapidly or gradually a transition took place.
  - We proceed using the softmax transformation. **Juniper** - is this
    acceptable (even if not ideal)? My impression was that the softmax
    was most problematic when we were fitting slopes, but you’re the
    expert on these details.

## Details on model selection

### Christensen/original LDATS

I’m including this in case it is a helpful reminder. Feel free to skip\!

C. used a seuential approach.

  - First fit numerous LDAs with varying `k` (numbers of topics) and
    `seed` (important because the model fitting algorithm is sensitive
    to initial conditions; we use many seeds to get good coverage of the
    likelihood space).
  - Then, select the best-fitting LDA via AIC and carry only that model
    forward.
  - Take the `gammas` (topic proportions) from the best fitting LDA and
    fit numerous changepoint models with varying `ncpts` (numbers of
    changepoints).
  - Select the best-fitting TS model via AIC.

This worked beautifully at Portal, but when applied to BBS (and other
coarser/shorter timeseries)

  - The best-fitting LDA, via AIC, tends to have very high `k`.
  - The resulting topic proportions are super high dimensional and hard
    for the change point model to fit.
  - Think about this as, *we optimized the LDA piece at the very great
    expense of the TS piece*. Because we ultimately care more about the
    TS piece, this is not useful for our purposes.

### Combined goodness of fit

Because we want the *combination* of LDA and TS model that best capture
the dynamics, we move towards a combined or holistic approach to model
selection.

  - Run all possible combinations of `k`, `seed`, and `ncpts`.
  - For every model, calculate an overall goodness of fit.
      - Loglikelihood of observed actual abundances given predicted
        abundances (multinomial probabilities) from model.
      - This is done via LOO cross validation.
        <!-- * Every year takes its turn being the test yqear.  -->
        <!--  * Make training data by witholding the test year + a buffer.  -->
        <!--  * Run the specific model in uestion on the training data (`k`, `seed`, `ncpts`).  -->
        <!--  * Calculate the loglikelihood of the observed test data given the predicted abundances for the test year.  -->
        <!--  * Score the model's performance over all years by summing the loglikelihoods for every test year.  -->
        <!--  * (Done many times because Bayesian, and tried with a variety of LOO schemes) -->
  - Choose the whole-model - `k`, `seed`, `ncpts` - with the best
    loglikelihood

In practice, this approach tends to have tractable `k` but a lot of
uncertainty for, and often high, `ncpts`. That is, it effectively
penalizes overly complex LDAs, because these interfere with the TS
model’s ability to fit well. But there isn’t really a penalty for
extra changepoints, because there can be a changepoint with very little
change. Having many changepoints can thus result in a slight improvement
in fit and rarely results in a dramatic reduction in fit detectable via
crossvalidation.

We didn’t have this problem before, because when we select the TS via
AIC, we explicitly impose a penalty for extra parameters. So an extra
changepoint had to improve the fit enough to be “worth” the parameter
penalty. Using crossvalidation, the extra changepoint just has to not
make things a lot worse. Crossvalidation approaches assume the
extra-complexity penalty is built in via overfitting, and aren’t really
compatible with an explicit extra penalty for parameters.

### What I’m doing now - “Hybrid” (Crossval + AIC)

I want to effectively select the LDA using crossvalidation but select
the TS using AIC(c).

This is a little complex because 1) we can’t use AIC to compare TS
models fit on different LDAs, and 2) we need the TS fit before we can
perform crossvalidation. We can work around this by:

  - Use AIC to select the best-fitting TS **for each specific LDA
    model**. That is, are the topic proportions from the LDA model with
    2 topics and seed 100 best-described via a TS model with 0, 1, or 2
    changepoints?
  - Each LDA model is then combined with only its best-fitting TS model.
    So if `k = 2, seed = 100` was best fit by `ncpts = 1`, that is the
    only version of `k = 2, seed = 100` we consider further. We no
    longer entertain the possibility that `k = 2, seed = 100, ncpts
    = 3`.
  - For each specific LDA model, now combined with its TS model, get an
    overall goodness of fit using crossvalidation.
      - We therefore get crossvalidation scores for a bunch of models
        like this:
          - `k = 2, seed = 100, ncpts = 1`; `k = 3, seed = 20, ncpts
            = 0`; `k = 12, seed = 2, ncpts = 0`.
          - This effectively tells us whether a 2 topic LDA with 1
            changepoint is better at predicting withheld data than a 12
            topic LDA with 0 changepoints etc.
      - Choose the model with the best crossvalidation score.

I would not have done this if not for the string of issues discussed
above. It’s unconventional\! **Can I please ask technical folks** (it is
up to you whether you consider yourself technical folk or not\!), **do
we see major red flags?**

#### Detail on LDAs and crossvalidation

**I’d really appreciate technical perspectives on this, too\!**

I believe we have to do the training/test split on the LDA proportions
after they are fit (instead of on the data before it goes into the LDA).
This is unusual for crossvalidation, but justified, I think.

If you fit two LDAs to two different datasets, even with the same seed,
you can end up with very different topics and topic proportions. It’s
impossible to re-combine them into one LDA for the whole timeseries. Nor
is the LDA you get from fitting to the whole, unsubsetted, data really
reflective of the LDAs you got from every subset. This renders the
crossvalidation nonsensical.

Fitting the LDA first, and then subsetting, in principle results in some
data leakage. However, I think this would manifest as overfitting in the
LDA/sneaking around the crossvalidation. I’m not finding an obvious
issue with high `k` anymore. And, selecting `k` perfectly is less
important now than in the original formulation.

This is also always going to be a problem with LDA + crossvalidation.

# Sample results

## What changepoints mean now

The presence & number of changepoints tells us how many community states
the model is using to describe the data and when the system changed from
one state to another.

The presence of a changepoint means there was a transition, but not
necessarily a *rapid* one. The uncertainty around *when* the changepoint
occurred may reflect how rapid it was.

A transition probably doesn’t need to be a total overhaul of the
community/“regime shift” for the model to find a changepoint. It has to
be reasonably substantial and consistent, but just flagging that
transitions between states \!= regime shift.

## What topics mean now

In this application, the number of topics and the species composition of
the topics is less intuitively informative than in the Portal
application. Here, the topic structure doesn’t seem to be picking up on
“functional” community types with fine variation in their relative
proportions over time. Rather, we tend to see one topic corresponding to
the community state in one time period, and, if there is a transition to
another community state, another topic post-transition.

I think this is because of two related things. One, we have fewer time
samples, so less capacity to detect fine scale dynamics. Two, we
specifically look for the set of topics that allows the change point
model to achieve a good fit, which means the topics need to have
relatively simple temporal dynamics.
