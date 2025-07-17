#!/bin/bash
# this_file: scripts/test.sh

set -e

echo "🧪 AudioStretchy Test Script"
echo "==========================="

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Install test dependencies
echo "📦 Installing test dependencies..."
python -m pip install --upgrade pip
pip install -e .[testing]

# Run tests with coverage
echo "🧪 Running tests with coverage..."
python -m pytest tests/ -v --cov=src/audiostretchy --cov-report=term-missing --cov-report=html

# Run linting
echo "🔍 Running linting..."
python -m flake8 src/audiostretchy/ tests/

# Check if coverage report was generated
if [ -f "htmlcov/index.html" ]; then
    echo "📊 Coverage report generated at htmlcov/index.html"
fi

echo "✅ All tests passed!"