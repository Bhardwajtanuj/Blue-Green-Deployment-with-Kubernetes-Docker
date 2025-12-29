# Blue-Green Deployment - Quick Reference

## 🚀 Quick Start Commands

### Local Testing (Minikube)
```bash
# One-command setup
chmod +x quick-start.sh && ./quick-start.sh

# Or use Makefile
make test-local
```

### Manual Deployment
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Deploy Blue version
./scripts/deploy.sh blue v1.0.0

# Create service (first time only)
kubectl apply -f k8s/service.yaml

# Deploy Green version
./scripts/deploy.sh green v2.0.0

# Switch traffic to Green
./scripts/switch.sh green

# Rollback if needed
./scripts/rollback.sh
```

## 📊 Monitoring Commands

```bash
# Check deployment status
kubectl get all -n blue-green

# View pods
kubectl get pods -n blue-green

# Check which version is active
kubectl get service webapp-service -n blue-green -o jsonpath='{.spec.selector.version}'

# View logs
kubectl logs -n blue-green -l version=blue --tail=50
kubectl logs -n blue-green -l version=green --tail=50

# Test endpoints
SERVICE_URL=$(minikube service webapp-service -n blue-green --url)
curl $SERVICE_URL/version
curl $SERVICE_URL/health
```

## 🔧 Makefile Commands

```bash
make help              # Show all available commands
make deploy-blue       # Deploy Blue version
make deploy-green      # Deploy Green version
make switch-blue       # Switch traffic to Blue
make switch-green      # Switch traffic to Green
make rollback          # Rollback to previous version
make status            # Show deployment status
make logs-blue         # View Blue logs
make logs-green        # View Green logs
make clean             # Delete all resources
```

## 📁 Project Structure

```
blue-green-k8s/
├── app/                    # Flask application
├── k8s/                    # Kubernetes manifests
├── scripts/                # Automation scripts
├── .github/workflows/      # CI/CD pipeline
├── docs/                   # Documentation
├── Dockerfile              # Docker build
├── Makefile                # Convenience commands
├── quick-start.sh          # Quick start script
└── README.md               # Main documentation
```

## 📖 Documentation

- **README.md** - Main documentation with architecture and quick start
- **docs/DEPLOYMENT.md** - Detailed deployment guide (local and cloud)
- **docs/TROUBLESHOOTING.md** - Common issues and solutions

## 🎯 Key Features

✅ Zero-downtime deployments
✅ Instant rollback (< 10 seconds)
✅ Automated CI/CD pipeline
✅ Health checks and monitoring
✅ Production-ready configuration
✅ Comprehensive documentation

## 🔄 Deployment Workflow

1. **Deploy new version** to inactive environment (Blue or Green)
2. **Health checks** validate new version
3. **Switch traffic** instantly via Service selector
4. **Rollback** if issues detected (instant)

## 🌐 Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/` | Main application |
| `/version` | Version information |
| `/health` | Health check |
| `/ready` | Readiness check |
| `/metrics` | Prometheus metrics |

## 🚨 Emergency Rollback

```bash
# Instant rollback to previous version
./scripts/rollback.sh

# Or manually
kubectl patch service webapp-service -n blue-green -p '{"spec":{"selector":{"version":"blue"}}}'
```

## 📦 Prerequisites

- Docker (v20.10+)
- kubectl (v1.25+)
- Kubernetes cluster (Minikube/Kind/GKE/EKS/AKS)

## 🎓 Next Steps

1. **Test Locally:** Run `./quick-start.sh`
2. **Configure Registry:** Update image names in manifests
3. **Set Up CI/CD:** Add GitHub secrets
4. **Deploy to Cloud:** Follow `docs/DEPLOYMENT.md`
5. **Add Monitoring:** Deploy Prometheus/Grafana

---

**For detailed information, see README.md**
