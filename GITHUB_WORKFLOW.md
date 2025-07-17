# GitHub Actions Workflow Setup

Due to GitHub App permissions, the CI/CD workflow file needs to be manually created. After this PR is merged, please add the following workflow file:

## File: `.github/workflows/ci.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  release:
    types: [published]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        python-version: ['3.8', '3.9', '3.10', '3.11', '3.12']

    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        submodules: recursive

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install system dependencies (Ubuntu)
      if: matrix.os == 'ubuntu-latest'
      run: |
        sudo apt-get update
        sudo apt-get install -y ffmpeg libsndfile1-dev

    - name: Install system dependencies (macOS)
      if: matrix.os == 'macos-latest'
      run: |
        brew install ffmpeg libsndfile

    - name: Install system dependencies (Windows)
      if: matrix.os == 'windows-latest'
      run: |
        choco install ffmpeg

    - name: Install Python dependencies
      run: |
        python -m pip install --upgrade pip
        pip install build twine
        pip install -e .[testing]

    - name: Run tests
      run: |
        python -m pytest tests/ -v --cov=src/audiostretchy --cov-report=xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        flags: unittests
        name: codecov-umbrella

  build-wheels:
    needs: test
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]

    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        submodules: recursive

    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'

    - name: Install build dependencies
      run: |
        python -m pip install --upgrade pip
        pip install build cibuildwheel

    - name: Build wheels
      uses: pypa/cibuildwheel@v2.16.2
      env:
        CIBW_BUILD: cp38-* cp39-* cp310-* cp311-* cp312-*
        CIBW_SKIP: "*-win32 *-manylinux_i686"
        CIBW_BEFORE_BUILD_LINUX: yum install -y ffmpeg-devel libsndfile-devel || apt-get update && apt-get install -y ffmpeg libsndfile1-dev
        CIBW_BEFORE_BUILD_MACOS: brew install ffmpeg libsndfile
        CIBW_BEFORE_BUILD_WINDOWS: choco install ffmpeg
        CIBW_TEST_REQUIRES: pytest soundfile
        CIBW_TEST_COMMAND: python -m pytest {project}/tests/test_stretch.py::test_stretch_no_change -v

    - name: Build source distribution
      if: matrix.os == 'ubuntu-latest'
      run: python -m build --sdist

    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: dist-${{ matrix.os }}
        path: dist/

  release:
    needs: [test, build-wheels]
    runs-on: ubuntu-latest
    if: github.event_name == 'release' && github.event.action == 'published'

    steps:
    - name: Download all artifacts
      uses: actions/download-artifact@v3
      with:
        path: dist/

    - name: Flatten artifacts directory
      run: |
        find dist/ -name "*.whl" -o -name "*.tar.gz" | xargs -I {} mv {} dist/
        find dist/ -type d -empty -delete

    - name: Publish to PyPI
      uses: pypa/gh-action-pypi-publish@release/v1
      with:
        user: __token__
        password: ${{ secrets.PYPI_API_TOKEN }}
        packages_dir: dist/
```

## Setup Instructions

1. **After PR is merged**, create the directory structure:
   ```bash
   mkdir -p .github/workflows
   ```

2. **Create the workflow file** with the content above:
   ```bash
   # Copy the YAML content above to .github/workflows/ci.yml
   ```

3. **Configure PyPI API Token**:
   - Go to PyPI.org → Account Settings → API Tokens
   - Create a new token with upload permissions
   - Add it to GitHub repository secrets as `PYPI_API_TOKEN`

4. **Test the workflow**:
   - Push a commit to main branch
   - Verify the workflow runs successfully
   - Check that tests pass on all platforms

## Additional Setup

### Codecov Integration (Optional)
If you want code coverage reporting:
1. Sign up at codecov.io
2. Connect your GitHub repository
3. The workflow will automatically upload coverage reports

### Branch Protection Rules (Recommended)
Set up branch protection for main branch:
- Require pull request reviews
- Require status checks (CI tests)
- Require branches to be up to date
- Restrict pushes to main branch

## Testing the Release Process

After the workflow is set up:

1. **Test with a pre-release**:
   ```bash
   git tag -a v1.0.0-beta.1 -m "Beta release"
   git push origin v1.0.0-beta.1
   ```

2. **Create a GitHub release**:
   - Go to GitHub repository → Releases
   - Click "Create a new release"
   - Select your tag
   - Fill in release notes
   - Publish the release

3. **Verify PyPI upload**:
   - Check that the package appears on PyPI
   - Test installation: `pip install audiostretchy==1.0.0b1`

## Troubleshooting

### Common Issues

1. **Workflow permission errors**: Ensure the GitHub App or user has workflows permission
2. **PyPI token errors**: Verify the token is correctly set in repository secrets
3. **Build failures**: Check system dependencies are correctly installed
4. **Test failures**: Ensure all tests pass locally before pushing

### Debug Commands

```bash
# Local testing
make test
make build

# Check version detection
python -c "import setuptools_scm; print(setuptools_scm.get_version())"

# Validate distribution
python -m twine check dist/*
```

This workflow provides:
- ✅ Multi-platform testing (Ubuntu, Windows, macOS)
- ✅ Python version matrix (3.8-3.12)
- ✅ Automated wheel building
- ✅ PyPI publishing on releases
- ✅ Code coverage reporting
- ✅ Artifact collection and storage