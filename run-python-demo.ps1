# Simple Python Demo - Blue-Green Deployment Simulation
# Run this without Docker to see the Blue-Green concept

Write-Host "========================================" -ForegroundColor Green
Write-Host "Blue-Green Deployment - Python Demo" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check Python
Write-Host "[1/6] Checking Python..." -ForegroundColor Yellow
$pythonVersion = python --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Python found: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Python not found. Please install Python." -ForegroundColor Red
    exit 1
}

# Install dependencies
Write-Host ""
Write-Host "[2/6] Installing dependencies..." -ForegroundColor Yellow
Set-Location app
pip install -q -r requirements.txt
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..

# Start Blue version in background
Write-Host ""
Write-Host "[3/6] Starting Blue version (port 5001)..." -ForegroundColor Yellow
$env:APP_VERSION = "blue"
$env:APP_PORT = "5001"
$env:ENVIRONMENT = "development"
$blueProcess = Start-Process python -ArgumentList "app/app.py" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3
Write-Host "✓ Blue version started (PID: $($blueProcess.Id))" -ForegroundColor Green

# Start Green version in background
Write-Host ""
Write-Host "[4/6] Starting Green version (port 5002)..." -ForegroundColor Yellow
$env:APP_VERSION = "green"
$env:APP_PORT = "5002"
$greenProcess = Start-Process python -ArgumentList "app/app.py" -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3
Write-Host "✓ Green version started (PID: $($greenProcess.Id))" -ForegroundColor Green

# Test Blue
Write-Host ""
Write-Host "[5/6] Testing Blue version..." -ForegroundColor Yellow
try {
    $blueResponse = Invoke-RestMethod -Uri "http://localhost:5001/version" -TimeoutSec 5
    Write-Host "✓ Blue version: $($blueResponse.version)" -ForegroundColor Green
    Write-Host "  Uptime: $($blueResponse.uptime_seconds)s" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to connect to Blue version" -ForegroundColor Red
}

# Test Green
Write-Host ""
Write-Host "[6/6] Testing Green version..." -ForegroundColor Yellow
try {
    $greenResponse = Invoke-RestMethod -Uri "http://localhost:5002/version" -TimeoutSec 5
    Write-Host "✓ Green version: $($greenResponse.version)" -ForegroundColor Green
    Write-Host "  Uptime: $($greenResponse.uptime_seconds)s" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Failed to connect to Green version" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Demo Running!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Access the applications:" -ForegroundColor Cyan
Write-Host "  Blue:  http://localhost:5001" -ForegroundColor White
Write-Host "  Green: http://localhost:5002" -ForegroundColor White
Write-Host ""
Write-Host "Test endpoints:" -ForegroundColor Cyan
Write-Host "  curl http://localhost:5001/version" -ForegroundColor White
Write-Host "  curl http://localhost:5002/version" -ForegroundColor White
Write-Host "  curl http://localhost:5001/health" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop both servers..." -ForegroundColor Yellow
Write-Host ""

# Keep script running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host ""
    Write-Host "Stopping servers..." -ForegroundColor Yellow
    Stop-Process -Id $blueProcess.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $greenProcess.Id -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Servers stopped" -ForegroundColor Green
}
