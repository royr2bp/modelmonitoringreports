# Server logic for HTML File Viewer Shiny Application

server <- function(input, output, session) {
  
  # Reactive value to store file list
  file_list <- reactiveVal()
  
  # Function to update file list
  update_file_list <- function() {
    file_info <- get_file_list()
    file_list(file_info)
    
    # Send carousel update message to JavaScript
    session$sendCustomMessage("updateCarouselData", list(
      totalFiles = nrow(file_info)
    ))
  }
  
  # Initialize file list on startup
  observe({
    update_file_list()
  })
  
  # Check if files exist
  output$has_files <- reactive({
    nrow(file_list()) > 0
  })
  outputOptions(output, "has_files", suspendWhenHidden = FALSE)
  
  # Generate carousel file cards
  output$carousel_files <- renderUI({
    files <- file_list()
    if (nrow(files) == 0) return(NULL)
    
    file_cards <- lapply(1:nrow(files), function(i) {
      create_file_card(
        filename = files$filename[i],
        size = files$size[i], 
        modified = files$modified[i],
        index = i
      )
    })
    
    do.call(tagList, file_cards)
  })
  
  # Generate carousel indicators
  output$carousel_indicators <- renderUI({
    files <- file_list()
    if (nrow(files) == 0) return(NULL)
    
    # Calculate number of slides needed
    card_width <- 300
    viewport_width <- 1200  # Approximate viewport width
    cards_per_slide <- max(1, floor(viewport_width / card_width))
    num_slides <- ceiling(nrow(files) / cards_per_slide)
    
    if (num_slides <= 1) return(NULL)
    
    indicators <- lapply(1:num_slides, function(i) {
      div(
        class = if (i == 1) "carousel-dot active" else "carousel-dot",
        onclick = paste0("goToSlide(", i-1, ")")
      )
    })
    
    do.call(tagList, indicators)
  })
  
  # Handle file upload
  observeEvent(input$upload_btn, {
    req(input$file)
    
    tryCatch({
      uploaded_files <- input$file
      success_count <- 0
      
      for (i in 1:nrow(uploaded_files)) {
        file_info <- uploaded_files[i, ]
        
        # Create a unique filename to avoid conflicts
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        original_name <- tools::file_path_sans_ext(file_info$name)
        extension <- tools::file_ext(file_info$name)
        new_filename <- paste0(original_name, "_", timestamp, ".", extension)
        
        # Copy file to uploads directory
        file.copy(file_info$datapath, file.path("uploads", new_filename))
        success_count <- success_count + 1
      }
      
      # Update file list
      update_file_list()
      
      output$upload_status <- renderText({
        if (success_count == 1) {
          "✓ Analytics report uploaded successfully!"
        } else {
          paste("✓", success_count, "analytics reports uploaded successfully!")
        }
      })
      
      # Show notification
      showNotification(
        paste("�", success_count, "report(s) uploaded to library!"), 
        type = "message", 
        duration = 3
      )
      
    }, error = function(e) {
      output$upload_status <- renderText({
        paste("✗ Error uploading report(s):", e$message)
      })
    })
  })
  
  # Handle file selection from carousel
  observeEvent(input$selected_file_carousel, {
    if (!is.null(input$selected_file_carousel)) {
      output$selected_file_display <- renderText({
        paste("� Selected Report:", input$selected_file_carousel)
      })
    }
  })
  
  # Handle serve button for selected file
  observeEvent(input$serve_selected, {
    req(input$selected_file_carousel)
    serve_file_in_fullscreen(input$selected_file_carousel)
  })
  
  # Handle direct serve from carousel cards
  observeEvent(input$serve_file_carousel, {
    req(input$serve_file_carousel)
    serve_file_in_fullscreen(input$serve_file_carousel)
  })
  
  # Function to serve file in fullscreen
  serve_file_in_fullscreen <- function(filename) {
    tryCatch({
      file_path <- file.path("uploads", filename)
      
      if (file.exists(file_path)) {
        # Copy file to www directory for serving
        www_dir <- "www"
        if (!dir.exists(www_dir)) {
          dir.create(www_dir)
        }
        
        # Copy file to www directory
        file.copy(file_path, file.path(www_dir, filename), overwrite = TRUE)
        
        # Create URL and open in fullscreen
        url <- paste0(session$clientData$url_protocol, "//", 
                     session$clientData$url_hostname, ":", 
                     session$clientData$url_port, "/", 
                     filename)
        
        # Use JavaScript to open in fullscreen
        session$sendCustomMessage("openFullScreen", list(url = url))
        
        # Show notification
        showNotification(
          paste("🚀 Launching", filename, "in analytics viewer!"), 
          type = "message", 
          duration = 4
        )
        
      } else {
        showNotification("❌ Report not found", type = "error", duration = 3)
      }
      
    }, error = function(e) {
      showNotification(
        paste("❌ Error launching report:", e$message), 
        type = "error", 
        duration = 4
      )
    })
  }
  
  # Navigate to upload tab
  observeEvent(input$go_to_upload, {
    updateTabItems(session, "sidebarMenu", "upload")
  })
  
  # Render files table for manager
  output$files_table <- DT::renderDataTable({
    req(file_list())
    files <- file_list()
    if (nrow(files) > 0) {
      files[, c("filename", "size", "modified")]
    } else {
      data.frame(
        filename = character(0),
        size = character(0),
        modified = character(0)
      )
    }
  }, options = list(
    pageLength = 15, 
    scrollX = TRUE,
    dom = 'Bfrtip',
    columnDefs = list(list(className = 'dt-center', targets = "_all"))
  ), selection = 'single', class = 'cell-border stripe hover')
  
  # Handle refresh button
  observeEvent(input$refresh_btn, {
    update_file_list()
    showNotification("📋 Report library refreshed successfully!", type = "message", duration = 3)
  })
  
  # Handle delete button
  observeEvent(input$delete_btn, {
    req(input$files_table_rows_selected)
    
    selected_row <- input$files_table_rows_selected
    files <- file_list()
    file_to_delete <- files$filename[selected_row]
    
    showModal(modalDialog(
      title = "⚠️ Confirm Deletion",
      div(style = "padding: 10px;",
        h4("Are you sure you want to remove this report?", style = "color: #dc3545;"),
        p(paste("Report:", file_to_delete), style = "font-weight: bold; color: #495057;"),
        p("This action cannot be undone.", style = "color: #6c757d; font-style: italic;")
      ),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_delete", "Remove Report", class = "btn-danger", icon = icon("trash-alt"))
      ),
      size = "m"
    ))
  })
  
  # Handle confirmed deletion
  observeEvent(input$confirm_delete, {
    req(input$files_table_rows_selected)
    
    selected_row <- input$files_table_rows_selected
    files <- file_list()
    file_to_delete <- files$filename[selected_row]
    file_path <- file.path("uploads", file_to_delete)
    
    if (file.exists(file_path)) {
      file.remove(file_path)
      update_file_list()
      showNotification(paste("🗑️ Deleted:", file_to_delete), type = "warning", duration = 4)
      
      # Clear selection if deleted file was selected
      if (!is.null(input$selected_file_carousel) && input$selected_file_carousel == file_to_delete) {
        session$sendCustomMessage("clearSelection", list())
      }
    }
    
    removeModal()
  })
}
