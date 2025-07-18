# Global variables and setup for HTML File Viewer Shiny Application

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(htmltools)
library(shinyjs)
library(shinyauthr)
library(sodium)

# Authentication setup
# Create user credentials data frame with hashed passwords
user_base <- data.frame(
  user = c("admin", "user"),
  password = sapply(c("Admin@Risk2025!", "User@Risk2025!"), sodium::password_store),
  permissions = c("admin", "user"),
  name = c("Administrator", "User"),
  stringsAsFactors = FALSE,
  row.names = NULL
)
upload_dir <- "uploads"

# Function to get file list with metadata
get_file_list <- function() {
  files <- list.files(upload_dir, pattern = "\\.(html|htm)$", full.names = FALSE)
  if (length(files) > 0) {
    file_info <- data.frame(
      filename = files,
      size = sapply(files, function(f) {
        size_bytes <- file.info(file.path(upload_dir, f))$size
        if (size_bytes < 1024) {
          paste(size_bytes, "B")
        } else if (size_bytes < 1024^2) {
          paste(round(size_bytes/1024, 2), "KB")
        } else {
          paste(round(size_bytes/1024^2, 2), "MB")
        }
      }),
      modified = sapply(files, function(f) {
        as.character(file.info(file.path(upload_dir, f))$mtime)
      }),
      path = file.path(upload_dir, files),
      stringsAsFactors = FALSE
    )
  } else {
    file_info <- data.frame(
      filename = character(0),
      size = character(0),
      modified = character(0),
      path = character(0),
      stringsAsFactors = FALSE
    )
  }
  return(file_info)
}

# Function to create file preview card for carousel - Alteryx Style
create_file_card <- function(filename, size, modified, index) {
  div(
    class = "file-card",
    `data-index` = index,
    div(
      class = "card",
      div(
        class = "card-header",
        h5(
          style = "margin: 0; font-size: 14px; font-weight: 600; line-height: 1.3; color: white;",
          filename
        )
      ),
      div(
        class = "card-body",
        p(strong("Size: "), size, style = "margin: 4px 0; font-size: 13px; color: #5f6368;"),
        p(strong("Modified: "), format(as.POSIXct(modified), "%Y-%m-%d %H:%M"), style = "margin: 4px 0; font-size: 13px; color: #5f6368;"),
        div(
          style = "text-align: center; margin-top: 12px;",
          tags$button(
            "Open Report",
            class = "btn btn-primary btn-sm",
            style = "width: 100%; background-color: #1f77b4; border-color: #1f77b4; font-weight: 600; padding: 8px 16px; border: none; border-radius: 4px; color: white; cursor: pointer;",
            onclick = paste0('console.log("Button clicked for file: ', gsub('"', '\\\\"', filename), '"); Shiny.setInputValue("carousel_file_action", "', gsub('"', '\\\\"', filename), '", {priority: "event"});')
          )
        )
      )
    )
  )
}

# Remove file size limits
options(shiny.maxRequestSize = -1)
