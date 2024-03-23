#' ---
#' project: OFHD24    #####################################################
#' title:   Fun threshold
#' author:  Reto Zihlmann <retozihlmann@outlook.com>
#' date:    2024-03-23 09:43:36
#' output:  github_document   #############################################
#' ---


# Packages ----------------------------------------------------------------

library(magrittr,warn.conflicts = F); library(tidyverse,warn.conflicts = F)


read_rds("app/data/damage_threshold.rds")

# Function ----------------------------------------------------------------

compare_against_threshold <- function(total_counts, pest_counts, damage_threshold) {
  ########## Aggregation
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
  
  ############ Check threshold
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
}

