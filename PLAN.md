# AudioStretchy Complete Rewrite and Repackaging Plan

## Overview
Complete rewrite and repackaging of AudioStretchy to use git submodules for audio-stretch C library integration, Pedalboard for file I/O, and Hatch for modern Python packaging with cross-platform wheel building.

## Technical Architecture

### Core Components
1. **Git Submodule Integration**: Use https://github.com/dbry/audio-stretch as a git submodule
2. **Audio I/O**: Replace existing I/O with Pedalboard library exclusively
3. **Build System**: Migrate from setuptools to Hatch with cross-platform wheel building
4. **CI/CD**: GitHub Actions for automated building and publishing

### Project Structure
```
audiostretchy/
├── pyproject.toml           # Hatch configuration
├── src/
│   └── audiostretchy/
│       ├── __init__.py
│       ├── __main__.py      # CLI entry point
│       ├── core.py          # Main AudioStretch class
│       └── c_interface/
│           ├── __init__.py
│           ├── wrapper.py   # C library ctypes wrapper
│           └── build.py     # C compilation utilities
├── audio-stretch/           # Git submodule
│   ├── stretch.h
│   ├── stretch.c
│   └── README.md
├── scripts/
│   ├── build_local.py       # Local wheel building
│   └── compile_c.py         # C library compilation
├── .github/
│   └── workflows/
│       ├── build.yml        # Cross-platform wheel building
│       └── publish.yml      # PyPI publishing
└── tests/
```

## Implementation Phases

### Phase 1: Infrastructure Setup
- [ ] Configure git submodule for audio-stretch
- [ ] Set up Hatch build system configuration
- [ ] Create basic project structure with src layout

### Phase 2: Core Implementation
- [ ] Implement Pedalboard-based audio I/O
- [ ] Create C library compilation system
- [ ] Develop ctypes wrapper for audio-stretch
- [ ] Implement main AudioStretch class

### Phase 3: Build System
- [ ] Create local build scripts for different platforms
- [ ] Set up GitHub Actions for cross-platform building
- [ ] Configure automated PyPI publishing
- [ ] Test wheel building on multiple platforms

### Phase 4: CLI and Testing
- [ ] Implement CLI interface with Fire
- [ ] Create comprehensive test suite
- [ ] Add performance benchmarks
- [ ] Documentation updates

## Technical Specifications

### Hatch Configuration
- Use `hatchling` as build backend
- Configure wheel building with platform-specific compilation
- Set up proper package data inclusion for compiled libraries
- Configure development dependencies and optional extras

### C Library Integration
- Compile stretch.c for multiple platforms (Linux, macOS, Windows)
- Create platform-specific shared libraries (.so, .dylib, .dll)
- Use ctypes for Python-C interface
- Handle different architectures (x86_64, arm64)

### Pedalboard Integration
- Replace all existing audio I/O with Pedalboard AudioFile
- Utilize built-in resampling capabilities
- Support multiple audio formats (WAV, MP3, FLAC, OGG, etc.)
- Optimize for performance and memory usage

### Cross-Platform Wheel Building
- Use cibuildwheel for GitHub Actions
- Support Linux (x86_64, aarch64), macOS (x86_64, arm64), Windows (x86_64)
- Ensure proper C library compilation for each platform
- Handle platform-specific dependencies

## Dependencies

### Core Dependencies
- `pedalboard>=0.8.6` - Audio I/O and effects
- `numpy>=1.23.0` - Numerical operations
- `fire>=0.5.0` - CLI interface

### Build Dependencies
- `hatchling` - Build backend
- `cibuildwheel` - Cross-platform wheel building
- Platform-specific C compilers

### Development Dependencies
- `pytest` - Testing framework
- `pytest-cov` - Coverage reporting
- `black` - Code formatting
- `ruff` - Linting and import sorting

## Success Criteria
1. Git submodule properly integrated and buildable
2. Pedalboard handles all audio I/O operations
3. Hatch successfully builds wheels for all target platforms
4. GitHub Actions automatically build and publish releases
5. Local build scripts work on developer machines
6. All existing functionality preserved with improved performance
7. Clean, maintainable codebase following modern Python practices
