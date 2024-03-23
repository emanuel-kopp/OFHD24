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
  r_df[["poison_table"]] <- NULL
  
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
    value_box("Anzahl kontrollierte Einheiten", value = r_arr$flower_counter)
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
    r_df$bonitur_pests$date[start:end] <- Sys.Date()
    r_df$bonitur_pests$unit_ID[start:end] <- r_arr$flower_counter
    r_df$bonitur_pests$pest[start:end] <- input$pests_checkbox_input
    r_df$bonitur_pests$BBCH[start:end] <- as.integer(input$bbch)
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
    r_df$bonitur_n_units$BBCH[start:end] <- as.integer(input$bbch)
    r_df$bonitur_n_units$date[start:end] <- Sys.Date()
    r_df$bonitur_n_units$unit <- "Blütenbüschel"
    r_df$bonitur_n_units$nr_of_units_counted[start:end] <- r_arr$flower_counter
    print(r_df$bonitur_n_units)
    r_arr[["flower_counter"]] <- 0
    write.csv(r_df$bonitur_n_units, "total_counts.csv", row.names = F)
    write.csv(r_df$bonitur_pests, "pest_counts.csv", row.names = F)
  })
  
  # Observe show spritzvorschlag
  observeEvent(input$show_poison, {
    df_threshold <- 
      compare_against_threshold(r_df$bonitur_n_units, r_df$bonitur_pests, damage_threshold)
    pests_to_treat <- df_threshold$pest[df_threshold$decision %in% c("above", "within")]
    print(pests_to_treat)
    if (length(pests_to_treat) > 0) {
      output_psm <- master_psm(pest_name = pests_to_treat[1], "Kernobst")
      r_df$poison_table <- output_psm$alle_psm_infos$PSM_infos
    } else {
      r_df$poison_table <- as.data.frame(matrix(nrow = 0, ncol = 1))
      colnames(r_df$poison_table) <- "Nichts zu spritzen!"
    }
  })
  
  output$poison_ui <- renderUI({
    if (is.null(r_df$poison_table)) {
      uiOutput("gif")
    } else {
      dataTableOutput("table_poison")
    }
  })
  
  output$gif <- renderUI({
    fluidPage(
      img(src="caterpillar_waiting.gif", align = "left")
    )
  })
  
  output$table_poison <- renderDataTable({
    DT::datatable(
      r_df$poison_table, style = "bootstrap4", rownames = F,
      options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/German.json')))
  })
  
  # Reactive UI ====
  
  # Start page
  output$start_page <- renderUI({
    out <- tagList()
    out[[1]] <- selectInput("orchard", label = "Parzelle", 
                            choices = c("Hinterguggen", "Vorderluegen"))
    out[[2]] <- selectInput("bbch", label = "BBCH", 
                            choices = stadien$nummer, selected = "59")
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
      choiceValues = pests$schaedling, 
      choiceNames = lapply(list_images_links, function (f) { HTML(f) })
      )
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
  
  
  # Chose pest for history plot
  output$history <- renderUI({
    out <- tagList()
    if (input$history_type == "pest") {
      out[[1]] <- selectInput("pest", label = "Parzelle", 
                              choices = c("Apfelwickler", "Apfelblütenstecher"))
      out
    } else if (input$history_type == "bonitur") {
      out[[1]] <- selectInput("pest", label = "Parzelle", 
                              choices = c("Bonitur 1", "Bonitur 2"))
      out
    }
    })
  
  # Add history with plot
  output$history_plot <- renderPlot({
    if (grepl("Bonitur", input$pest)) {
      bon_num <- as.numeric(gsub("\\D", "", input$pest))
      make_example_plot_one_rating(bon_num)
    } else {
      make_example_plot(input$pest)
    }
  })
}