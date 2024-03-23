# ---------------------------------------------------------------------------- #
# Shiny App 
# Global File
# Bonitur Obstschädlinge
# ---------------------------------------------------------------------------- #

library(shiny)
library(bslib)
library(dplyr)
library(xml2)
library(DT)

# Function
source("scripts/PSM/master_psm.R")

source("scripts/damage_threshold/00_fun_damage_threshold.R")

# Read in data
pests <- read.csv("https://obsty.nemundo.ch/schaedling/schaedling-csv", sep = ";")
pests <- pests %>% filter(grepl("png|jpg", bild))

list_images_links <- apply(pests, 1, function(v) {
  HTML(paste0("<h3>", v[2], "</h3>", "<img src='", v[4], "'/>"))
})

# Emtpy data frame for results
bonitur_pests <- as.data.frame(matrix(nrow = 0, ncol = 8))
colnames(bonitur_pests) <- 
  c("bonitur_ID", "date", "plot", "BBCH", "pest", "unit", "unit_ID", "pest_nr")

# Emtpy data frame for results
bonitur_n_units <- as.data.frame(matrix(nrow = 0, ncol = 6))
colnames(bonitur_n_units) <- 
  c("bonitur_ID", "date", "plot", "BBCH", "unit", "nr_of_units_counted")

# Source function for history plot
source("scripts/history/make_history_data.R")
source("scripts/history/plot_one_bonitur.R")
