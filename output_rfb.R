
## Before: model.RData (model/)
## After: rfb_advice_table.csv (output/) — table of key rfb rule values

library(TAF)
library(cat3advice)
library(icesAdvice)

mkdir("output")

load("model/model_rfb.RData")


advice(rfb_advice)  ### console display, matches ICES advice sheet format

rfb_advice_table <- data.frame( ### build a longer form version and round
  parameter = c(
    "Years",
    "Previous advice",
    "r",
    "f",
    "b",
    "m",
    "Advice (uncapped)",
    "Stability Applied",
    "Advice",
    "Advised Landings",
    "Discard rate",
    "Percentage change"
  ),
  value = c(
    paste(rfb_advice@years, collapse = "-"),
    round(rfb_advice@A@value),
    icesRound(rfb_advice@r@value),
    icesRound(rfb_advice@f@value),
    icesRound(rfb_advice@b@value),
    icesRound(rfb_advice@m@value),
    round(rfb_advice@advice_uncapped),
    rfb_advice@cap,
    round(rfb_advice@advice),
    round(rfb_advice@advice_landings),
    icesRound(rfb_advice@discard_rate),
    icesRound(rfb_advice@change, percent = TRUE, sign = TRUE)
  )
)

write.taf(rfb_advice_table, dir = "output")
