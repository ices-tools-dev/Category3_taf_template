## Prepare plots and tables for report

## Before: model.RData (model/), rb_advice.csv (output/)
## After: r_b.png, rb_advice.csv (report/)

library(TAF)
library(cat3advice)
library(officer)
library(flextable)



mkdir("report")

load("model/model_rb.RData")

### ----------------------------------------------------------------------
### Diagnostic plots
### ----------------------------------------------------------------------

taf.png("r_b_rb")
print(plot(r, b))
dev.off()

### ----------------------------------------------------------------------
### Advice table
### ----------------------------------------------------------------------

rb_advice_table <- read.taf("output/rb_advice_table.csv")
write.taf(rb_advice_table, dir = "report")

ft <- flextable(rb_advice_table)
ft <- set_table_properties(ft, layout = "autofit", width = 1)

doc <- read_docx()
doc <- body_add_flextable(doc, ft)
print(doc, target = "report/advice_rb.docx")
