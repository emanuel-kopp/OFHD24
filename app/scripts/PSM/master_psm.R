# OFHD2024
# obst
#master

master_psm <- function(pest_name, crop_species) {
  source("scripts/PSM/functions/match_maker.R")
  source("scripts/PSM/functions/check_notfallzulassung.R")
  source("scripts/PSM/functions/FUN_utils_webscraper.R")
  
  # match maker run to make matches
  match_maker()
  #
  organism_id <- get_pest_ID(pest_name = pest_name)
  # get psm info
  all_psm_info <- get_full_psm_info(organism_id = organism_id,
                    crop_species = crop_species)
  
  last_notfall <- check_notfallzulassung()
  
  out_list <- list(
    "alle_psm_infos" = all_psm_info,
    "letzte_notfall_zulassung" = last_notfall
  )
  return(out_list)
}

