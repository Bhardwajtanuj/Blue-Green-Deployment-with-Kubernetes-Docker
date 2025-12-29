# Blue-Green Deployment - Local Testing Guide (Windows)

Since Docker/Kubernetes are not installed, here are **3 ways** to test the Blue-Green deployment:

## Option 1: Python-Only Demo (Recommended - No Docker Required)

This runs both Blue and Green versions locally using Python.

### Steps:

1. **Run the demo:**
```powershell
.\run-python-demo.ps1
```

2. **Test the endpoints:**
```powershell
# Blue version
curl http://localhost:5001/version
curl http://localhost:5001/health

# Green version
curl http://localhost:5002/version
curl http://localhost:5002/health
```

3. **Simulate traffic switching:**
   - Both versions run simultaneously
   - Blue on port 5001
   - Green on port 5002
   - You can switch by changing which port you access

---

## Option 2: Manual Python Testing

### Start Blue Version:
```powershell
cd app
$env:APP_VERSION="blue"
$env:APP_PORT="5001"
python app.py
```

### In another terminal, start Green Version:
```powershell
cd app
$env:APP_VERSION="green"
$env:APP_PORT="5002"
python app.py
```

### Test:
```powershell
curl http://localhost:5001/version  # Blue
curl http://localhost:5002/version  # Green
```

---

## Option 3: Docker Compose (Requires Docker Desktop)

If you install Docker Desktop, you can run the full demo:

### Install Docker Desktop:
1. Download from: https://www.docker.com/products/docker-desktop/
2. Install and start Docker Desktop
3. Run the demo:

```powershell
.\run-demo.bat
```

This will:
- Build Blue and Green containers
- Start Nginx proxy
- Route traffic through Nginx (port 8080)
- Allow instant switching between Blue and Green

---

## Quick Test (Right Now)

Let's test the Flask app immediately:

```powershell
# Install dependencies
cd app
pip install -r requirements.txt

# Run Blue version
$env:APP_VERSION="blue"
python app.py
```

Then open browser to: http://localhost:5000

---

## Endpoints to Test

| Endpoint | Description |
|----------|-------------|
| `/` | Main page |
| `/version` | Shows Blue or Green |
| `/health` | Health check |
| `/ready` | Readiness check |
| `/metrics` | Prometheus metrics |
| `/api/data` | Sample API |

---

## For Full Kubernetes Demo

To run the complete Kubernetes-based Blue-Green deployment:

1. **Install required tools:**
   - Docker Desktop: https://www.docker.com/products/docker-desktop/
   - Enable Kubernetes in Docker Desktop settings
   - Or install Minikube: https://minikube.sigs.k8s.io/docs/start/

2. **Run the quick start:**
```bash
chmod +x quick-start.sh
./quick-start.sh
```

---

## Current Status

✅ Python is installed (3.14.0)
❌ Docker is not installed
❌ kubectl is not installed
❌ Minikube is not installed

**Recommendation:** Use Option 1 (Python-Only Demo) to test immediately!
