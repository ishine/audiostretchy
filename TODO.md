# AudioStretchy Complete Rewrite - TODO

## Completed ✅

### Infrastructure Setup
- [x] Set up git submodule for audio-stretch 
- [x] Configure Hatch build system in pyproject.toml
- [x] Create new project structure with src layout
- [x] Remove old setuptools-based configuration

### Core Implementation  
- [x] Implement Pedalboard-based audio I/O in core.py
- [x] Create C library compilation system in c_interface/build.py
- [x] Develop ctypes wrapper for audio-stretch in c_interface/wrapper.py
- [x] Implement main AudioStretch class with TDHS integration
- [x] Update __init__.py and __main__.py for new structure
- [x] Compile C library for current platform

### Build System
- [x] Create local build scripts (scripts/build_local.py, scripts/compile_c.py)
- [x] Set up GitHub Actions for cross-platform building (.github/workflows/build.yml)
- [x] Configure automated PyPI publishing (.github/workflows/publish.yml)
- [x] Configure cibuildwheel for cross-platform wheels

### Testing Framework
- [x] Create basic test suite for core functionality (tests/test_core.py)
- [x] Test audio data conversion methods (float32 ⟷ int16)
- [x] Test error handling for edge cases
- [x] Remove old implementation files

## Next Steps 📋

### Testing & Validation
- [ ] Test package build with `python -m build`
- [ ] Verify wheel includes compiled C libraries
- [ ] Test installation from wheel in clean environment  
- [ ] Add integration tests with actual audio files
- [ ] Test CLI functionality end-to-end

### Documentation & Polish
- [ ] Update README.md with new architecture details
- [ ] Update CHANGELOG.md with rewrite information
- [ ] Test cross-platform compatibility
- [ ] Performance benchmarking vs old implementation

### Release Preparation
- [ ] Version bump and tagging
- [ ] Test GitHub Actions workflows
- [ ] Documentation review
- [ ] Final validation of all functionality
