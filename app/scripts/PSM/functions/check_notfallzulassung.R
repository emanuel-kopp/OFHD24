# Kontrolliert das Datum der letzten veröffentlichten Notfallzulassunn

check_notfallzulassung <- function() {
    library(rvest)
    library(mark)

    check <- readLines("https://www.blv.admin.ch/blv/de/home/zulassung-pflanzenschutzmittel/anwendung-und-vollzug/notfallzulassungen.html")

    start <- grep(paste0("Allgemeinverfügungen ", format(Sys.Date(), "%Y")), check)
    stop <- grep(paste0("Allgemeinverfügungen ", as.numeric(format(Sys.Date(), "%Y")) - 1), check)

    check <- check[start:stop]

    check_dates <- lapply(check, function(x) str_extract_date(x, format = "%d.%m.%Y")) %>%
        lapply(., function(x) as.character(as.Date(x))) %>%
        do.call(rbind, .) %>%
        max(., na.rm = TRUE)
    return(check_dates)
}
