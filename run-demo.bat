@echo off
REM Blue-Green Deployment Demo Script for Windows (Docker Compose)
REM This script demonstrates Blue-Green deployment without Kubernetes

echo ========================================
echo Blue-Green Deployment Demo
echo ========================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker Desktop.
    exit /b 1
)

echo [INFO] Docker is running
echo.

REM Build and start containers
echo [1/5] Building and starting containers...
docker-compose up -d --build

if %errorlevel% neq 0 (
    echo [ERROR] Failed to start containers
    exit /b 1
)

echo [INFO] Containers started successfully
echo.

REM Wait for containers to be healthy
echo [2/5] Waiting for containers to be healthy...
timeout /t 10 /nobreak >nul

REM Check Blue health
echo [3/5] Checking Blue version health...
curl -s http://localhost:5001/health
echo.

REM Check Green health
echo [4/5] Checking Green version health...
curl -s http://localhost:5002/health
echo.

REM Check current version via Nginx
echo [5/5] Checking current active version (via Nginx)...
curl -s http://localhost:8080/version
echo.
echo.

echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo Blue version:  http://localhost:5001
echo Green version: http://localhost:5002
echo Nginx proxy:   http://localhost:8080  (currently routing to Blue)
echo.
echo To switch traffic to Green:
echo   1. Stop Nginx: docker-compose stop nginx
echo   2. Copy config: copy nginx-green.conf nginx.conf
echo   3. Start Nginx: docker-compose start nginx
echo.
echo To view logs:
echo   docker-compose logs -f app-blue
echo   docker-compose logs -f app-green
echo.
echo To stop all containers:
echo   docker-compose down
echo.
