# Server logic for HTML File Viewer Shiny Application
library(shiny)
library(shinydashboard)
library(DT)
library(shinyjs)

server <- function(input, output, session) {

  # Authentication logic
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    sodium_hashed = TRUE,
    log_out = reactive(logout_init())
  )

  # Show/hide content based on authentication
  observe({
    if (credentials()$user_auth) {
      shinyjs::hide("login-content")
      shinyjs::show("main-content")
    } else {
      shinyjs::show("login-content")
      shinyjs::hide("main-content")
      # Reset to Report Gallery when logging out
      updateTabItems(session, "sidebar", "carousel")
    }
  })

  # User info for role-based access
  user_info <- reactive({
    credentials()$info
  })

  # Reactive output for UI conditional panels
  output$user_is_admin <- reactive({
    req(credentials()$user_auth)
    !is.null(user_info()) && user_info()$permissions == "admin"
  })
  outputOptions(output, "user_is_admin", suspendWhenHidden = FALSE)

  # Security: Redirect non-admin users away from restricted tabs
  observe({
    req(credentials()$user_auth)
    if (!is.null(user_info()) && user_info()$permissions != "admin") {
      # Check if user is on a restricted tab
      if (!is.null(input$sidebar) && input$sidebar %in% c("upload", "manager")) {
        # Redirect to Report Gallery
        updateTabItems(session, "sidebar", "carousel")
      }
    }
  })

  # Define the upload directory
  upload_dir <- "uploads"

  # Create upload directory if it doesn't exist
  if (!dir.exists(upload_dir)) {
    dir.create(upload_dir, recursive = TRUE)
  }

  # Add resource path to serve HTML
  addResourcePath("reports", upload_dir)

  # Reactive values
  values <- reactiveValues(
    files = NULL,
    selected_file = NULL
  )

  # Function to scan for HTML files
  scan_files <- function() {
    if (dir.exists(upload_dir)) {
      files <- list.files(upload_dir, pattern = "\\.(html|htm)$", ignore.case = TRUE, full.names = FALSE)
      if (length(files) > 0) {
        file_info <- file.info(file.path(upload_dir, files))
        data.frame(
          filename = files,
          size = round(file_info$size / 1024, 2),
          modified = format(file_info$mtime, "%Y-%m-%d %H:%M"),
          stringsAsFactors = FALSE
        )
      } else {
        data.frame(filename = character(0), size = numeric(0), modified = character(0))
      }
    } else {
      data.frame(filename = character(0), size = numeric(0), modified = character(0))
    }
  }

  # Initialize file list
  observe({
    req(credentials()$user_auth)  # Require authentication
    values$files <- scan_files()
  })

  # Check if files exist
  output$has_files <- reactive({
    req(credentials()$user_auth)  # Require authentication
    !is.null(values$files) && nrow(values$files) > 0
  })
  outputOptions(output, "has_files", suspendWhenHidden = FALSE)

  # Handle file serving for carousel
  observeEvent(input$serve_selected, {
    req(credentials()$user_auth)  # Require authentication
    req(input$selected_file_carousel)

    # Validate file exists
    file_path <- file.path(upload_dir, input$selected_file_carousel)
    if (file.exists(file_path)) {
      # Create the URL using the resource path
      file_url <- paste0(session$clientData$url_protocol, "//",
                        session$clientData$url_hostname, ":",
                        session$clientData$url_port,
                        session$clientData$url_pathname,
                        "reports/", input$selected_file_carousel)

      # Send custom message to JavaScript to open the file
      session$sendCustomMessage("openFullScreen", list(
        url = file_url,
        filename = input$selected_file_carousel
      ))
    } else {
      showNotification("File not found!", type = "error")
    }
  })

  # Generate carousel content
  output$carousel_files <- renderUI({
    req(credentials()$user_auth)  # Require authentication
    req(values$files)

    if (nrow(values$files) == 0) {
      return(div())
    }

    # Send total files count to JavaScript
    session$sendCustomMessage("updateCarouselData", list(totalFiles = nrow(values$files)))

    # Create file cards using the function from global.R
    file_cards <- lapply(seq_len(nrow(values$files)), function(i) {
      file_info <- values$files[i, ]
      create_file_card(
        filename = file_info$filename,
        size = file_info$size,
        modified = file_info$modified,
        index = i
      )
    })

    do.call(tagList, file_cards)
  })

  # Generate carousel indicators
  output$carousel_indicators <- renderUI({
    req(credentials()$user_auth)  # Require authentication
    req(values$files)

    if (nrow(values$files) <= 3) return(div()) # Don't show indicators if all files are visible

    indicators <- lapply(0:(nrow(values$files) - 1), function(i) {
      div(class = "carousel-dot", onclick = paste0("goToSlide(", i, ")"))
    })

    do.call(tagList, indicators)
  })
  # Handle file serving from carousel buttons
  observeEvent(input$carousel_file_action, {
    req(credentials()$user_auth)  # Require authentication
    req(input$carousel_file_action)

    cat("Carousel file action triggered for:", input$carousel_file_action, "\n")

    filename <- input$carousel_file_action
    file_path <- file.path(upload_dir, filename)

    if (file.exists(file_path)) {
      file_url <- paste0(session$clientData$url_protocol, "//",
                        session$clientData$url_hostname, ":",
                        session$clientData$url_port,
                        session$clientData$url_pathname,
                        "reports/", filename)

      cat("Opening file URL:", file_url, "\n")

      session$sendCustomMessage("openFullScreen", list(
        url = file_url,
        filename = filename
      ))
    } else {
      showNotification("File not found!", type = "error")
    }
  })

  # Display selected file name
  output$selected_file_display <- renderText({
    req(credentials()$user_auth)  # Require authentication
    req(input$selected_file_carousel)
    paste("File:", input$selected_file_carousel)
  })

  # File upload handling
  observeEvent(input$upload_btn, {
    req(credentials()$user_auth)  # Require authentication
    req(user_info()$permissions == "admin")  # Only admin can upload
    req(input$file)

    uploaded_count <- 0
    error_count <- 0

    for (i in seq_len(nrow(input$file))) {
      file_info <- input$file[i, ]

      # Check if it's an HTML file
      if (grepl("\\.(html|htm)$", file_info$name, ignore.case = TRUE)) {
        # Copy file to upload directory
        file.copy(file_info$datapath, file.path(upload_dir, file_info$name), overwrite = TRUE)
        uploaded_count <- uploaded_count + 1
      } else {
        error_count <- error_count + 1
      }
    }

    # Update file list
    values$files <- scan_files()

    # Show notification
    if (uploaded_count > 0) {
      showNotification(paste("Successfully uploaded", uploaded_count, "file(s)"), type = "message")
    }
    if (error_count > 0) {
      showNotification(paste(error_count, "file(s) were not HTML files and were skipped"), type = "warning")
    }
  })

  # File manager table
  output$files_table <- DT::renderDataTable({
    req(credentials()$user_auth)  # Require authentication
    req(values$files)
    values$files
  }, options = list(
    pageLength = 10,
    searching = TRUE,
    ordering = TRUE
  ), selection = "multiple")

  # Refresh file list
  observeEvent(input$refresh_btn, {
    req(credentials()$user_auth)  # Require authentication
    values$files <- scan_files()
    showNotification("File list refreshed", type = "message")
  })

  # Delete selected files
  observeEvent(input$delete_btn, {
    req(credentials()$user_auth)  # Require authentication
    # Only allow admin users to delete files
    req(user_info()$permissions == "admin")
    selected_rows <- input$files_table_rows_selected

    if (length(selected_rows) > 0) {
      files_to_delete <- values$files$filename[selected_rows]

      # Show confirmation modal
      showModal(modalDialog(
        title = "Confirm Deletion",
        paste("Are you sure you want to delete", length(files_to_delete), "file(s)?"),
        footer = tagList(
          modalButton("Cancel"),
          actionButton("confirm_delete", "Delete", class = "btn-danger")
        )
      ))
    } else {
      showNotification("Please select files to delete", type = "warning")
    }
  })

  # Confirm deletion
  observeEvent(input$confirm_delete, {
    req(credentials()$user_auth)  # Require authentication
    req(user_info()$permissions == "admin")  # Only admin can delete
    selected_rows <- input$files_table_rows_selected

    if (length(selected_rows) > 0) {
      files_to_delete <- values$files$filename[selected_rows]
      deleted_count <- 0

      for (filename in files_to_delete) {
        file_path <- file.path(upload_dir, filename)
        if (file.exists(file_path)) {
          file.remove(file_path)
          deleted_count <- deleted_count + 1
        }
      }

      # Update file list
      values$files <- scan_files()

      showNotification(paste("Deleted", deleted_count, "file(s)"), type = "message")
    }

    removeModal()
  })

  # Upload status output
  output$upload_status <- renderText({
    req(credentials()$user_auth)  # Require authentication
    if (!is.null(input$file)) {
      paste("Ready to upload", nrow(input$file), "file(s)")
    } else {
      "No files selected"
    }
  })

  # Control delete button visibility based on user permissions
  observe({
    req(credentials()$user_auth)
    if (user_info()$permissions == "admin") {
      shinyjs::show("delete_btn")
    } else {
      shinyjs::hide("delete_btn")
    }
  })

  # Navigation to upload tab
  observeEvent(input$go_to_upload, {
    req(credentials()$user_auth)  # Require authentication
    updateTabItems(session, "sidebar", "upload")
  })
}
