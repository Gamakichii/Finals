# Facebook Phishing Detector - Docker Setup

This project consists of a Flask backend API for phishing detection and a Chrome extension frontend that runs in a containerized Chrome browser.

## 🏗️ Architecture

- **Backend**: Flask API with ML models for phishing detection
- **Frontend**: Chrome extension pre-installed in a containerized Chrome browser
- **Networking**: Both services communicate via Docker network

## 📋 Prerequisites

- Docker Desktop installed and running
- Docker Compose (included with Docker Desktop)
- At least 4GB of RAM available for Docker

## 🚀 Quick Start

### Option A: Pull Pre-built Images (⭐ Recommended - No Build Required!)

**Perfect for running on other PCs or quick deployment!**

The images are already available on Docker Hub at:
- `gamamochi/phishing-detector-backend:latest`
- `gamamochi/phishing-detector-frontend:latest`

**Simple 3-step setup:**

1. **Clone the repository:**
```powershell
git clone https://github.com/Gamakichii/Finals.git
cd Finals
```

2. **Pull and run the containers:**
```powershell
docker compose -f docker-compose.pull.yml up -d
```

3. **Access the application:**
   - Open your browser and go to: **http://localhost:6080**
   - The Chrome browser with the phishing detector extension will load automatically!

**Stopping the application:**
```powershell
docker compose -f docker-compose.pull.yml down
```

**📖 For more details, see [DOCKER_HUB_SETUP.md](DOCKER_HUB_SETUP.md)**

---

### Option B: Build from Source (Development)

Use this option if you want to modify the code or build the images yourself.

### 1. Clone or navigate to the project directory

```powershell
cd "d:\Vanderlei\4th Year\1st Sem\ProgMan\Finals"
```

### 2. Ensure model files exist in Backend directory

Make sure you have the following model files in the `Backend/` directory:
- `phishing_autoencoder_model.keras`
- `scaler.pkl` or `scaler_final.pkl`
- `autoencoder_threshold.txt`
- (Optional) `gnn_probs.npy`, `post_node_map.json`, `fusion_config.json`

### 3. Build and start the containers

```powershell
docker-compose up --build
```

Or run in detached mode (background):

```powershell
docker-compose up -d --build
```

### 4. Access the application

- **Backend API**: http://localhost:8000
- **Chrome Remote Debug**: http://localhost:9222
- **Frontend Chrome**: The Chrome browser will automatically open with the extension loaded

## 🔧 Configuration

### Environment Variables

You can customize the application by creating a `.env` file in the root directory (copy from `.env.example`):

```powershell
cp .env.example .env
```

Key configuration options:

#### Backend
- `PORT`: Backend server port (default: 8000)
- `AE_WEIGHT`: Autoencoder weight in scoring (default: 0.6)
- `FINAL_SCORE_CUTOFF`: Phishing decision threshold (default: 0.5)
- `GOOGLE_APPLICATION_CREDENTIALS_JSON`: Firestore credentials (optional)

#### Frontend
- `API_BASE_URL`: Backend API URL (default: http://backend:8000)

### Firestore Integration (Optional)

If you want to enable Firestore for storing reports:

1. Get your Google Cloud service account JSON file
2. Convert it to a single-line string
3. Add it to `.env` as `GOOGLE_APPLICATION_CREDENTIALS_JSON`

## 🛠️ Docker Commands

### View logs

```powershell
# All services
docker-compose logs -f

# Backend only
docker-compose logs -f backend

# Frontend only
docker-compose logs -f frontend
```

### Stop the application

```powershell
docker-compose down
```

### Stop and remove volumes

```powershell
docker-compose down -v
```

### Rebuild containers

```powershell
docker-compose up --build
```

### Check service status

```powershell
docker-compose ps
```

## 🧪 Testing the Setup

### 1. Test Backend API

```powershell
# Health check
curl http://localhost:8000/

# Check if models are ready
curl http://localhost:8000/ready
```

### 2. Test Frontend

1. The Chrome browser should automatically start with the extension loaded
2. Navigate to Facebook: https://www.facebook.com
3. The extension should be active and scanning for phishing links

### 3. Verify Extension Installation

- Open Chrome DevTools in the container (accessible via remote debugging)
- Check that the extension is loaded in `chrome://extensions`
- The extension icon should appear in the toolbar

## 🐛 Troubleshooting

### Backend won't start

1. Check if model files exist in `Backend/` directory
2. View logs: `docker-compose logs backend`
3. Verify Python dependencies in `requirements.txt`

### Frontend Chrome won't open

1. Ensure backend is healthy: `docker-compose ps`
2. Check frontend logs: `docker-compose logs frontend`
3. Verify shared memory: `docker stats`

### Extension not loading

1. Check manifest.json permissions
2. Verify extension files are copied to container
3. Check browser console for errors

### API connection errors

1. Verify backend is running: `curl http://localhost:8000/`
2. Check Docker network: `docker network ls`
3. Ensure `API_BASE_URL` is set correctly in frontend

### Port conflicts

If ports 8000 or 9222 are already in use:

1. Edit `docker-compose.yml`
2. Change port mappings (e.g., `"8081:8000"`)
3. Update `API_BASE_URL` accordingly

## 📁 Project Structure

```
Finals/
├── Backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app.py
│   └── [model files]
├── Frontend/
│   ├── Dockerfile
│   └── extension_dist/
│       ├── manifest.json
│       ├── background.js
│       ├── content_script.js
│       ├── popup.html
│       ├── popup.js
│       ├── popup.css
│       ├── config.js
│       └── icons/
├── docker-compose.yml
├── .env.example
└── README.md
```

## 🔄 Development Workflow

### Making changes to Backend

1. Edit files in `Backend/`
2. Rebuild: `docker-compose up --build backend`

### Making changes to Frontend

1. Edit files in `Frontend/extension_dist/`
2. Rebuild: `docker-compose up --build frontend`

### Hot reload (using volumes)

The docker-compose.yml mounts the Backend directory as a volume, so changes to Python files will be reflected after restarting the container.

## 🌐 API Endpoints

### Backend API

- `GET /` - Health check
- `GET /ready` - Check if models are loaded
- `POST /predict` - Single URL prediction
- `POST /predict_batch` - Batch URL prediction
- `GET /flagged_links` - Get flagged phishing links
- `POST /flag` - Flag a URL as phishing
- `POST /report` - Submit user report
- `POST /reload_models` - Reload ML models

### Example API Call

```powershell
# PowerShell
$body = @{
    url = "https://example.com/suspicious-link"
    post_id = "12345"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/predict" -Method Post -Body $body -ContentType "application/json"
```

## 📊 Monitoring

### View Chrome browser activity

Access Chrome Remote Debugging at: http://localhost:9222

### Check container resource usage

```powershell
docker stats
```

### View network connections

```powershell
docker network inspect finals_phishing-detector-network
```

## 🛡️ Security Notes

- The Chrome container runs in a sandboxed environment
- Backend exposes only necessary ports
- Firestore credentials should be kept secure (use environment variables)
- Consider adding authentication for production deployments

## 👥 Contributors

DaKuGuMen

## 🙋 Support

For issues or questions, please refer to the troubleshooting section or contact the development team.
