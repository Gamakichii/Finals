# Docker Setup Summary

## 📦 Files Created

### Backend
- ✅ `Backend/Dockerfile` - Multi-stage Docker image for Flask API
- ✅ `Backend/requirements.txt` - Python dependencies
- ✅ `Backend/.dockerignore` - Exclude unnecessary files from build

### Frontend  
- ✅ `Frontend/Dockerfile` - Chrome browser with extension pre-installed
- ✅ `Frontend/.dockerignore` - Exclude unnecessary files from build
- ✅ `Frontend/extension_dist/config.js` - Configuration for API URL

### Root Directory
- ✅ `docker-compose.yml` - Orchestration for both services
- ✅ `docker-compose.dev.yml` - Development overrides
- ✅ `.env.example` - Environment variable template
- ✅ `README.md` - Comprehensive documentation
- ✅ `QUICKSTART.md` - Quick start guide
- ✅ `start.ps1` - PowerShell startup script

### Modified Files
- ✅ `Frontend/extension_dist/background.js` - Updated API URL to support Docker networking
- ✅ `Frontend/extension_dist/manifest.json` - Added Docker host permissions

## 🔧 Key Changes

### 1. Backend Configuration
- **Port**: 8000 (configurable via environment)
- **Host**: 0.0.0.0 (accessible from Docker network)
- **Health Check**: Enabled with `/` endpoint
- **Dependencies**: All Python packages in requirements.txt

### 2. Frontend Configuration
- **API URL**: `http://backend:8000` (Docker internal network)
- **Chrome**: Runs in headless mode with extension loaded
- **Remote Debug**: Port 9222 exposed for debugging
- **Persistence**: Chrome user data stored in Docker volume

### 3. Networking
- **Network Name**: `phishing-detector-network`
- **Type**: Bridge network
- **Communication**: Frontend → Backend via service name `backend`

## 🎯 Architecture

```
┌─────────────────────────────────────────────────┐
│                  Docker Host                     │
│                                                  │
│  ┌────────────────────────────────────────────┐ │
│  │  phishing-detector-network (Bridge)        │ │
│  │                                            │ │
│  │  ┌──────────────┐      ┌───────────────┐ │ │
│  │  │   Backend    │      │   Frontend    │ │ │
│  │  │   (Flask)    │◄─────┤   (Chrome)    │ │ │
│  │  │   :8000      │      │   :9222       │ │ │
│  │  └──────┬───────┘      └───────────────┘ │ │
│  │         │                                  │ │
│  └─────────┼──────────────────────────────────┘ │
│            │                                     │
│  ┌─────────▼───────────────────────────────┐   │
│  │  Volumes:                                │   │
│  │  - chrome-data (persist Chrome state)    │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
│  Exposed Ports:                                 │
│  - localhost:8000 → backend:8000                │
│  - localhost:9222 → frontend:9222               │
└─────────────────────────────────────────────────┘
```

## 🚀 How to Run

### Option 1: Use the PowerShell Script (Recommended)
```powershell
.\start.ps1
```

### Option 2: Manual Docker Compose
```powershell
# Build and start
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Option 3: Development Mode (with live reload)
```powershell
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up --build
```

## ✅ Verification Steps

### 1. Check Backend Health
```powershell
curl http://localhost:8000/
```
Expected: `{"status":"healthy","service":"dakugumen-phishing-detector"}`

### 2. Check Backend Readiness
```powershell
curl http://localhost:8000/ready
```
Expected: `{"models_ready":true,"error":null}`

### 3. Check Containers
```powershell
docker-compose ps
```
Expected: Both `backend` and `frontend` in "Up" state

### 4. Test Extension
1. Access Chrome remote debugging: http://localhost:9222
2. Navigate to Facebook in the containerized browser
3. Extension should be active and scanning posts

## 🔑 Environment Variables

### Backend
| Variable | Default | Description |
|----------|---------|-------------|
| PORT | 8000 | Backend server port |
| AE_WEIGHT | 0.6 | Autoencoder weight in scoring |
| FINAL_SCORE_CUTOFF | 0.5 | Phishing decision threshold |
| RESOLVE_SHORTENERS | 1 | Enable URL shortener resolution |

### Frontend
| Variable | Default | Description |
|----------|---------|-------------|
| API_BASE_URL | http://backend:8000 | Backend API endpoint |
| SE_SCREEN_WIDTH | 1920 | Chrome window width |
| SE_SCREEN_HEIGHT | 1080 | Chrome window height |

## 📊 Monitoring & Debugging

### View Logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Check Resource Usage
```powershell
docker stats
```

### Access Container Shell
```powershell
# Backend
docker exec -it phishing-detector-backend /bin/bash

# Frontend
docker exec -it phishing-detector-frontend /bin/bash
```

### Inspect Network
```powershell
docker network inspect finals_phishing-detector-network
```

## 🐛 Common Issues & Solutions

### Issue: Backend not starting
**Solution**: Check if model files exist
```powershell
docker-compose logs backend
```

### Issue: Extension not loading
**Solution**: Verify manifest.json and permissions
```powershell
docker exec -it phishing-detector-frontend ls -la /home/seluser/extension
```

### Issue: API connection failed
**Solution**: Verify network connectivity
```powershell
docker exec -it phishing-detector-frontend curl http://backend:8000/
```

### Issue: Port already in use
**Solution**: Change port mapping in docker-compose.yml
```yaml
ports:
  - "8081:8000"  # Change host port
```

## 🔐 Security Considerations

1. **Firestore Credentials**: Never commit credentials to Git
2. **API Access**: Backend allows CORS from all origins (for Chrome extension)
3. **Chrome Sandbox**: Running in container provides isolation
4. **Network**: Internal Docker network prevents external access to inter-service communication

## 📝 Next Steps

1. ✅ Build and test locally
2. ⬜ Deploy to cloud (AWS, Azure, GCP)
3. ⬜ Add CI/CD pipeline
4. ⬜ Implement authentication
5. ⬜ Add monitoring and alerting

## 🎓 Development Tips

### Hot Reload Backend
The dev override mounts source code as volume:
```powershell
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```

### Update Extension
Rebuild frontend container after changes:
```powershell
docker-compose up --build frontend
```

### Clear Cache
Remove all containers and volumes:
```powershell
docker-compose down -v
docker-compose up --build
```

## 📚 Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Flask in Docker](https://flask.palletsprojects.com/en/2.3.x/deploying/)
- [Chrome Extension Development](https://developer.chrome.com/docs/extensions/)

---

**Status**: ✅ Complete and ready for local deployment
**Last Updated**: 2025-10-14
