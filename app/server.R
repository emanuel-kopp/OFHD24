# ---------------------------------------------------------------------------- #
# Shiny App 
# Server File
# Bonitur Obstschädlinge
# ---------------------------------------------------------------------------- #

server <- function(input, output, session) {
  
  # Reactive variables ====
  r_arr <- reactiveValues()
  r_arr[["flower_counter"]] <- 0
  r_arr[["page"]] <- 0
  r_arr[["bonitur_id"]] <- 0
  r_df <- reactiveValues()
  r_df[["bonitur_pests"]] <- bonitur_pests
  r_df[["bonitur_n_units"]] <- bonitur_n_units
  
  # Actions ====
  
  # Start Bonitur
  observeEvent(input$start_bonitur, {
    r_arr$page <- 1
    r_arr$bonitur_id <- r_arr$bonitur_id + 1
  })
  
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
    # Add data to dataframe
    start <- nrow(r_df$bonitur_pests) + 1
    end <- start + length(input$pests_checkbox_input) - 1
    r_df$bonitur_pests[start:end, 1] <- r_arr$bonitur_id
    r_df$bonitur_pests$plot[start:end] <- input$orchard
    r_df$bonitur_pests$unit[start:end] <- "Blütenbüschel"
    r_df$bonitur_pests$unit_ID[start:end] <- r_arr$flower_counter
    r_df$bonitur_pests$pest[start:end] <- input$pests_checkbox_input
    r_df$bonitur_pests$BBCH[start:end] <- input$bbch
    print(r_df$bonitur_pests)
  })
  
  # Observe end bonitur
  observeEvent(input$ende_bonitur, {
    r_arr[["page"]] <- 0
    # Add data to dataframe
    start <- nrow(r_df$bonitur_n_units) + 1
    end <- start + length(input$pests_checkbox_input) - 1
    r_df$bonitur_n_units[start:end, 1]  <- r_arr$bonitur_id
    r_df$bonitur_n_units$plot[start:end] <- input$orchard
    r_df$bonitur_n_units$BBCH[start:end] <- input$bbch
    r_df$bonitur_n_units$nr_of_units_counted[start:end] <- r_arr$flower_counter
    print(r_df$bonitur_n_units)
    r_arr[["flower_counter"]] <- 0
  })
  
  # Reactive UI ====
  
  # Start page
  output$start_page <- renderUI({
    out <- tagList()
    out[[1]] <- selectInput("orchard", label = "Parzelle", 
                            choices = c("Hinterguggen", "Vorderluegen"))
    out[[2]] <- selectInput("bbch", label = "BBCH", 
                            choices = c("58", "69"))
    out[[3]] <- actionButton("start_bonitur", label = "Start", 
                             icon = icon("circle-play"))
    out
  })
  
  # Flower counter UI
  output$flower_counter_ui <- renderUI({
    out <- tagList()
    out[[1]] <- uiOutput("flower_counter_value_box_ui")
    out[[2]] <- card_title("Schädling vorhanden?")
    out[[3]] <- actionButton("yes_pest", "Ja")
    out[[4]] <- actionButton("no_pest", "Nein")
    out[[5]] <- actionButton("plus_10", "10 x Nein")
    out[[6]] <- br()
    out[[7]] <- br()
    out[[8]] <- actionButton("ende_bonitur", "Bonitur beenden!")
    out
  })
  
  # Pest choice UI
  output$pests_choice_ui <- renderUI({
    out <- tagList()
    out[[1]] <- uiOutput("flower_counter_value_box_ui")
    out[[2]] <- card_title("Welche Schädlinge sind vorhanden?")
    out[[3]] <- checkboxGroupInput(
      "pests_checkbox_input", label = "Vorhandene Schädlinge", 
      choiceValues = pests$schaedling[1:3], 
      choiceNames = c(list(HTML("<img src='https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Cydia.pomonella.7162.jpg/2560px-Cydia.pomonella.7162.jpg'/>")),
                      list(HTML("<img src='https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Cydia.pomonella.7162.jpg/2560px-Cydia.pomonella.7162.jpg'/>")),
                      list(HTML("<img src='https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Cydia.pomonella.7162.jpg/2560px-Cydia.pomonella.7162.jpg'/>"))))
    out[[4]] <- actionButton("save_pests", label = "Weiter", 
                             icon = icon("floppy-disk"))
    out
  })
  
  # UI depending on current page value
  output$card_ui <- renderUI({
    print(r_arr$page)
    if (r_arr$page == 0) {
      uiOutput("start_page")
    } else if (r_arr$page == 1) {
      uiOutput("flower_counter_ui")
    } else if (r_arr$page == 2) {
      uiOutput("pests_choice_ui")
    }
  })
  
}