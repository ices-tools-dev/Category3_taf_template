# ICES Category 3 Assessment Tamplates

A repository of worked R examples for ICES category 3 (data-limited) fish
stock assessments, structured as an [ICES Transparent Assessment Framework 
(TAF)](https://github.com/ices-taf/doc/wiki) analysis. 

The advice rule calculations themselves are done by
[`cat3advice`](https://github.com/shfischer/cat3advice), which implements
the ICES *rfb*, *rb*, and *chr* harvest control rules. This repository does not
reimplement any of that logic - it implements `cat3advice` using the standard
TAF data/model/output/report pipeline, and adds a few quality-of-life
features - a long-format advice table, ICES rounding, a Word export - on top.

## Repository structure

This repo follows the standard four-stage TAF pipeline. Each of the four
top-level scripts is a thin dispatcher that sources the script for the
assessment method being applied to a given stock:
  
  ```
data.R    -->  data_rfb.R, data_rb.R, data_chr.R
model.R   -->  model_rfb.R, model_rb.R, model_chr.R
output.R  -->  output_rfb.R, output_rb.R, output_chr.R
report.R  -->  report_rfb.R, report_rb.R, report_chr.R
```

To switch which method a stock uses, edit the relevant dispatcher (e.g.
`model.R`) and uncomment the `source()` line for the method in use, commenting out the others.

```
ices_cat_3_template/
  ├── boot/
  │   ├── DATA.bib              # metadata for raw data files
│   └── initial/data/           # raw data files (real, or demo — see below)
├── data.R, data_rfb.R
├── model.R, model_rfb.R
├── output.R, output_rfb.R
├── report.R, report_rfb.R
├── data/                       # created by data.R — cleaned data tables
  ├── model/                    # created by model.R — saved rule objects
  ├── output/                   # created by output.R — advice table
  └── report/                   # created by report.R — plots, tables, docx
  ```

The `data/`, `model/`, `output/`, and `report/` directories are generated
by running the pipeline — they aren't stored in version control.
 
## Requirements
 
- R (version 4.5.2)
- [TAF](https://cran.r-project.org/package=TAF)
- [`cat3advice`](https://github.com/shfischer/cat3advice), from the ICES
  r-universe:
```r
  install.packages("cat3advice",
    repos = c("https://ices-tools-prod.r-universe.dev",
              "https://cloud.r-project.org"))
```
- `dplyr`
- [`icesAdvice`](https://cran.r-project.org/package=icesAdvice) (for
  `icesRound()`, used to apply ICES rounding rules to the output table)
- `officer` and `flextable` (only if exporting the advice table to Word)
## Running the demo 

The pipeline can be run end-to-end against `cat3advice`'s built-in
plaice (`ple.27.7e`) example dataset.

Run this once, to populate `boot/initial/data/` with the demo files:
  
  ```r
library(TAF)
library(cat3advice)

mkdir("boot/initial/data")

data(ple7e_catch)
data(ple7e_idx)
data(ple7e_length)

advice_history <- ple7e_catch
names(advice_history) <- c("year", "advice_catch_stock", "ICES_landings_stock",
                           "ICES_discards_stock", "ICES_catch_stock")

write.taf(advice_history, dir = "boot/initial/data")

idx <- ple7e_idx
length_data <- ple7e_length

write.taf(idx, dir = "boot/initial/data")
write.taf(length_data, dir = "boot/initial/data")
```

Then create the data.BIB file, and save it to the 'boot' directory.

```
 
data_bib <- c(
  '@Misc{advice_history.csv,',
  '  originator = {cat3advice},',
  '  year       = {2026},',
  '  title      = {Demo catch and advice history -- plaice (ple.27.7e)',
  '                example data from the cat3advice package.},',
  '  period     = {1987-2022},',
  '  access     = {Public},',
  '  source     = {file},',
  '}',
  '',
  '@Misc{idx.csv,',
  '  originator = {cat3advice},',
  '  year       = {2026},',
  '  title      = {Demo biomass index -- plaice (ple.27.7e) example data',
  '                from the cat3advice package.},',
  '  period     = {2003-2021},',
  '  access     = {Public},',
  '  source     = {file},',
  '}',
  '',
  '@Misc{length_data.csv,',
  '  originator = {cat3advice},',
  '  year       = {2026},',
  '  title      = {Demo catch length data -- plaice (ple.27.7e) example',
  '                data from the cat3advice package.},',
  '  access     = {Public},',
  '  source     = {file},',
  '}'
)
 
writeLines(data_bib, "boot/DATA.bib")

```


Then run the pipeline:
  
  ```r
library(TAF)
taf.boot()
source.all()
```

The first block of code writes the example catch, index, and length data
into `boot/initial/data/`, with matching entries already present in
`boot/DATA.bib` (`source = "file"`) — the same mechanism used for real
data.

## Applying this to a real stock
 
1. Place your stock's raw data files directly in `boot/initial/data/`.
2. Add an entry to `boot/DATA.bib` for each raw file, following the
existing demo entries as a format example (`source = "file"`,
                                           originator, year, title, access, and — where relevant — the period
                                           covered).
3. Confirm column names and units before running anything. The
templates deliberately leave data-loading and renaming steps marked
with `TODO` comments rather than guessing at a real stock's schema —
   fill these in explicitly; don't assume they match the demo or the
`cat3advice` vignette's example data.
4. Confirm rule settings in `model_rfb.R` (or equivalent): index and
   catch units, `Itrigger` (first vs. repeat application), the `Lc`
   pooling window, `Linf`, `Lref`, the von Bertalanffy `k`, and the
   discard rate — the last of which is a **percentage** (e.g. `26.72`),
   not a proportion e.g. (`0.2672`).
5. Run `taf.boot()` then `source.all()` as in the demo.
## Currently implemented methods
 
| Method | Status |
|--------|--------|
| rfb    | Implemented (`data_rfb.R`, `model_rfb.R`, `output_rfb.R`, `report_rfb.R`) |
| rb     | Implemented (`data_rb.R`, `model_rb.R`, `output_rb.R`, `report_rb.R`) |
| chr    | Implemented (`data_chr.R`, `model_chr.R`, `output_chr.R`, `report_chr.R`) |
 

## Output table and rounding
 
`output_....R` builds a long-format (`parameter`/`value`) advice table
from the object's own slots, since `cat3advice::advice()` only
prints a formatted console table and does not return one. Rounding
follows the ICES Advice Technical Guidelines via `icesAdvice::icesRound()`
for ratios, multipliers, and percentages (`r`, `f`, `b`, `m`,
                                          `discard_rate`, `pct_change`); catch quantities (`previous_advice`,
                                                                                           `advice_uncapped`, `advice`, `advice_landings`) use plain `round()`
instead, per `icesRound()`'s own documented guidance not to apply ICES
rounding to catch, biomass, or count quantities.
 
## Notes for assessors adapting these templates
 
