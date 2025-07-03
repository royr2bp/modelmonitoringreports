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
    }
  })

  # User info for role-based access
  user_info <- reactive({
    credentials()$info
  })

  # Define the upload directory
  upload_dir <- "uploaded_files"

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

    # Create file cards
    file_cards <- lapply(1:nrow(values$files), function(i) {
      file_info <- values$files[i, ]

      div(class = "file-card",
        onclick = paste0("selectFile('", file_info$filename, "')"),
        div(class = "card",
          div(class = "card-header",
            h5(file_info$filename)
          ),
          div(class = "card-body",
            p(strong("Size: "), paste0(file_info$size, " KB")),
            p(strong("Modified: "), file_info$modified),
            div(style = "margin-top: 10px;",
              actionButton(paste0("quick_serve_", i), "Quick View",
                         class = "btn-info btn-sm",
                         onclick = paste0("serveFile('", file_info$filename, "')"))
            )
          )
        )
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

  # Handle quick serve from carousel
  observe({
    req(values$files)

    lapply(1:nrow(values$files), function(i) {
      observeEvent(input[[paste0("quick_serve_", i)]], {
        filename <- values$files$filename[i]
        file_path <- file.path(upload_dir, filename)

        if (file.exists(file_path)) {
          file_url <- paste0(session$clientData$url_protocol, "//",
                            session$clientData$url_hostname, ":",
                            session$clientData$url_port,
                            session$clientData$url_pathname,
                            "reports/", filename)

          session$sendCustomMessage("openFullScreen", list(
            url = file_url,
            filename = filename
          ))
        } else {
          showNotification("File not found!", type = "error")
        }
      })
    })
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
    req(input$file)

    uploaded_count <- 0
    error_count <- 0

    for (i in 1:nrow(input$file)) {
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
