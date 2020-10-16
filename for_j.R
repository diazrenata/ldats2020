library(LDATS)
load("portal_annual.RData")
lda <- LDATS::LDA_set(abund_dat$abundance, 2, 2)

ts <- TS_on_LDA(lda[[1]], as.data.frame(abund_dat$covariates), formulas = ~1, nchangepoints = 0, timename = "year", control = TS_control(nit = 100))

ts <- ts[[1]]

ts$etas

covars <- abund_dat$covariates$year

toy_theta <- function(ts, covars, sim) {
ncovar <- 1

nseg <- ifelse(is.null(ts$rhos), 1, ncol(ts$rhos) + 1)

ntopics <- ncol(ts$data$gamma)

ndocs <- length(covars)

X <- matrix(nrow = ndocs, ncol = ncovar, data = covars, byrow = FALSE)

model_Eta <- ts$etas[sim, ]

Eta_matrix <- matrix(nrow = ncovar  * nseg, ncol = ntopics,
                     data = c(rep(0, times = ncovar * nseg), model_Eta), byrow = FALSE)

rho = ts$rhos[sim,]

tD <- covars

Theta <- LDATS::sim_TS_data(X, Eta_matrix, rho, tD, err = 0)

return(Theta)
}

theta2 <- toy_theta(ts, covars, 2)
theta3 <- toy_theta(ts, covars, 3)
theta4 <- toy_theta(ts, covars, 4)

ts$etas[2,]
theta2[1,]

ts$etas[3,]
theta3[1,]

ts$etas[4,]
theta4[1,]

ts$lls


ts <- TS_on_LDA(lda[[1]], as.data.frame(abund_dat$covariates), formulas = ~1, nchangepoints = 1, timename = "year", control = TS_control(nit = 100))

ts <- ts[[1]]

ts$etas

covars <- abund_dat$covariates$year

theta2 <- toy_theta(ts, covars, 2)
theta3 <- toy_theta(ts, covars, 3)
theta4 <- toy_theta(ts, covars, 4)

ts$etas[2,]
theta2[1,]

ts$etas[3,]
theta3[1,]

ts$etas[4,]
theta4[1,]

ts$lls

plot(ts$rhos, ts$lls)
