# Semantic Versioning and Release Guide

## Overview

AudioStretchy uses git-tag-based semantic versioning with automated CI/CD pipeline for releases. The version is automatically determined from git tags using `setuptools_scm`.

## Version Format

Versions follow semantic versioning (SemVer) format: `MAJOR.MINOR.PATCH[-PRERELEASE]`

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backwards compatible manner  
- **PATCH**: Backwards compatible bug fixes
- **PRERELEASE**: Optional pre-release identifier (e.g., `1.0.0-alpha`, `1.0.0-beta.1`)

## Release Process

### 1. Local Development

```bash
# Set up development environment
make dev

# Run tests
make test

# Run linting
make lint

# Build package
make build
```

### 2. Creating a Release

```bash
# Create and push a release tag
make release VERSION=1.2.3

# Or manually:
./scripts/release.sh 1.2.3
```

This will:
- Validate the version format
- Ensure you're on the main branch
- Run all tests
- Build the package
- Create a git tag
- Push the tag to GitHub

### 3. Automated Release Pipeline

When you push a tag to GitHub:

1. **CI Pipeline Triggers**: GitHub Actions detects the new tag
2. **Multi-platform Testing**: Tests run on Ubuntu, Windows, and macOS
3. **Wheel Building**: Binary wheels are built for all supported platforms
4. **Automatic PyPI Release**: Package is automatically published to PyPI

## Version Detection

The package version is automatically detected from git tags using `setuptools_scm`:

```python
# In Python code
import audiostretchy
print(audiostretchy.__version__)
```

```bash
# From command line
python -c "import audiostretchy; print(audiostretchy.__version__)"
```

## Development Versions

During development (between releases), versions are automatically generated:
- Format: `1.2.3.dev4+g1234abcd`
- `dev4`: 4 commits since last tag
- `g1234abcd`: Short git commit hash

## Pre-release Versions

For pre-releases, use descriptive tags:

```bash
# Alpha release
git tag -a v1.3.0-alpha.1 -m "Alpha release 1.3.0-alpha.1"

# Beta release  
git tag -a v1.3.0-beta.1 -m "Beta release 1.3.0-beta.1"

# Release candidate
git tag -a v1.3.0-rc.1 -m "Release candidate 1.3.0-rc.1"
```

## Branch Strategy

- **main**: Production-ready code, all releases are made from here
- **develop**: Integration branch for features (optional)
- **feature/***: Feature branches

## CI/CD Pipeline Details

### Test Matrix
- **Operating Systems**: Ubuntu, Windows, macOS
- **Python Versions**: 3.8, 3.9, 3.10, 3.11, 3.12
- **Dependencies**: FFmpeg, libsndfile

### Build Process
1. **Source Distribution**: Built on Ubuntu
2. **Binary Wheels**: Built using `cibuildwheel` for all platforms
3. **Testing**: Each wheel is tested before release
4. **Publication**: Automatic upload to PyPI on successful build

### Security
- Uses PyPI trusted publishing with GitHub Actions
- No manual token management required
- Automatic signing and verification

## Manual Release Steps (if needed)

If automatic release fails, you can manually release:

```bash
# Build locally
make build

# Check distribution
python -m twine check dist/*

# Upload to PyPI (requires API token)
python -m twine upload dist/*
```

## Troubleshooting

### Common Issues

1. **Version not detected**: Ensure you're in a git repository with tags
2. **Build failures**: Check that all dependencies are installed
3. **Test failures**: Run `make test` locally first
4. **PyPI upload errors**: Check that version doesn't already exist

### Debug Commands

```bash
# Check current version
python -c "import setuptools_scm; print(setuptools_scm.get_version())"

# Check git status
git status
git tag -l

# Validate build
python -m build --wheel
python -m twine check dist/*
```

## Best Practices

1. **Always test before releasing**: Use `make test` and `make build`
2. **Follow semantic versioning**: Breaking changes require major version bump
3. **Write meaningful commit messages**: They become part of the version history
4. **Tag releases properly**: Use annotated tags with descriptive messages
5. **Keep CHANGELOG.md updated**: Document all changes between versions

## Integration with setuptools_scm

The `pyproject.toml` configuration:

```toml
[tool.setuptools_scm]
version_scheme = "no-guess-dev"
```

This ensures consistent version numbering and development version formatting.