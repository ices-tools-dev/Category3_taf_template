## Preprocess data, write data tables

## Before:
## After: catch.csv, index.csv, length.csv (data/)

library(TAF)
library(cat3advice)
library(dplyr)

mkdir("data")

### ----------------------------------------------------------------------
### Load raw stock data
### ----------------------------------------------------------------------
### Replace with your actual data

# data("ple7e_catch")
# year advice landings discards catch
# 1 1987     NA     2272       NA  2272
# 2 1988     NA     2835       NA  2835
# 3 1989     NA     2742       NA  2742
# ...

# data("ple7e_idx")
# year     index
# 1 2003 0.5047407
# 2 2004 0.7051944
# 3 2005 0.4998611
# ...

# data("ple7e_length")
# year             catch_category length numbers
# 1 2018                BMS landing    100    0.00
# 2 2018                   Discards    100 5887.55
# 3 2018 Logbook Registered Discard    100    0.00
# ...

catch <- read.taf("boot/data/advice_history.csv")
catch <- catch %>%
  select(year, advice = advice_catch_stock, discards = ICES_discards_stock,
         landings = ICES_landings_stock, catch = ICES_catch_stock)

### biomass index
idx <- read.taf("boot/data/idx.csv")

### catch length data 
length <- read.taf("boot/data/length_data.csv")

write.taf(catch, dir = "data")
write.taf(idx, dir = "data")
write.taf(length, dir = "data")

