# Docker Deployment Guide

## Building and Running the Application

### Using Docker Compose (Recommended)

1. **Build and start the application:**
   ```bash
   docker-compose up --build
   ```

2. **Run in background:**
   ```bash
   docker-compose up -d --build
   ```

3. **Stop the application:**
   ```bash
   docker-compose down
   ```

4. **View logs:**
   ```bash
   docker-compose logs -f
   ```

### Using Docker directly

1. **Build the Docker image:**
   ```bash
   docker build -t modelmonitoringreports .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     --name shiny-reports \
     -p 3838:3838 \
     -v $(pwd)/uploads:/srv/shiny-server/uploads \
     modelmonitoringreports
   ```

3. **Stop and remove the container:**
   ```bash
   docker stop shiny-reports
   docker rm shiny-reports
   ```

## Accessing the Application

Once running, access the application at: `http://localhost:3838`

## Volume Mounts

The Docker setup includes persistent volume mounts for:
- `uploads/` - Stores uploaded HTML files

## Troubleshooting

1. **Check container logs:**
   ```bash
   docker logs shiny-reports
   ```

2. **Access container shell:**
   ```bash
   docker exec -it shiny-reports /bin/bash
   ```

3. **Check if app is running:**
   ```bash
   curl http://localhost:3838
   ```

## Production Considerations

- Use environment variables for configuration
- Set up proper logging and monitoring
- Consider using a reverse proxy (nginx) for HTTPS
- Implement proper backup strategy for uploaded files
- Use secrets management for sensitive data
