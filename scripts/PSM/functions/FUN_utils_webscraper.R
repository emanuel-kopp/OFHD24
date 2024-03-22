# OFHD2024
# obst

get_psm_table_web <- function(organism_id){
  # input: organism id from blv, output df containing list of potential psm 
  require(rvest)
  #create link
  download_link <- paste0("https://www.psm.admin.ch/de/schaderreger/",organism_id)
  #read page
  webpage <- read_html(download_link)
  #get content
  df_list <- webpage %>%
    html_table(fill = TRUE)
  output_df <- as.data.frame(df_list[[1]])
  #return df
  return(output_df)
  
}

  