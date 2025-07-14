# HTML File Viewer - R Shiny Application

A simple R Shiny application that allows users to upload HTML files, save them locally, and view them in a web browser interface.

## Features

- **Upload HTML Files**: Upload `.html` or `.htm` files through a user-friendly interface
- **File Management**: View a list of all uploaded files with details (filename, size, modification date)
- **File Viewing**: Select and preview HTML files directly in the application
- **File Storage**: Automatically saves uploaded files with timestamps to prevent conflicts
- **File Deletion**: Remove unwanted files with confirmation dialog

## Installation

### Prerequisites

Make sure you have R installed on your system. You'll also need the following R packages:

```r
install.packages(c("shiny", "shinydashboard", "DT"))
```

### Running the Application

1. Run the application:
   ```r
   # Option 1: Run directly
   shiny::runApp("app.R")
   
   # Option 2: Source and run
   source("app.R")
   ```

2. The application will open in your default web browser, typically at `http://127.0.0.1:xxxx`

## Usage

### Uploading Files

1. Go to the "Upload & View" tab
2. Click "Choose HTML File" and select your HTML file
3. Click "Save File" to upload and store the file
4. The file will be automatically renamed with a timestamp to prevent conflicts

### Viewing Files

1. Select a file from the dropdown menu in the "Select File to View" section
2. The HTML content will automatically display in the preview area
3. File details (size, modification date) will be shown below the dropdown

### Managing Files

1. Go to the "File Manager" tab
2. View all uploaded files in a sortable table
3. Select a file and click "Delete Selected" to remove it
4. Click "Refresh List" to update the file list

## File Storage

- All uploaded files are stored in the `uploads/` directory (created automatically)
- Files are automatically renamed with timestamps (e.g., `myfile_20250702_143022.html`)
- Only `.html` and `.htm` files are accepted