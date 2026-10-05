## Prepare plots and tables for report

## Before: model.RData (model/), chr_advice.csv (output/)
## After: i.png, b.png, f.png, lmean.png, hr.png, HR_target.png,
##        chr_advice.csv (report/)

library(TAF)
library(cat3advice)
library(officer)
library(flextable)



mkdir("report")

load("model/model_chr.RData")

### ----------------------------------------------------------------------
### Diagnostic plots
### ----------------------------------------------------------------------

### biomass index — most recent value used by chr
taf.png("i_chr")
print(plot(i))
dev.off()

### biomass safeguard (chr has no r component to combine this with)
taf.png("b_chr")
print(plot(b))
dev.off()

taf.png("f_chr")
print(plot(f))
dev.off()

taf.png("lmean_chr")
print(plot(f@Lmean))
dev.off()

### harvest rate history (catches, index, and derived harvest rate)
taf.png("hr_chr")
print(plot(hr))
dev.off()

### target harvest rate HRMSYproxy, with reference years highlighted
taf.png("HR_target_chr")
print(plot(HR_target))
dev.off()

### ----------------------------------------------------------------------
### Advice table
### ----------------------------------------------------------------------

chr_advice_table <- read.taf("output/chr_advice_table.csv")
write.taf(chr_advice_table, dir = "report")

ft <- flextable(chr_advice_table)
ft <- set_table_properties(ft, layout = "autofit", width = 1)

doc <- read_docx()
doc <- body_add_flextable(doc, ft)
print(doc, target = "report/advice_chr.docx")
