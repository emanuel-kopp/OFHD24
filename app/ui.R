# ---------------------------------------------------------------------------- #
# Shiny App
# UI File
# Bonitur Obstschädlinge
# ---------------------------------------------------------------------------- #

ui <- page_navbar(
  id = "tabselected",
  fillable_mobile = TRUE,
  # Browser Tab title
  window_title = tags$head(tags$title("Obstschädlinge"),),
  
  includeCSS("styles.css"),
  
  title = "Obstschädlinge",
  
  sidebar = sidebar(
    width = "20%",
    # Auswahl Kultur
    selectInput(
      inputId = "species",
      label = "Art",
      choices = c("Apfel", "Birne", "Zwetschge")
    )
  ),
  
  # Felderfassung ====
  nav_panel(
    title = "Felderfassung",
    value = 0,
    card(card_header("Visuelle Kontrolle"),
         uiOutput("card_ui"))
  ),
  
  # Spritzvorschlag ====
  nav_panel(title = "Spritzvorschlag",
            card(
              card_header("Spritzvorschlag"),
              actionButton("show_poison", "Vorschlag für letzte Bonitur"),
              uiOutput("poison_ui")
            )),
  
  # Auswertung ====
  nav_panel(
    title = "Auswertung",
    value = 0,
    card(
      card_header("Auswertung"),
      radioButtons("history_type", label = "",
                   choices = c("Auswertung nach Schadorganismus anzeigen" = "pest",
                               "Auswertung nach Bonitur anzeigen" = "bonitur")),
      uiOutput("history"),
      plotOutput("history_plot")
    )
  )
)
