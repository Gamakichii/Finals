# Quick Start Guide

## 🚀 Getting Started in 3 Steps

### Step 1: Ensure Docker is Running
Make sure Docker Desktop is installed and running on your machine.

### Step 2: Run the Startup Script
Open PowerShell and navigate to the project directory, then run:

```powershell
.\start.ps1
```

Or manually with docker-compose:

```powershell
docker-compose up --build
```

### Step 3: Access the Application
- **Backend API**: http://localhost:8000
- **Chrome Browser**: Will automatically open with the extension loaded

## 📝 What You Need

Before running, ensure you have these model files in the `Backend/` directory:
- `phishing_autoencoder_model.keras`
- `scaler.pkl` (or `scaler_final.pkl`)
- `autoencoder_threshold.txt`

## 🎯 Key Points

1. **Backend URL**: The frontend extension is configured to use `http://backend:8000` (Docker internal network)
2. **Chrome Extension**: Pre-loaded and ready to detect phishing links on Facebook
3. **Networking**: Both services communicate via Docker's internal network

## 🔧 Configuration

To change settings, edit the `.env` file (copy from `.env.example`):

```powershell
cp .env.example .env
```

## 🛑 Stopping the Application

```powershell
docker-compose down
```

## 📊 Monitoring

View logs in real-time:

```powershell
docker-compose logs -f
```

## 🐛 Troubleshooting

### Backend not starting?
```powershell
docker-compose logs backend
```

### Extension not working?
1. Check if backend is healthy: `curl http://localhost:8000/ready`
2. Verify Chrome container is running: `docker-compose ps`

### Port conflicts?
Edit `docker-compose.yml` and change the port mappings:
```yaml
ports:
  - "8081:8000"  # Change 8000 to 8081
```

## 📚 Full Documentation

See [README.md](README.md) for complete documentation.

## ✅ Verify Installation

Test the backend:
```powershell
curl http://localhost:8000/
```

Expected response:
```json
{"status":"healthy","service":"dakugumen-phishing-detector"}
```

That's it! Your dockerized phishing detector is ready to use! 🎉
