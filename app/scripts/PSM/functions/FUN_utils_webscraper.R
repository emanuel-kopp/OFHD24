# OFHD2024
# obst

get_psm_table_web <- function(organism_id){
  # input: organism id from blv, output df containing list of potential psm 
  require(rvest)
  require(dplyr)
  #create link
  download_link <- paste0("https://www.psm.admin.ch/de/schaderreger/",
                          organism_id)
  #read page
  webpage <- read_html(download_link)
  #get content
  df_list <- webpage %>%
    html_table(fill = TRUE)
  output_df <- as.data.frame(df_list[[1]])
  
  output_df$Zulassungsnummer <- gsub(".-","",output_df$Zulassungsnummer)
  output_df <- output_df[,-which(names(output_df) %in% c(
    "Parallelimport", "Nichtberufliche Verwendung"))]
  #return df
  return(output_df)
  
}


psm_dosage_and_regulations_adder <- function(psm_id, species = "Apfel" ){
  # get infromation about the PSMs and the corresponding regulations
  require(rvest)
  
  download_link <- paste0("https://www.psm.admin.ch/de/produkte/",psm_id)
  #read page
  webpage <- read_html(download_link)
  #get content of psm
  df_list <- webpage %>%
    html_table(fill = TRUE)
  if(length(df_list)<3){
    return()
  }
  psm_df <- as.data.frame(df_list[[2]])
  psm_df  <- subset(psm_df, Kultur == species)
  if(dim(psm_df)[1]<1){
    return()
  }
  psm_df$Zulassungsnummer <- psm_id
  
  # get regulations
  page <- readLines(download_link)
  
  regulations <- page[grep("<li>",page)[which(grep("<li>",page) %in% c(grep(
    "Auflagen und Bemerkungen:",page):grep("Gefahrenkennzeichnungen:",page)))]]
  # clean
  regulations <- gsub("<li>","",regulations)
  regulations <- gsub("</li>","",regulations)
  
  regulations_df <- data.frame("Auflagen_number"= c(1:length(regulations)),
                               "regulation" = regulations,
                               "Zulassungsnummer" = psm_id)
  
  # add regulations to the psm_df
  
  out_list <- list("PSM_info" = psm_df,
                   "Auflagen" = regulations_df)
  
  
  return(out_list)

}



get_full_psm_info <- function(organism_id,species){
  # combine all information about psm
  psm_available <- get_psm_table_web(organism_id = organism_id)
  all_regulations <- list()
  all_psm_info <- list()
  
  for (psm in psm_available$Zulassungsnummer){
    one_psm <- subset(psm_available, Zulassungsnummer == psm )
    psm_add_info <- psm_dosage_and_regulations_adder(psm_id = psm,
                                                     species = species)
    if(is.null(psm_add_info)){
      next
    }
    all_psm_info[[psm]] <-  cbind(one_psm, psm_add_info$PSM_info[,which(names(
      psm_add_info$PSM_info) %in% c("Schaderreger/Wirkung", "Dosierungshinweise"
                                    ,"Auflagen" ))])
    

    current_regulations <- as.numeric(unlist(strsplit(
                psm_add_info$PSM_info$Auflagen, ", ")))
    
    all_regulations[[psm]] <- subset(psm_add_info$Auflagen, Auflagen_number %in% 
                                       current_regulations)

  }
  all_psm_info_df <- do.call("rbind",all_psm_info)
  all_regulations_df <- do.call("rbind",all_regulations)
  
  return(list("PSM_infos"= all_psm_info_df,
              "regulation_infos" = all_regulations_df))
}



