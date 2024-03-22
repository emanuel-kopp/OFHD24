# Funktion um die IDs (key) und die Namen der Schadorganismen verlinkt, um damit auf die Liste der möglichen PSM zuzugreifen

match_maker <- function() {
    library(utils)
    library(xml2)
    library(XML)
    library(mark)
    library(tidyr)

    ifelse(file.exists("data/pest_matcher.csv"), check_date <- TRUE, c(check_date <- FALSE, run_code <- TRUE))

    if (check_date == TRUE) {
        my_matcher <- read.csv("data/pest_matcher.csv")
        pubdate <- readLines("https://www.blv.admin.ch/blv/de/home/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis.html")
        pubdate <- as.character(grep("Daten Pflanzen", pubdate, value = TRUE)) %>%
            str_extract_date(., format = "%d.%m.%Y")
        my_date <- unique(my_matcher$date)
        ifelse(pubdate > my_date, run_code <- TRUE, run_code <- FALSE)
    }

    if (run_code == TRUE) {
        download.file("https://www.blv.admin.ch/dam/blv/de/dokumente/zulassung-pflanzenschutzmittel/pflanzenschutzmittelverzeichnis/daten-pflanzenschutzmittelverzeichnis.zip", "PSM.zip")
        unzip("PSM.zip")
        fileurl <- "PublicationData.xml"
        data <- read_xml(fileurl)
        data <- xmlParse(data)
        xmltop <- xmlRoot(data)

        pest_matcher <- data.frame(key = c(), pest = c())
        for (i in 1:xmlSize(xmltop[[10]])) {
            if (xmlSize(xmltop[[10]][[i]]) == 5) {
                the_pest <- xmlGetAttr(xmltop[[10]][[i]][[1]], "value")
            } else if (xmlSize(xmltop[[10]][[i]]) == 6) {
                the_pest <- xmlGetAttr(xmltop[[10]][[i]][[2]], "value")
            }
            the_key <- as.numeric(xmlGetAttr(xmltop[[10]][[i]], "primaryKey"))
            foo <- data.frame(key = the_key, pest = the_pest)
            pest_matcher <- rbind(pest_matcher, foo)
        }
        pest_matcher$date <- Sys.Date()
        write.csv(pest_matcher, "data/pest_matcher.csv", row.names = FALSE)
        unlink("*.xml")
        unlink("*.xsd")
        unlink("*.zip")
    }
}
