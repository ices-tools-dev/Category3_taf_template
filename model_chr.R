## Run analysis, write model results

## Before: catch.csv, index.csv, length.csv (data/)
## After: model.RData (model/) — A, i, b, lc, lmean, lref, f, lref_dummy,
##        f_dummy, hr, HR_target, m, chr_advice

library(TAF)
library(cat3advice)

mkdir("model")

### ----------------------------------------------------------------------
### Stock-specific settings
### ----------------------------------------------------------------------

catch_units <- "tonnes"
index_units <- "kg per hour per m beam width"


Itrigger <- 1.04

### length-at-first-capture pooling window (for Lc).
# lc_pool_years <- NULL  ### e.g. 2019:2023
lc_pool_years <- 2016:2021


lc_lstep      <- NULL  ### e.g. 20, if noisy; leave NULL otherwise

lref_Lc <- 264
Linf    <- 585
discard_rate <- 32.0 # note: percentage (32%), not proportion (0.32)!


### ----------------------------------------------------------------------
### Read data
### ----------------------------------------------------------------------

catch  <- read.taf("data/catch.csv")
index  <- read.taf("data/idx.csv")
length <- read.taf("data/length.csv")

### ----------------------------------------------------------------------
### chr rule components
### ----------------------------------------------------------------------

A <- A(catch, units = catch_units)
A

### most recent biomass index value (chr uses I directly, not the r ratio)
i <- I(index, units = index_units)
i

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

### length indicator — for chr this is used only to identify reference
### years for the target harvest rate below, not as a multiplicative
### term in the final advice calculation
f <- f(Lmean = lmean, Lref = lref, units = "mm")
f

### ----------------------------------------------------------------------
### target harvest rate HRMSYproxy
### ----------------------------------------------------------------------
### This should be calculated once, in the first year of application of
### the chr rule to this stock, from historical catch and index data. In
### subsequent years, the same value should be reused rather than
### recalculated. Per the cat3advice reference manual, F() supports this
### directly via F(hr, yr_ref = c(...)) — pass the previously-established
### reference years instead of recomputing them from f each time.

### combine catch and index data into a single data.frame
df <- merge(catch, index, all = TRUE)

### historical harvest rate (catch / biomass index)
hr <- HR(df, units_catch = catch_units, units_index = index_units)
hr

# F() selects reference years as those where indicator f > 1. With the
# properly-derived Lref above (344.25mm, from Lc = 264, Linf = 585), no
# year in this demo length dataset clears that bar (checked via
# indicator(f) — max value 0.987 in 2019), so F(hr, f) errors with
# "All indicator values are <1. Impossible to select reference years!"

# The cat3advice vignette chr example runs into the same issue with
# this dataset and works around it by substituting a dummy Lref of
# 330mm purely so the reference-year search has candidates. We do the
# same here, ONLY so this template runs end-to-end on demo data.

# For your stock, do not substitute a dummy Lref to force reference
# years to appear. If no year clears the F=M proxy, that is a genuine
# result requiring your judgement — investigate your data or
# use the documented yr_ref override (F(hr, yr_ref = c(...))) with a
# defensible and justified chosen set of years instead.

lref_dummy <- Lref(330, units = "mm")
f_dummy <- f(Lmean = lmean, Lref = lref_dummy, units = "mm")

### target harvest rate: average harvest rate in years where f_dummy > 1
HR_target <- F(hr, f_dummy)
HR_target

### ----------------------------------------------------------------------
### multiplier
### ----------------------------------------------------------------------
### chr's multiplier is fixed (m = 0.5 by default)
m <- m(hcr = "chr")
m

### ----------------------------------------------------------------------
### apply chr rule — combine elements
### ----------------------------------------------------------------------
### includes consideration of stability clause

chr_advice <- chr(A = A, I = i, F = HR_target, b = b, m = m,
                   discard_rate = discard_rate)
chr_advice

### ----------------------------------------------------------------------
### Save model objects
### ----------------------------------------------------------------------

save(A, i, b, lc, lmean, lref, f, lref_dummy, f_dummy, hr, HR_target, m,
     chr_advice, file = "model/model_chr.RData")
