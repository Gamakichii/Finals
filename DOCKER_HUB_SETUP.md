# Docker Hub Deployment Guide

This guide explains how to use the pre-built Docker images from Docker Hub.

## 🎯 Pre-built Images Available

The following images are already published and ready to use:
- **Backend**: `gamamochi/phishing-detector-backend:latest`
- **Frontend**: `gamamochi/phishing-detector-frontend:latest`

---

## For End Users (Pull and Run)

### Prerequisites
- Docker Desktop installed
- Internet connection to pull images

### Quick Start

1. Clone the repository:
```powershell
git clone https://github.com/Gamakichii/Finals.git
cd Finals
```

2. Pull and run the containers:
```powershell
docker compose -f docker-compose.pull.yml up -d
```

3. Access the application:
- Open your browser and navigate to: **http://localhost:6080**
- The Chrome browser with the extension will load automatically

### Stopping the Application
```powershell
docker compose -f docker-compose.pull.yml down
```

### Updating to Latest Version
```powershell
docker compose -f docker-compose.pull.yml pull
docker compose -f docker-compose.pull.yml up -d
```

---

## For Developers (Update Images)

### 1. Tag and Push Images to Docker Hub

First, make sure you're logged in to Docker Hub:
```powershell
docker login
```

Build and tag your local images:
```powershell
# Build the images
docker compose build

# Tag them with your Docker Hub username
docker tag finals-backend gamamochi/phishing-detector-backend:latest
docker tag finals-frontend gamamochi/phishing-detector-frontend:latest
```

Push the images to Docker Hub:
```powershell
docker push gamamochi/phishing-detector-backend:latest
docker push gamamochi/phishing-detector-frontend:latest
```

### 2. (Optional) Make Images Public

1. Go to https://hub.docker.com/u/gamamochi
2. Navigate to each repository
3. Click "Settings" → "Make Public" (so others can pull without authentication)

---

## For Other Users (Pull and Run)

### Prerequisites
- Docker Desktop installed
- Internet connection to pull images

### Quick Start

1. Clone the repository:
```powershell
git clone https://github.com/Gamakichii/Finals.git
cd Finals
```

2. Pull and run the containers:
```powershell
# Using the pull configuration
docker compose -f docker-compose.pull.yml pull
docker compose -f docker-compose.pull.yml up -d
```

Or as a one-liner:
```powershell
docker compose -f docker-compose.pull.yml up -d
```

4. Access the application:
- Open your browser and navigate to: http://localhost:6080
- The Chrome browser with the extension will load automatically

### Stopping the Application
```powershell
docker compose -f docker-compose.pull.yml down
```

### Updating to Latest Version
```powershell
docker compose -f docker-compose.pull.yml pull
docker compose -f docker-compose.pull.yml up -d
```

## Troubleshooting

### "no matching manifest" error
- Make sure the images were pushed successfully
- Check that the images exist at: 
  - https://hub.docker.com/r/gamamochi/phishing-detector-backend
  - https://hub.docker.com/r/gamamochi/phishing-detector-frontend

### "unauthorized" error
- If images are private, run `docker login` first
- Or make the images public on Docker Hub

### Port conflicts
If ports 6080, 8000, 5901, or 9222 are already in use, edit `docker-compose.pull.yml` and change the port mappings:
```yaml
ports:
  - "8080:6080"  # Change 6080 to 8080 on the left side
```

## Alternative: Using Docker Hub Images Without Git Clone

If you don't want to clone the repository, create a minimal `docker-compose.yml`:

```yaml
services:
  backend:
    image: gamamochi/phishing-detector-backend:latest
    ports:
      - "8000:8000"
    environment:
      - PORT=8000
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    image: gamamochi/phishing-detector-frontend:latest
    ports:
      - "6080:6080"
    environment:
      - API_BASE_URL=http://backend:8000
    depends_on:
      backend:
        condition: service_healthy
    restart: unless-stopped
    shm_size: 2gb
    volumes:
      - chrome-data:/home/chrome/.config/google-chrome

volumes:
  chrome-data:
```

Then run:
```powershell
docker compose up -d
```
