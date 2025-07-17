# this_file: Dockerfile

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsndfile1-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY pyproject.toml ./
RUN pip install --no-cache-dir build

# Copy source code
COPY . .

# Install the package
RUN pip install -e .[testing]

# Run tests by default
CMD ["python", "-m", "pytest", "tests/", "-v"]