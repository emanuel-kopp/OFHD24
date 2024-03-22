# ---------------------------------------------------------------------------- #
# Shiny App 
# Server File
# Bonitur Obstschädlinge
# ---------------------------------------------------------------------------- #

server <- function(input, output, session) {
  # Reactive variables
  r_arr <- reactiveValues()
  r_arr[["flower_counter"]] <- 0
  r_arr[["page"]] <- 1
  
  # Observe: Pest present
  observeEvent(input$yes_pest, {
    r_arr[["flower_counter"]] <- r_arr[["flower_counter"]] + 1
    r_arr[["page"]] <- 2
  })
  
  # Observe: No pest
  observeEvent(input$no_pest, {
    r_arr[["flower_counter"]] <- r_arr[["flower_counter"]] + 1
  })
  
  # Observe: No pest
  observeEvent(input$plus_10, {
    r_arr[["flower_counter"]] <- r_arr[["flower_counter"]] + 10
  })
  
  # Update value box
  output$flower_counter_value_box_ui <- renderUI({
    value_box("Anzahl Blüten", value = r_arr$flower_counter)
  })
  
  # Observe save pests
  observeEvent(input$save_pests, {
    r_arr[["page"]] <- 1
  })
  
  # Flower counter UI
  output$flower_counter_ui <- renderUI({
    out <- tagList()
    out[[1]] <- uiOutput("flower_counter_value_box_ui")
    out[[2]] <- card_title("Schädling vorhanden?")
    out[[3]] <- actionButton("yes_pest", "Ja")
    out[[4]] <- actionButton("no_pest", "Nein")
    out[[5]] <- actionButton("plus_10", "10 x Nein")
    out
  })
  
  # Pest choice UI
  output$pests_choice_ui <- renderUI({
    out <- tagList()
    out[[1]] <- uiOutput("flower_counter_value_box_ui")
    out[[2]] <- card_title("Welche Schädlinge sind vorhanden?")
    out[[3]] <- checkboxGroupInput(
      "pests_checkbox_input", label = "Vorhandene Schädlinge", 
      choices = v_pests)
    out[[4]] <- actionButton("save_pests", label = "Weiter", 
                             icon = icon("floppy-disk"))
    out
  })
  
  # UI depending on current page value
  output$card_ui <- renderUI({
    print(r_arr$page)
    if (r_arr$page == 1) {
      uiOutput("flower_counter_ui")
    } else if (r_arr$page == 2) {
      uiOutput("pests_choice_ui")
    }
  })
  
  
}