## Prepare plots and tables for report

## Before: model.RData (model/), rfb_advice.csv (output/)
## After: r_b.png, f.png, lmean.png, rfb_advice.csv (report/)

library(TAF)
library(cat3advice)
library(officer)
library(flextable)



mkdir("report")

load("model/model_rfb.RData")

### ----------------------------------------------------------------------
### Diagnostic plots
### ----------------------------------------------------------------------

taf.png("r_b_rfb")
plot(r, b)
dev.off()

taf.png("f_rfb")
plot(f)
dev.off()

taf.png("lmean_rfb")
plot(lmean)
dev.off()

### ----------------------------------------------------------------------
### Advice table
### ----------------------------------------------------------------------

rfb_advice_table <- read.taf("output/rfb_advice_table.csv")
write.taf(rfb_advice_table, dir = "report")

ft <- flextable(rfb_advice_table)
ft <- set_table_properties(ft, layout = "autofit", width = 1)

doc <- read_docx()
doc <- body_add_flextable(doc, ft)
print(doc, target = "report/advice_rfb.docx")
