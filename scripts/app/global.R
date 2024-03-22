# ---------------------------------------------------------------------------- #
# Shiny App 
# Global File
# Bonitur Obstschädlinge
# ---------------------------------------------------------------------------- #

library(shiny)
library(bslib)
library(dplyr)

# Read in data
pests <- read.csv("https://obsty.nemundo.ch/schaedling/schaedling-csv", sep = ";")

# Emtpy data frame for results
bonitur_pests <- as.data.frame(matrix(nrow = 0, ncol = 7))
colnames(bonitur_pests) <- 
  c("bonitur_ID", "plot", "BBCH", "pest", "unit", "unit_ID", "pest_nr")

# Emtpy data frame for results
bonitur_n_units <- as.data.frame(matrix(nrow = 0, ncol = 5))
colnames(bonitur_n_units) <- 
  c("bonitur_ID", "plot", "BBCH", "unit", "nr_of_units_counted")
