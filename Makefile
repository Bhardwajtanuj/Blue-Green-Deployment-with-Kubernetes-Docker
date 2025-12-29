# Makefile for Blue-Green Deployment

.PHONY: help build deploy-blue deploy-green switch-blue switch-green rollback health-blue health-green clean

# Variables
REGISTRY ?= your-registry
IMAGE_NAME = $(REGISTRY)/blue-green-app
VERSION ?= latest

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build-blue: ## Build Blue Docker image
	docker build -t $(IMAGE_NAME):blue -t $(IMAGE_NAME):$(VERSION)-blue .

build-green: ## Build Green Docker image
	docker build -t $(IMAGE_NAME):green -t $(IMAGE_NAME):$(VERSION)-green .

push-blue: build-blue ## Push Blue image to registry
	docker push $(IMAGE_NAME):blue
	docker push $(IMAGE_NAME):$(VERSION)-blue

push-green: build-green ## Push Green image to registry
	docker push $(IMAGE_NAME):green
	docker push $(IMAGE_NAME):$(VERSION)-green

deploy-blue: ## Deploy Blue version
	chmod +x scripts/deploy.sh
	./scripts/deploy.sh blue $(VERSION)

deploy-green: ## Deploy Green version
	chmod +x scripts/deploy.sh
	./scripts/deploy.sh green $(VERSION)

switch-blue: ## Switch traffic to Blue
	chmod +x scripts/switch.sh
	./scripts/switch.sh blue

switch-green: ## Switch traffic to Green
	chmod +x scripts/switch.sh
	./scripts/switch.sh green

rollback: ## Rollback to previous version
	chmod +x scripts/rollback.sh
	./scripts/rollback.sh

health-blue: ## Check Blue health
	chmod +x scripts/health-check.sh
	./scripts/health-check.sh blue

health-green: ## Check Green health
	chmod +x scripts/health-check.sh
	./scripts/health-check.sh green

status: ## Show deployment status
	@echo "=== Pods ==="
	kubectl get pods -n blue-green
	@echo "\n=== Services ==="
	kubectl get services -n blue-green
	@echo "\n=== Current Version ==="
	kubectl get service webapp-service -n blue-green -o jsonpath='{.spec.selector.version}'
	@echo ""

logs-blue: ## Show Blue logs
	kubectl logs -n blue-green -l version=blue --tail=50

logs-green: ## Show Green logs
	kubectl logs -n blue-green -l version=green --tail=50

clean: ## Delete all resources
	kubectl delete namespace blue-green

setup: ## Initial setup (create namespace and service)
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/service.yaml

test-local: ## Test with Minikube
	@echo "Setting up Minikube environment..."
	eval $$(minikube docker-env) && \
	docker build -t blue-green-app:blue . && \
	docker build -t blue-green-app:green . && \
	kubectl apply -f k8s/namespace.yaml && \
	kubectl apply -f k8s/configmap.yaml && \
	sed 's|your-registry/blue-green-app|blue-green-app|g' k8s/deployment-blue.yaml | \
	sed 's|imagePullPolicy: Always|imagePullPolicy: Never|g' | kubectl apply -f - && \
	kubectl apply -f k8s/service.yaml && \
	echo "Waiting for deployment..." && \
	kubectl rollout status deployment/webapp-blue -n blue-green && \
	minikube service webapp-service -n blue-green --url
