
## Before: model.RData (model/)
## After: rb_advice_table.csv (output/) — table of key rb rule values

library(TAF)
library(cat3advice)
library(icesAdvice)

mkdir("output")

load("model/model_rb.RData")


advice(rb_advice)  ### creates a console display which matches ICES advice sheet format


rb_advice_table <- data.frame( ### build a longer form version for outputting and rounds
  parameter = c(
    "Years",
    "Previous advice",
    "r",
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
    paste(rb_advice@years, collapse = "-"),
    round(rb_advice@A@value),
    icesRound(rb_advice@r@value),
    icesRound(rb_advice@b@value),
    icesRound(rb_advice@m@value),
    round(rb_advice@advice_uncapped),
    rb_advice@cap,
    round(rb_advice@advice),
    round(rb_advice@advice_landings),
    icesRound(rb_advice@discard_rate),
    icesRound(rb_advice@change, percent = TRUE, sign = TRUE)
  )
)

write.taf(rb_advice_table, dir = "output")
