
## Before: model.RData (model/)
## After: chr_advice_table.csv (output/) — table of key chr rule values

library(TAF)
library(cat3advice)
library(icesAdvice)

mkdir("output")

load("model/model_chr.RData")


advice(chr_advice)  ### console display, matches ICES advice sheet format

chr_advice_table <- data.frame( ### build a longer form version and round
  parameter = c(
    "Years",
    "Previous advice",
    "I",
    "HRMSYproxy",
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
    paste(chr_advice@years, collapse = "-"),
    round(chr_advice@A@value),
    icesRound(chr_advice@I@value),
    round(chr_advice@F@value),
    icesRound(chr_advice@b@value),
    icesRound(chr_advice@m@value),
    round(chr_advice@advice_uncapped),
    chr_advice@cap,
    round(chr_advice@advice),
    round(chr_advice@advice_landings),
    icesRound(chr_advice@discard_rate),
    icesRound(chr_advice@change, percent = TRUE, sign = TRUE)
  )
)

write.taf(chr_advice_table, dir = "output")
