# Development Guide for AudioStretchy

## Overview

This guide covers the complete development workflow for AudioStretchy, including testing, building, and releasing.

## Project Structure

```
audiostretchy/
├── src/audiostretchy/           # Main package source
│   ├── __init__.py             # Package initialization with version
│   ├── __main__.py             # CLI entry point
│   ├── stretch.py              # Core audio processing
│   └── interface/              # C library bindings
├── tests/                      # Comprehensive test suite
│   ├── test_stretch.py         # Main functionality tests
│   ├── test_cli.py             # Command line interface tests
│   ├── test_mono_audio.py      # Mono audio specific tests
│   ├── test_performance.py     # Performance benchmarks
│   └── conftest.py             # Test fixtures and utilities
├── scripts/                    # Build and release scripts
│   ├── build.sh                # Build script
│   ├── test.sh                 # Test script
│   └── release.sh              # Release script
├── .github/workflows/          # CI/CD pipeline
│   └── ci.yml                  # GitHub Actions workflow
├── Makefile                    # Convenient build commands
├── pyproject.toml              # Package configuration
├── Dockerfile                  # Docker container for testing
└── SEMVER_GUIDE.md            # Semantic versioning guide
```

## Development Setup

### Prerequisites

- Python 3.8+
- Git
- FFmpeg (for audio format support)
- libsndfile (for audio I/O)

### Local Development

```bash
# Clone the repository
git clone https://github.com/twardoch/audiostretchy.git
cd audiostretchy

# Set up development environment
make dev

# This will:
# - Install the package in editable mode
# - Install all testing dependencies
# - Set up pre-commit hooks
```

### Available Commands

```bash
# Development
make dev          # Set up development environment
make install      # Install package in development mode

# Testing
make test         # Run complete test suite with coverage
make lint         # Run linting checks
make format       # Format code with black and isort
make check        # Run both tests and linting

# Building
make build        # Build source and wheel distributions
make clean        # Clean build artifacts

# Release
make release VERSION=1.2.3  # Create and push release tag
```

## Testing

### Test Structure

AudioStretchy has a comprehensive test suite covering:

1. **Core functionality** (`test_stretch.py`)
   - Audio stretching operations
   - File I/O operations
   - Resampling functionality
   - Parameter validation

2. **CLI interface** (`test_cli.py`)
   - Command line argument parsing
   - Integration with Fire framework
   - Error handling

3. **Audio format support** (`test_mono_audio.py`)
   - Mono and stereo audio processing
   - Various audio formats (WAV, MP3)
   - Silence handling

4. **Performance** (`test_performance.py`)
   - Benchmark tests
   - Memory usage validation
   - Processing time limits

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
python -m pytest tests/test_stretch.py -v

# Run with coverage
python -m pytest tests/ --cov=src/audiostretchy --cov-report=html

# Run performance tests
python -m pytest tests/test_performance.py -m performance
```

### Test Fixtures

The test suite includes several fixtures for consistent testing:

- **Audio file generators**: Create test audio files dynamically
- **Temporary directories**: Clean test environments
- **Property checkers**: Validate audio file properties
- **Tolerance checkers**: Handle floating-point comparisons

## Building

### Local Build

```bash
# Build source distribution and wheel
make build

# Build artifacts will be in dist/
ls dist/
# audiostretchy-1.2.3-py3-none-any.whl
# audiostretchy-1.2.3.tar.gz
```

### Docker Build

```bash
# Build and test in Docker container
docker build -t audiostretchy-test .
docker run --rm audiostretchy-test
```

### Wheel Building

The CI pipeline uses `cibuildwheel` to build wheels for multiple platforms:

- **Linux**: x86_64, aarch64
- **Windows**: AMD64
- **macOS**: x86_64, arm64

## Version Management

AudioStretchy uses `setuptools_scm` for automatic version detection from git tags:

```python
# Version is automatically set from git tags
import audiostretchy
print(audiostretchy.__version__)
```

### Version Format

- **Release**: `1.2.3`
- **Development**: `1.2.3.dev4+g1234abcd`
- **Pre-release**: `1.3.0-alpha.1`

## Release Process

### Automated Release

```bash
# Create release (must be on main branch)
make release VERSION=1.2.3
```

This triggers:
1. Local validation and testing
2. Git tag creation
3. CI/CD pipeline activation
4. Multi-platform wheel building
5. Automatic PyPI publication

### Manual Release

If needed, you can manually release:

```bash
# Build locally
make build

# Check distribution
python -m twine check dist/*

# Upload to PyPI (requires API token)
python -m twine upload dist/*
```

## CI/CD Pipeline

### GitHub Actions Workflow

The CI pipeline (`.github/workflows/ci.yml`) includes:

1. **Testing Phase**
   - Multi-platform testing (Ubuntu, Windows, macOS)
   - Python version matrix (3.8-3.12)
   - Dependency installation
   - Test execution with coverage

2. **Build Phase**
   - Source distribution building
   - Multi-platform wheel building
   - Artifact collection

3. **Release Phase** (on tags)
   - Artifact aggregation
   - PyPI publication
   - Release notification

### Dependencies

The pipeline installs system dependencies:

- **Ubuntu**: `ffmpeg`, `libsndfile1-dev`
- **macOS**: `ffmpeg`, `libsndfile` (via Homebrew)
- **Windows**: `ffmpeg` (via Chocolatey)

## Code Quality

### Pre-commit Hooks

The project uses pre-commit hooks for code quality:

- **Formatting**: Black, isort
- **Linting**: flake8, mypy
- **Security**: Basic security checks
- **Testing**: Quick smoke test

### Code Standards

- **Formatting**: Black with 88 character line length
- **Import sorting**: isort with Black profile
- **Type hints**: Encouraged but not required
- **Documentation**: Docstrings for all public APIs

## Contributing

### Workflow

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Set up development environment (`make dev`)
4. Make changes with tests
5. Run quality checks (`make check`)
6. Commit changes (`git commit -m 'Add amazing feature'`)
7. Push to branch (`git push origin feature/amazing-feature`)
8. Create Pull Request

### Pull Request Requirements

- All tests must pass
- Code coverage should not decrease
- Code must be formatted with Black
- Include tests for new functionality
- Update documentation if needed

## Troubleshooting

### Common Issues

1. **Import errors**: Ensure package is installed (`make install`)
2. **Test failures**: Check system dependencies (FFmpeg, libsndfile)
3. **Build failures**: Clean build artifacts (`make clean`)
4. **Version issues**: Check git tags and setuptools_scm

### Debug Commands

```bash
# Check version detection
python -c "import setuptools_scm; print(setuptools_scm.get_version())"

# Check package installation
python -c "import audiostretchy; print(audiostretchy.__version__)"

# Check git status
git status
git tag -l | tail -10

# Validate build
python -m build --wheel --sdist
python -m twine check dist/*
```

## Performance Considerations

### Optimization

- Pre-compiled C libraries for core algorithms
- Efficient NumPy array operations
- Minimal memory copying in audio processing
- Streaming audio I/O where possible

### Benchmarking

Run performance tests to ensure no regressions:

```bash
python -m pytest tests/test_performance.py -v
```

Expected performance targets:
- 1 second of audio processed in < 5 seconds
- Memory usage stable across multiple operations
- No memory leaks in repeated operations

## Support

For development questions:
- Check this guide and other documentation
- Review test cases for usage examples
- Open issues on GitHub for bugs/features
- Follow contributing guidelines for PRs