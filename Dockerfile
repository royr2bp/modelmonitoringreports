# Use the official R base image with Shiny Server
FROM rocker/shiny:latest

# Set the maintainer label
LABEL maintainer="riddhiman.roy@bharatpe.com"

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

# Create the app directory
WORKDIR /srv/shiny-server

# Copy the Shiny app files
COPY app.R .
COPY global.R .
COPY server.R .
COPY ui.R .

# Create necessary directories with proper permissions
RUN mkdir -p uploads && \
    chown -R shiny:shiny /srv/shiny-server && \
    chmod -R 755 /srv/shiny-server

# Copy any existing files to the appropriate directories
COPY uploads/ ./uploads/

# Ensure proper permissions for all directories
RUN chown -R shiny:shiny /srv/shiny-server && \
    chmod -R 755 /srv/shiny-server

# Expose the port that Shiny Server runs on
EXPOSE 3838

# Configure Shiny Server
RUN echo "run_as shiny;" > /etc/shiny-server/shiny-server.conf && \
    echo "server {" >> /etc/shiny-server/shiny-server.conf && \
    echo "  listen 3838;" >> /etc/shiny-server/shiny-server.conf && \
    echo "  location / {" >> /etc/shiny-server/shiny-server.conf && \
    echo "    site_dir /srv/shiny-server;" >> /etc/shiny-server/shiny-server.conf && \
    echo "    log_dir /var/log/shiny-server;" >> /etc/shiny-server/shiny-server.conf && \
    echo "    directory_index on;" >> /etc/shiny-server/shiny-server.conf && \
    echo "  }" >> /etc/shiny-server/shiny-server.conf && \
    echo "}" >> /etc/shiny-server/shiny-server.conf


LABEL security.cap_drop="ALL"
LABEL security.cap_add="SETGID,SETUID,DAC_OVERRIDE"

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
