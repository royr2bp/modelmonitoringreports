# UI for HTML File Viewer Shiny Application

ui <- dashboardPage(
  dashboardHeader(title = "Model Monitoring Reports"),

  dashboardSidebar(
    sidebarMenu(id = "sidebar",
      menuItem("Report Gallery", tabName = "carousel", icon = icon("chart-line")),
      menuItem("Upload Reports", tabName = "upload", icon = icon("upload")),
      menuItem("Report Manager", tabName = "manager", icon = icon("cogs"))
    )
  ),

  dashboardBody(
    useShinyjs(),

    # Custom CSS for Alteryx-style professional interface
    tags$head(
      tags$style(HTML("
        @import url('https://fonts.googleapis.com/css2?family=Open+Sans:wght@300;400;600;700&display=swap');

        body, .content-wrapper, .right-side {
          background-color: #f7f8fa !important;
          font-family: 'Open Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          color: #2c3e50;
        }

        /* Alteryx Color Palette */
        :root {
          --alteryx-blue: #1f77b4;
          --alteryx-light-blue: #4a9eff;
          --alteryx-dark-blue: #1a5490;
          --alteryx-orange: #ff7f0e;
          --alteryx-green: #2ca02c;
          --alteryx-red: #d62728;
          --alteryx-purple: #9467bd;
          --alteryx-gray: #7f7f7f;
          --alteryx-light-gray: #f7f8fa;
          --alteryx-medium-gray: #e8eaed;
          --alteryx-dark-gray: #5f6368;
          --alteryx-text: #2c3e50;
          --alteryx-border: #dadce0;
        }

        .box {
          border-radius: 8px;
          box-shadow: 0 1px 3px rgba(60, 64, 67, 0.15);
          border: 1px solid var(--alteryx-border);
          background-color: #ffffff;
          margin-bottom: 20px;
        }

        .box-header {
          border-radius: 8px 8px 0 0;
          background-color: #ffffff !important;
          border-bottom: 1px solid var(--alteryx-border);
          padding: 16px 20px;
        }

        .box-header .box-title {
          font-size: 18px;
          font-weight: 600;
          color: var(--alteryx-text);
          margin: 0;
        }

        .box-body {
          padding: 20px;
        }

        .btn {
          border-radius: 6px;
          font-weight: 500;
          padding: 10px 20px;
          margin: 4px;
          font-size: 14px;
          transition: all 0.2s ease;
          border: none;
          text-transform: none;
        }

        .btn-success {
          background-color: var(--alteryx-green);
          color: white;
        }

        .btn-success:hover {
          background-color: #228B22;
          transform: translateY(-1px);
          box-shadow: 0 2px 8px rgba(44, 160, 44, 0.3);
        }

        .btn-primary {
          background-color: var(--alteryx-blue);
          color: white;
        }

        .btn-primary:hover {
          background-color: var(--alteryx-dark-blue);
          transform: translateY(-1px);
          box-shadow: 0 2px 8px rgba(31, 119, 180, 0.3);
        }

        .btn-info {
          background-color: var(--alteryx-light-blue);
          color: white;
        }

        .btn-info:hover {
          background-color: #3a8eff;
          transform: translateY(-1px);
          box-shadow: 0 2px 8px rgba(74, 158, 255, 0.3);
        }

        .btn-danger {
          background-color: var(--alteryx-red);
          color: white;
        }

        .btn-danger:hover {
          background-color: #c53030;
          transform: translateY(-1px);
          box-shadow: 0 2px 8px rgba(214, 39, 40, 0.3);
        }

        .btn-warning {
          background-color: var(--alteryx-orange);
          color: white;
        }

        .btn-warning:hover {
          background-color: #e85e00;
          transform: translateY(-1px);
          box-shadow: 0 2px 8px rgba(255, 127, 14, 0.3);
        }

        .form-control {
          border-radius: 6px;
          border: 1px solid var(--alteryx-border);
          padding: 10px 12px;
          font-size: 14px;
          transition: border-color 0.2s ease;
        }

        .form-control:focus {
          border-color: var(--alteryx-blue);
          box-shadow: 0 0 0 3px rgba(31, 119, 180, 0.1);
          outline: none;
        }

        /* Header Styling - Alteryx Blue Theme */
        .main-header .logo {
          background-color: var(--alteryx-blue) !important;
          color: white !important;
          border-bottom: none !important;
        }

        .main-header .logo:hover {
          background-color: var(--alteryx-dark-blue) !important;
        }

        .main-header .navbar {
          background-color: var(--alteryx-blue) !important;
          border: none !important;
        }

        /* Sidebar Styling */
        .main-sidebar {
          background-color: #ffffff !important;
          border-right: 1px solid var(--alteryx-border);
          box-shadow: 2px 0 4px rgba(0,0,0,0.05);
        }

        .sidebar-menu > li > a {
          color: var(--alteryx-text) !important;
          border-left: 3px solid transparent;
          padding: 12px 20px;
          font-weight: 500;
          transition: all 0.2s ease;
        }

        .sidebar-menu > li:hover > a,
        .sidebar-menu > li.active > a {
          background-color: var(--alteryx-light-gray) !important;
          border-left-color: var(--alteryx-blue) !important;
          color: var(--alteryx-blue) !important;
        }

        .sidebar-menu > li > a > .fa {
          color: var(--alteryx-dark-gray);
          margin-right: 10px;
        }

        .sidebar-menu > li:hover > a > .fa,
        .sidebar-menu > li.active > a > .fa {
          color: var(--alteryx-blue) !important;
        }

        /* Carousel Styling - Alteryx Design */
        .carousel-container {
          background-color: #ffffff;
          border-radius: 8px;
          padding: 24px;
          margin: 20px 0;
          box-shadow: 0 1px 3px rgba(60, 64, 67, 0.15);
          border: 1px solid var(--alteryx-border);
          min-height: 400px;
        }

        .carousel-wrapper {
          position: relative;
          overflow: hidden;
          margin: 24px 0;
        }

        .carousel-content {
          display: flex;
          transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
          align-items: flex-start;
          gap: 20px;
        }

        .file-card {
          flex-shrink: 0;
        }

        .file-card .card {
          width: 300px;
          height: 220px;
          border: 1px solid var(--alteryx-border);
          border-radius: 8px;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          background: white;
          box-shadow: 0 1px 3px rgba(60, 64, 67, 0.15);
          overflow: hidden;
        }

        .file-card:hover .card {
          transform: translateY(-4px);
          box-shadow: 0 4px 12px rgba(60, 64, 67, 0.25);
          border-color: var(--alteryx-light-blue);
        }

        .file-card.selected .card {
          border: 2px solid var(--alteryx-blue);
          box-shadow: 0 0 0 3px rgba(31, 119, 180, 0.15);
        }

        .card-header {
          background: linear-gradient(135deg, var(--alteryx-blue) 0%, var(--alteryx-dark-blue) 100%);
          color: white;
          padding: 16px;
          height: 70px;
          display: flex;
          align-items: center;
          overflow: hidden;
        }

        .card-header h5 {
          margin: 0;
          font-size: 14px;
          font-weight: 600;
          line-height: 1.3;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          -webkit-box-orient: vertical;
        }

        .card-body {
          padding: 16px;
          height: 150px;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
        }

        .card-body p {
          margin: 4px 0;
          font-size: 13px;
          color: var(--alteryx-dark-gray);
          line-height: 1.4;
        }

        .card-body strong {
          color: var(--alteryx-text);
          font-weight: 600;
        }

        .carousel-nav {
          display: flex;
          justify-content: center;
          align-items: center;
          margin: 24px 0;
          gap: 20px;
        }

        .carousel-nav h4 {
          margin: 0;
          color: var(--alteryx-text);
          font-weight: 600;
          font-size: 18px;
        }

        .carousel-btn {
          background: var(--alteryx-blue);
          color: white;
          border: none;
          border-radius: 50%;
          width: 48px;
          height: 48px;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          font-size: 16px;
          box-shadow: 0 2px 4px rgba(31, 119, 180, 0.3);
        }

        .carousel-btn:hover {
          background: var(--alteryx-dark-blue);
          transform: scale(1.05);
          box-shadow: 0 4px 12px rgba(31, 119, 180, 0.4);
        }

        .carousel-btn:disabled {
          background: var(--alteryx-medium-gray);
          color: var(--alteryx-gray);
          cursor: not-allowed;
          transform: none;
          box-shadow: none;
        }

        .carousel-indicators {
          display: flex;
          justify-content: center;
          gap: 8px;
          margin: 20px 0;
        }

        .carousel-dot {
          width: 10px;
          height: 10px;
          border-radius: 50%;
          background-color: var(--alteryx-medium-gray);
          cursor: pointer;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .carousel-dot.active {
          background-color: var(--alteryx-blue);
          transform: scale(1.3);
        }

        .carousel-dot:hover {
          background-color: var(--alteryx-light-blue);
        }

        .no-files-message {
          text-align: center;
          padding: 80px 20px;
          color: var(--alteryx-dark-gray);
        }

        .no-files-message i {
          font-size: 72px;
          color: var(--alteryx-medium-gray);
          margin-bottom: 24px;
        }

        .no-files-message h3 {
          color: var(--alteryx-text);
          font-weight: 600;
          margin-bottom: 12px;
        }

        .no-files-message p {
          color: var(--alteryx-dark-gray);
          font-size: 16px;
          margin-bottom: 24px;
        }

        .selected-file-info {
          background: linear-gradient(135deg, var(--alteryx-blue) 0%, var(--alteryx-dark-blue) 100%);
          color: white;
          border-radius: 8px;
          padding: 24px;
          margin: 20px 0;
          text-align: center;
          box-shadow: 0 2px 8px rgba(31, 119, 180, 0.3);
        }

        .selected-file-info h4 {
          margin-bottom: 16px;
          font-weight: 600;
        }

        .serve-button-large {
          background-color: #ffffff;
          color: var(--alteryx-blue);
          border: 2px solid #ffffff;
          font-weight: 600;
          padding: 16px 32px;
          font-size: 16px;
          border-radius: 6px;
          width: 100%;
          margin-top: 16px;
          transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .serve-button-large:hover {
          background-color: rgba(255, 255, 255, 0.9);
          color: var(--alteryx-dark-blue);
          transform: translateY(-2px);
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
        }

        /* Upload Section Styling */
        .upload-section {
          padding: 20px;
        }

        .upload-section .form-group {
          margin-bottom: 20px;
        }

        .upload-section label {
          font-weight: 600;
          color: var(--alteryx-text);
          margin-bottom: 8px;
          display: block;
        }

        /* DataTable Styling */
        .dataTables_wrapper {
          font-family: 'Open Sans', sans-serif;
        }

        .dataTables_wrapper .dataTables_length,
        .dataTables_wrapper .dataTables_filter,
        .dataTables_wrapper .dataTables_info,
        .dataTables_wrapper .dataTables_processing,
        .dataTables_wrapper .dataTables_paginate {
          color: var(--alteryx-text);
        }

        table.dataTable thead th {
          background-color: var(--alteryx-light-gray);
          color: var(--alteryx-text);
          font-weight: 600;
          border-bottom: 2px solid var(--alteryx-border);
        }

        table.dataTable tbody tr:hover {
          background-color: var(--alteryx-light-gray);
        }

        table.dataTable tbody tr.selected {
          background-color: rgba(31, 119, 180, 0.1);
        }

        /* Modal Styling */
        .modal-content {
          border-radius: 8px;
          border: none;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
        }

        .modal-header {
          background-color: var(--alteryx-light-gray);
          border-bottom: 1px solid var(--alteryx-border);
          border-radius: 8px 8px 0 0;
        }

        .modal-title {
          color: var(--alteryx-text);
          font-weight: 600;
        }

        /* Notification Styling */
        .shiny-notification {
          border-radius: 6px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
          border: none;
        }

        .shiny-notification.shiny-notification-message {
          background-color: var(--alteryx-blue);
          color: white;
        }

        .shiny-notification.shiny-notification-warning {
          background-color: var(--alteryx-orange);
          color: white;
        }

        .shiny-notification.shiny-notification-error {
          background-color: var(--alteryx-red);
          color: white;
        }
        }
      "))
    ),

    # JavaScript for carousel and file serving
    tags$script(HTML("
      let currentIndex = 0;
      let totalFiles = 0;
      let selectedFile = null;

      function updateCarousel() {
        const content = document.querySelector('.carousel-content');
        const cardWidth = 300; // Width including margins
        const visibleCards = Math.floor(window.innerWidth / cardWidth);
        const maxIndex = Math.max(0, totalFiles - visibleCards);

        currentIndex = Math.min(currentIndex, maxIndex);

        if (content) {
          content.style.transform = `translateX(-${currentIndex * cardWidth}px)`;
        }

        // Update navigation buttons
        const prevBtn = document.getElementById('carousel-prev');
        const nextBtn = document.getElementById('carousel-next');

        if (prevBtn) prevBtn.disabled = currentIndex === 0;
        if (nextBtn) nextBtn.disabled = currentIndex >= maxIndex;

        // Update indicators
        updateIndicators();
      }

      function moveCarousel(direction) {
        const cardWidth = 300;
        const visibleCards = Math.floor(window.innerWidth / cardWidth);
        const maxIndex = Math.max(0, totalFiles - visibleCards);

        if (direction === 'next' && currentIndex < maxIndex) {
          currentIndex++;
        } else if (direction === 'prev' && currentIndex > 0) {
          currentIndex--;
        }

        updateCarousel();
      }

      function goToSlide(index) {
        currentIndex = index;
        updateCarousel();
      }

      function updateIndicators() {
        const indicators = document.querySelectorAll('.carousel-dot');
        indicators.forEach((dot, index) => {
          dot.classList.toggle('active', index === currentIndex);
        });
      }

      function selectFile(filename) {
        // Remove previous selection
        document.querySelectorAll('.file-card').forEach(card => {
          card.classList.remove('selected');
        });

        // Add selection to current card
        event.currentTarget.classList.add('selected');

        selectedFile = filename;
        Shiny.setInputValue('selected_file_carousel', filename);
      }

      function serveFile(filename) {
        Shiny.setInputValue('serve_file_carousel', filename, {priority: 'event'});
      }

      Shiny.addCustomMessageHandler('openFullScreen', function(data) {
        // Open the report in a new window with close button
        var reportWindow = window.open('', '_blank', 'width=1400,height=900,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no');

        // Create the HTML content with embedded report and close button
        var htmlContent = '<!DOCTYPE html>' +
          '<html>' +
          '<head>' +
          '<title>' + (data.filename || 'Report') + '</title>' +
          '<style>' +
          '* { margin: 0; padding: 0; box-sizing: border-box; }' +
          'body { font-family: \"Open Sans\", -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif; background-color: #f7f8fa; overflow: hidden; }' +
          '.report-header { background: linear-gradient(135deg, #1f77b4 0%, #1a5490 100%); color: white; padding: 12px 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 4px rgba(0,0,0,0.1); z-index: 1000; position: relative; }' +
          '.report-title { font-size: 16px; font-weight: 600; margin: 0; display: flex; align-items: center; gap: 10px; }' +
          '.close-btn { background: rgba(255, 255, 255, 0.2); border: 1px solid rgba(255, 255, 255, 0.3); color: white; padding: 8px 16px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 500; transition: all 0.2s ease; display: flex; align-items: center; gap: 6px; }' +
          '.close-btn:hover { background: rgba(255, 255, 255, 0.3); border-color: rgba(255, 255, 255, 0.5); transform: translateY(-1px); }' +
          '.report-container { width: 100%; height: calc(100vh - 50px); border: none; display: block; }' +
          '</style>' +
          '</head>' +
          '<body>' +
          '<div class=\"report-header\">' +
          '<h1 class=\"report-title\">' +
          '<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"currentColor\">' +
          '<path d=\"M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zM9 17H7v-7h2v7zm4 0h-2V7h2v10zm4 0h-2v-4h2v4z\"/>' +
          '</svg>' +
          '</h1>' +
          '</div>' +
          '<iframe class=\"report-container\" src=\"' + data.url + '\"></iframe>' +
          '</body>' +
          '</html>';

        reportWindow.document.write(htmlContent);
        reportWindow.document.close();
        reportWindow.focus();
      });

      Shiny.addCustomMessageHandler('updateCarouselData', function(data) {
        totalFiles = data.totalFiles;
        updateCarousel();
      });

      // Handle window resize
      window.addEventListener('resize', updateCarousel);
    ")),

    tabItems(
      # File Carousel Tab
      tabItem(tabName = "carousel",
        fluidRow(
          box(
            title = "Available Reports", status = "primary", solidHeader = TRUE,
            width = 12,

            # Carousel container
            div(class = "carousel-container",
              conditionalPanel(
                condition = "output.has_files",

                # Carousel wrapper
                div(class = "carousel-wrapper",
                  div(class = "carousel-content",
                    uiOutput("carousel_files")
                  )
                ),

                # Carousel indicators
                div(class = "carousel-indicators",
                  uiOutput("carousel_indicators")
                )
              )
            )
          )
        ),

        # Selected file information and serve button
        conditionalPanel(
          condition = "input.selected_file_carousel",
          fluidRow(
            box(
              title = "Selected File", status = "success", solidHeader = TRUE,
              width = 12,
              div(class = "selected-file-info",
                h4("Ready to Serve", style = "margin-bottom: 15px;"),
                textOutput("selected_file_display"),
                actionButton("serve_selected", "Open in Full Screen",
                           class = "serve-button-large",
                           icon = icon("expand-arrows-alt"))
              )
            )
          )
        )
      ),

      # Upload Tab
      tabItem(tabName = "upload",
        fluidRow(
          box(
            title = "Upload HTML File", status = "primary", solidHeader = TRUE,
            width = 12,
            div(class = "upload-section",
              fileInput("file", "Choose HTML File",
                       accept = c(".html", ".htm"),
                       multiple = TRUE,  # Allow multiple files
                       width = "100%"),
              br(),
              actionButton("upload_btn", "Save Files", class = "btn-success", icon = icon("save")),
              br(), br(),
              div(id = "upload_status_container",
                verbatimTextOutput("upload_status")
              )
            )
          )
        )
      ),

      # File Manager Tab
      tabItem(tabName = "manager",
        fluidRow(
          box(
            title = "File Management", status = "primary", solidHeader = TRUE,
            width = 12,
            h4("Uploaded HTML Files", style = "color: #495057; margin-bottom: 20px;"),
            DT::dataTableOutput("files_table"),
            br(),
            div(style = "text-align: center;",
              actionButton("refresh_btn", "Refresh List", class = "btn-info", icon = icon("sync-alt")),
              actionButton("delete_btn", "Delete Selected", class = "btn-danger", icon = icon("trash-alt"))
            )
          )
        )
      )
    )
  )
)
