#' ---
#' project: OFHD24    #####################################################
#' title:   Bonitur data aggregation
#' author:  Reto Zihlmann <retozihlmann@outlook.com>
#' date:    2024-03-22 19:45:37
#' output:  github_document   #############################################
#' ---


# Packages ----------------------------------------------------------------

# library(magrittr,warn.conflicts = F); library(tidyverse,warn.conflicts = F)
library(dplyr)
# oldtheme <- theme_set(theme_bw())
library(readxl)


# Read Data ---------------------------------------------------------------

total_counts <- read_excel("app/data/sample_data.xlsx", sheet = "total_counts")
pest_counts <- read_excel("app/data/sample_data.xlsx", sheet = "pest_counts")


# Unit Tests --------------------------------------------------------------

## Test if file fulfills all conditions
## total_counts
## - unique bonitur_ID
## - existing plots, units, ...
## pest_counts
## - bonitur_ID is included in total_counts
## - plot, unit, BBCH fits with total_counts
## - depending on pest:BBCH, pest_nr is included (<= IMPORTANT!)


# Aggregation -------------------------------------------------------------

## units with TRUE/FALSE
agg_binary_counts <- pest_counts %>% 
  filter(is.na(pest_nr)) %>% 
  group_by(bonitur_ID, plot, BBCH, pest, unit) %>% 
  summarise(unit_infested = n())

## units with count
agg_pest_counts <- pest_counts %>% 
  filter(!is.na(pest_nr)) %>% 
  group_by(bonitur_ID, plot, BBCH, pest, unit) %>% 
  summarise(count_pests = sum(pest_nr))

agg_counts <- full_join(agg_binary_counts, agg_pest_counts) %>% 
  left_join(total_counts) %>% 
  select(bonitur_ID, plot, BBCH, pest, unit, nr_of_units_counted,
         unit_infested, count_pests) %>% 
  ungroup()

