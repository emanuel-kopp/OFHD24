# ---------------------------------------------------------------------------- #
# Shiny App 
# UI File
# Bonitur Obstschädlinge
# ---------------------------------------------------------------------------- #

ui <- page_sidebar(
  id = "tabselected",
  fillable_mobile = TRUE,
  # Browser Tab title
  window_title = tags$head(
    tags$title("Obstschädlinge"),
  ),
  
  title = "Obstschädlinge",
  
  sidebar = sidebar(
    width = "20%",
    # Auswahl Kultur
    selectInput(inputId = "species", label = "Art", 
                choices = c("Apfel", "Birne", "Zwetschge")
    )
  ),
  
  # Main
  card(
    card_header("Visuelle Kontrolle"),
    uiOutput("card_ui"),
  )
)
