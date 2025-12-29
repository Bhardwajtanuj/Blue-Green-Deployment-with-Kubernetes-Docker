#!/bin/bash

###############################################################################
# Quick Start Script for Blue-Green Deployment
# This script sets up a local Blue-Green deployment using Minikube
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Blue-Green Deployment - Quick Start                     ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/7]${NC} Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found. Please install Docker first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker found${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ kubectl found${NC}"

if ! command -v minikube &> /dev/null; then
    echo -e "${YELLOW}⚠ Minikube not found. This script requires Minikube for local testing.${NC}"
    echo "Install Minikube: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi
echo -e "${GREEN}✓ Minikube found${NC}"

# Start Minikube
echo ""
echo -e "${YELLOW}[2/7]${NC} Starting Minikube cluster..."
if minikube status &> /dev/null; then
    echo -e "${GREEN}✓ Minikube already running${NC}"
else
    minikube start --driver=docker --cpus=2 --memory=2048
    echo -e "${GREEN}✓ Minikube started${NC}"
fi

# Use Minikube's Docker daemon
echo ""
echo -e "${YELLOW}[3/7]${NC} Configuring Docker environment..."
eval $(minikube docker-env)
echo -e "${GREEN}✓ Using Minikube's Docker daemon${NC}"

# Build Docker images
echo ""
echo -e "${YELLOW}[4/7]${NC} Building Docker images..."
docker build -t blue-green-app:blue --build-arg APP_VERSION=blue .
docker build -t blue-green-app:green --build-arg APP_VERSION=green .
echo -e "${GREEN}✓ Images built successfully${NC}"

# Deploy to Kubernetes
echo ""
echo -e "${YELLOW}[5/7]${NC} Deploying to Kubernetes..."

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Update manifests for local use
sed 's|image: your-registry/blue-green-app:blue|image: blue-green-app:blue|g' k8s/deployment-blue.yaml | \
sed 's|imagePullPolicy: Always|imagePullPolicy: Never|g' | kubectl apply -f -

sed 's|image: your-registry/blue-green-app:green|image: blue-green-app:green|g' k8s/deployment-green.yaml | \
sed 's|imagePullPolicy: Never|imagePullPolicy: Never|g' | kubectl apply -f -

# Create service
kubectl apply -f k8s/service.yaml

echo -e "${GREEN}✓ Deployed to Kubernetes${NC}"

# Wait for Blue deployment
echo ""
echo -e "${YELLOW}[6/7]${NC} Waiting for Blue deployment to be ready..."
kubectl rollout status deployment/webapp-blue -n blue-green --timeout=120s
echo -e "${GREEN}✓ Blue deployment ready${NC}"

# Wait for Green deployment
echo ""
echo -e "${YELLOW}[7/7]${NC} Waiting for Green deployment to be ready..."
kubectl rollout status deployment/webapp-green -n blue-green --timeout=120s
echo -e "${GREEN}✓ Green deployment ready${NC}"

# Get service URL
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Deployment Complete!                                     ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

SERVICE_URL=$(minikube service webapp-service -n blue-green --url)
echo -e "Service URL: ${GREEN}${SERVICE_URL}${NC}"
echo ""

# Test endpoints
echo "Testing endpoints..."
echo ""
echo -e "${YELLOW}Current Version:${NC}"
curl -s ${SERVICE_URL}/version | python3 -m json.tool || curl -s ${SERVICE_URL}/version

echo ""
echo ""
echo -e "${YELLOW}Health Status:${NC}"
curl -s ${SERVICE_URL}/health | python3 -m json.tool || curl -s ${SERVICE_URL}/health

echo ""
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "1. Test the application: curl ${SERVICE_URL}"
echo "2. Switch to Green: ./scripts/switch.sh green"
echo "3. Switch to Blue: ./scripts/switch.sh blue"
echo "4. Rollback: ./scripts/rollback.sh"
echo "5. View pods: kubectl get pods -n blue-green"
echo "6. View logs: kubectl logs -n blue-green -l version=blue"
echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"
