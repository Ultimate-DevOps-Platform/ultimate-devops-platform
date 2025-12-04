.PHONY: install dev test clean format lint docker-up docker-down

install:
	poetry install

dev:
	docker-compose up -d
	poetry run uvicorn services.user_service.main:app --reload --port 8000

test:
	poetry run pytest tests/ -v --cov=services

test-integration:
	poetry run pytest tests/integration/ -v

format:
	poetry run black services/ tests/
	poetry run isort services/ tests/

lint:
	poetry run flake8 services/ tests/
	poetry run mypy services/
	poetry run bandit -r services/

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf .pytest_cache .coverage htmlcov/

setup:
	poetry install
	poetry run pre-commit install
	cp .env.example .env

k8s-start:
	minikube start --cpus=4 --memory=7168 --driver=docker

k8s-stop:
	minikube stop

k8s-delete:
	minikube delete
