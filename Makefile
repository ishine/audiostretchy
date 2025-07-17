# this_file: Makefile

.PHONY: help build test clean install dev lint format release
.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "AudioStretchy Build Commands"
	@echo "============================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Build the package
	@./scripts/build.sh

test: ## Run tests with coverage
	@./scripts/test.sh

clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf build/ dist/ *.egg-info/ htmlcov/ .coverage
	@find . -type d -name __pycache__ -exec rm -rf {} +
	@find . -type f -name "*.pyc" -delete

install: ## Install package in development mode
	@echo "📦 Installing package in development mode..."
	@pip install -e .[testing]

dev: install ## Set up development environment
	@echo "🛠️ Setting up development environment..."
	@pip install pre-commit
	@pre-commit install

lint: ## Run linting
	@echo "🔍 Running linting..."
	@python -m flake8 src/audiostretchy/ tests/

format: ## Format code
	@echo "🎨 Formatting code..."
	@python -m black src/audiostretchy/ tests/
	@python -m isort src/audiostretchy/ tests/

release: ## Create a release (usage: make release VERSION=1.2.3)
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: Please provide a version number"; \
		echo "Usage: make release VERSION=1.2.3"; \
		exit 1; \
	fi
	@./scripts/release.sh $(VERSION)

check: test lint ## Run all checks (tests + linting)

all: clean test build ## Clean, test, and build the package