#' ---
#' project: OFHD24    #####################################################
#' title:   Calculate damage threshold
#' author:  Reto Zihlmann <retozihlmann@outlook.com>
#' date:    2024-03-22 20:57:35
#' output:  github_document   #############################################
#' ---


# Packages ----------------------------------------------------------------

# library(magrittr,warn.conflicts = F); library(tidyverse,warn.conflicts = F)
library(dplyr)
# oldtheme <- theme_set(theme_bw())
library(readxl)
source("app/scripts/damage_threshold/01_bonitur_data_agg.R")


# Read Data ---------------------------------------------------------------

damage_threshold <- read_excel("app/data/sample_data.xlsx", sheet = "damage_threshold")
saveRDS(damage_threshold, file = "app/data/damage_threshold.rds")
agg_counts



# Check threshold ---------------------------------------------------------

agg_counts %>% 
  mutate(damage_calc = if_else(!is.na(unit_infested),
                                         unit_infested/nr_of_units_counted,
                                         count_pests)) %>% 
  select(bonitur_ID, plot, BBCH, pest, unit, damage_calc) %>% 
  left_join(damage_threshold %>% 
              select(pest, BBCH_lo, BBCH_up, samplesize_unit, damage_threshold_unit, damage_threshold,
                     damage_threshold_lo, damage_threshold_up) %>% 
              rename(unit = samplesize_unit)) %>%
  filter(between(BBCH, BBCH_lo, BBCH_up)) %>% 
  mutate(decision = if_else(!is.na(damage_threshold),
                          if_else(damage_calc >= damage_threshold, "above", "below"),
                          case_when(damage_calc < damage_threshold_lo ~ "below",
                                            damage_calc < damage_threshold_up ~ "within",
                                            damage_calc >= damage_threshold_up ~ "above"))) %>% 
  mutate(threshold = if_else(!is.na(damage_threshold), paste(damage_threshold_unit, damage_threshold),
                             paste0(damage_threshold_unit, " ", damage_threshold_lo, "-", damage_threshold_up))) %>% 
  select(bonitur_ID, plot, BBCH, pest, damage_calc, threshold, decision)



# Test Fun ----------------------------------------------------------------

source("app/scripts/damage_threshold/00_fun_damage_threshold.R")
compare_against_threshold(total_counts = total_counts, pest_counts = pest_counts, damage_threshold = damage_threshold)
