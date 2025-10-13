# Facebook Phishing Detector - Docker Startup Script
# This script builds and starts the dockerized application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Facebook Phishing Detector - Docker Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker version | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if docker-compose exists
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
try {
    docker-compose version | Out-Null
    Write-Host "✓ Docker Compose is available" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker Compose is not available. Please install Docker Desktop with Compose." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Navigate to project directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Project directory: $scriptPath" -ForegroundColor Cyan
Write-Host ""

# Check for model files
Write-Host "Checking for model files..." -ForegroundColor Yellow
$modelFiles = @(
    "Backend\phishing_autoencoder_model.keras",
    "Backend\scaler.pkl",
    "Backend\autoencoder_threshold.txt"
)

$missingFiles = @()
foreach ($file in $modelFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (missing)" -ForegroundColor Yellow
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠ Warning: Some model files are missing." -ForegroundColor Yellow
    Write-Host "The backend may not work properly without these files." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Setup cancelled." -ForegroundColor Red
        exit 0
    }
}

Write-Host ""

# Ask user for build option
Write-Host "Build Options:" -ForegroundColor Cyan
Write-Host "  1. Build and start (recommended for first time)" -ForegroundColor White
Write-Host "  2. Start without building (faster if already built)" -ForegroundColor White
Write-Host "  3. Stop containers" -ForegroundColor White
Write-Host "  4. View logs" -ForegroundColor White
Write-Host "  5. Clean up (stop and remove volumes)" -ForegroundColor White
Write-Host ""
$option = Read-Host "Select option (1-5)"

switch ($option) {
    "1" {
        Write-Host ""
        Write-Host "Building and starting containers..." -ForegroundColor Cyan
        docker-compose up --build -d
    }
    "2" {
        Write-Host ""
        Write-Host "Starting containers..." -ForegroundColor Cyan
        docker-compose up -d
    }
    "3" {
        Write-Host ""
        Write-Host "Stopping containers..." -ForegroundColor Cyan
        docker-compose down
        Write-Host ""
        Write-Host "✓ Containers stopped" -ForegroundColor Green
        exit 0
    }
    "4" {
        Write-Host ""
        Write-Host "Showing logs (Ctrl+C to exit)..." -ForegroundColor Cyan
        docker-compose logs -f
        exit 0
    }
    "5" {
        Write-Host ""
        Write-Host "⚠ This will remove all containers and volumes!" -ForegroundColor Yellow
        $confirm = Read-Host "Are you sure? (y/N)"
        if ($confirm -eq "y" -or $confirm -eq "Y") {
            docker-compose down -v
            Write-Host ""
            Write-Host "✓ Cleanup complete" -ForegroundColor Green
        } else {
            Write-Host "Cleanup cancelled" -ForegroundColor Yellow
        }
        exit 0
    }
    default {
        Write-Host ""
        Write-Host "Invalid option. Exiting." -ForegroundColor Red
        exit 1
    }
}

# Wait for services to be ready
Write-Host ""
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check backend health
Write-Host ""
Write-Host "Checking backend health..." -ForegroundColor Yellow
$maxRetries = 12
$retryCount = 0
$backendReady = $false

while ($retryCount -lt $maxRetries -and -not $backendReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/" -TimeoutSec 2 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host "✓ Backend is ready!" -ForegroundColor Green
        }
    } catch {
        $retryCount++
        Write-Host "  Waiting... ($retryCount/$maxRetries)" -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

if (-not $backendReady) {
    Write-Host "⚠ Backend is not responding. Check logs with: docker-compose logs backend" -ForegroundColor Yellow
}

# Display service information
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Services are starting!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend API:         http://localhost:8000" -ForegroundColor White
Write-Host "Chrome Browser:      http://localhost:6080" -ForegroundColor Cyan
Write-Host "Chrome Remote Debug: http://localhost:9222" -ForegroundColor White
Write-Host ""
Write-Host "Access Chrome GUI:" -ForegroundColor Yellow
Write-Host "  Open your web browser and go to:" -ForegroundColor White
Write-Host "  http://localhost:6080" -ForegroundColor Green
Write-Host ""
Write-Host "  Chrome will open automatically with:" -ForegroundColor White
Write-Host "  - Your phishing detector extension loaded" -ForegroundColor White
Write-Host "  - Facebook.com opened in the browser" -ForegroundColor White
Write-Host "  - Connected to backend at http://backend:8000" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  View logs:    docker-compose logs -f" -ForegroundColor White
Write-Host "  Stop:         docker-compose down" -ForegroundColor White
Write-Host "  Restart:      docker-compose restart" -ForegroundColor White
Write-Host "  Status:       docker-compose ps" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop following logs, or close this window." -ForegroundColor Yellow
Write-Host ""

# Follow logs
docker-compose logs -f
