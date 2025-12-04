.PHONY: install dev test clean format lint docker-up docker-down git-setup

# Installation
install:
	poetry install

setup:
	poetry install
	poetry run pre-commit install
	cp .env.example .env
	@echo "Setup complete! Run 'make git-setup' to initialize branches"

# Development
dev:
	docker-compose up -d
	poetry run uvicorn services.user_service.main:app --reload --port 8000

# Testing
test:
	poetry run pytest tests/ -v --cov=services

test-integration:
	poetry run pytest tests/integration/ -v

# Code Quality
format:
	poetry run black services/ tests/
	poetry run isort services/ tests/

lint:
	poetry run flake8 services/ tests/
	poetry run mypy services/
	poetry run bandit -r services/

# Docker
docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

# Kubernetes
k8s-start:
	minikube start --cpus=4 --memory=7168 --driver=docker

k8s-stop:
	minikube stop

k8s-delete:
	minikube delete

# Git Branching
git-setup:
	@echo "Setting up Git branches..."
	git checkout -b develop || git checkout develop
	git push -u origin develop || true
	git checkout -b staging || git checkout staging
	git push -u origin staging || true
	git checkout develop
	@echo "Branches created: develop, staging"

git-feature:
	git checkout develop
	git pull origin develop
	@read -p "Feature name: " name && git checkout -b feature/$$name

git-cleanup:
	git branch --merged | grep -v "main\|develop\|staging" | xargs git branch -d || true

# Deployment
deploy-dev:
	git checkout develop
	git pull origin develop

deploy-staging:
	git checkout staging
	git merge develop
	git push origin staging

deploy-prod:
	git checkout main
	git merge staging
	git push origin main --tags

# Utilities
clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf .pytest_cache .coverage htmlcov/

help:
	@echo "Available commands:"
	@echo "  make install       - Install dependencies"
	@echo "  make setup         - Complete setup"
	@echo "  make git-setup     - Initialize Git branches"
	@echo "  make dev           - Start development"
	@echo "  make test          - Run tests"
	@echo "  make format        - Format code"
	@echo "  make lint          - Run linters"
	@echo "  make git-feature   - Create feature branch"
	@echo "  make deploy-dev    - Deploy to dev"
	@echo "  make deploy-staging - Deploy to staging"
	@echo "  make deploy-prod   - Deploy to production"
