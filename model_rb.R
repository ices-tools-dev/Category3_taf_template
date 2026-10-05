## Run analysis, write model results

## Before: catch.csv, index.csv (data/)
## After: model.RData (model/) — A, r, b, m, rb_advice

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

discard_rate <- 32.0 # note: percentage (32%), not proportion (0.32)!

### ----------------------------------------------------------------------
### Read data
### ----------------------------------------------------------------------

catch <- read.taf("data/catch.csv")
index <- read.taf("data/idx.csv")

### ----------------------------------------------------------------------
### rb rule components
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

### Note: the +20%/-30% stability clause is applied automatically inside
### rb() and is conditional on b = 1 (turned off when b < 1) — if the
### clause doesn't appear in the advice table, check the value of b above
### before assuming something is wrong.

### rb's multiplier is fixed (m = 0.5 for all stocks) — unlike rfb, it
### does not depend on the von Bertalanffy k, so no k setting is needed here.
m <- m(hcr = "rb")
m

rb_advice <- rb(A = A, r = r, b = b, m = m,
                 discard_rate = discard_rate)
rb_advice

### ----------------------------------------------------------------------
### Save model objects
### ----------------------------------------------------------------------

save(A, r, b, m, rb_advice, file = "model/model_rb.RData")

