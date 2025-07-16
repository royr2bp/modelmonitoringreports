# Use the official R base image with Shiny Server
FROM rocker/shiny:latest

# Install system dependencies
USER root

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libxt6 \
    r-cran-sodium \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'htmltools', 'shinyjs', 'sodium', 'scrypt'), repos='https://cran.rstudio.com/')"

# Install shinyauthr from GitHub
RUN R -e "install.packages('remotes', repos='https://cran.rstudio.com/'); remotes::install_github('paulc91/shinyauthr')"

# Remove the default shiny app
RUN rm -rf /srv/shiny-server/*

# Create the app directory and set up permissions (as root)
WORKDIR /srv/shiny-server

# Configure Shiny Server (as root)
RUN echo "run_as shiny;" > /etc/shiny-server/shiny-server.conf && \
    echo "server {" >> /etc/shiny-server/shiny-server.conf && \
    echo "  listen 3838;" >> /etc/shiny-server/shiny-server.conf && \
    echo "  location / {" >> /etc/shiny-server/shiny-server.conf && \
    echo "    site_dir /srv/shiny-server;" >> /etc/shiny-server/shiny-server.conf && \
    echo "    log_dir /var/log/shiny-server;" >> /etc/shiny-server/shiny-server.conf && \
    echo "    directory_index on;" >> /etc/shiny-server/shiny-server.conf && \
    echo "  }" >> /etc/shiny-server/shiny-server.conf && \
    echo "}" >> /etc/shiny-server/shiny-server.conf

# Create the uploads directory
RUN mkdir -p uploads

# Copy the Shiny app files
COPY app.R .
COPY global.R .
COPY server.R .
COPY ui.R .

# Copy uploads directory contents (if any exist)
COPY uploads/ ./uploads/

# Fix ownership after copying files
RUN chown -R shiny:shiny /srv/shiny-server
RUN chown -R shiny:shiny /srv/shiny-server/uploads
RUN chmod -R 775 /srv/shiny-server/
RUN chmod -R 775 /srv/shiny-server/uploads

# Change to non-root user (do this last)
USER shiny

# Expose the port that Shiny Server runs on
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
