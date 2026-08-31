## Run analysis, write model results

## Before: catch.csv, index.csv, length.csv (data/)
## After: model.RData (model/) — A, r, b, lc, lmean, lref, f, m, rfb_advice

library(TAF)
library(cat3advice)

mkdir("model")

### ----------------------------------------------------------------------
### Stock-specific settings
### ----------------------------------------------------------------------

catch_units <- "tonnes"
index_units <- "kg per hour per m beam width"



### Itrigger: leave NULL to calculate fresh on first application of the
### rule to this stock. On repeat applications, fix this to the previously
### established value and do not recalculate it.
### Itrigger <- NULL      
### e.g. 1.04, or NULL for first application

Itrigger <- 1.04

### length-at-first-capture pooling window (for Lc). If the length
### distribution looks noisy, widen the length classes via lc_lstep below
### rather than changing the pooling window.
# lc_pool_years <- NULL  ### e.g. 2019:2023
lc_pool_years <- 2016:2021


lc_lstep      <- NULL  ### e.g. 20, if noisy; leave NULL otherwise

### Lref: fixed once at first application, then reused on repeat
### applications the same way as Itrigger. Requires a single Lc value
### (not the pooled Lc time series computed below) and Linf.
# lref_Lc <- NULL   ### e.g. 264
# Linf    <- NULL   ### e.g. 585
# k             <- NULL  ### von Bertalanffy growth rate k, for multiplier m
# discard_rate  <- NULL  ### proportion, e.g. 0.34

lref_Lc <- 264
Linf    <- 585
k       <- 0.10
discard_rate <- 0.32


### ----------------------------------------------------------------------
### Read data
### ----------------------------------------------------------------------

catch  <- read.taf("data/catch.csv")
index  <- read.taf("data/idx.csv")
length <- read.taf("data/length.csv")

### ----------------------------------------------------------------------
### rfb rule components
### ----------------------------------------------------------------------

A <- A(catch, units = catch_units)
A

r <- r(index, units = index_units)
r

### first application (Itrigger == NULL) vs repeat application
b <- if (is.null(Itrigger)) {
  b(index, units = index_units)
} else {
  b(index, units = index_units, Itrigger = Itrigger)
}
b


### lstep has no default in Lc() — pass it only when set, rather than NULL
lc <- if (is.null(lc_lstep)) {
  Lc(length, pool = lc_pool_years)
} else {
  Lc(length, pool = lc_pool_years, lstep = lc_lstep)
}
lc



lmean <- Lmean(data = length, Lc = lc, units = "mm")
lmean

lref <- Lref(Lc = lref_Lc, Linf = Linf, units = "mm")
lref

f <- f(Lmean = lmean, Lref = lref, units = "mm")
f

### Note: the +20%/-30% stability clause is applied automatically inside
### rfb() and is conditional on b = 1 (turned off when b < 1) — if the
### clause doesn't appear in the advice table, check the value of b above
### before assuming something is wrong.

m <- m(hcr = "rfb", k = k)
m

rfb_advice <- rfb(A = A, r = r, f = f, b = b, m = m,
                   discard_rate = discard_rate)
rfb_advice

### ----------------------------------------------------------------------
### Save model objects
### ----------------------------------------------------------------------

save(A, r, b, lc, lmean, lref, f, m, rfb_advice, file = "model/model_rfb.RData")

