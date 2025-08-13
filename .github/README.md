# this_file: _github/README.md

# GitHub Workflows

This directory contains GitHub Actions workflow files for the AudioStretchy project.

## Workflows

### `docs.yml` - Documentation Build and Deploy

**Trigger**: 
- Push to `main` branch (when `src_docs/` changes)
- Pull requests to `main` branch (when `src_docs/` changes)
- Manual workflow dispatch

**Purpose**:
- Builds MkDocs Material documentation from `src_docs/`
- Deploys to GitHub Pages on push to main
- Validates documentation builds on pull requests

**Requirements**:
- GitHub Pages must be enabled in repository settings
- Source set to "GitHub Actions" in Pages settings

### `ci.yml` - Continuous Integration

**Trigger**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches  
- Manual workflow dispatch

**Purpose**:
- Tests on multiple OS (Ubuntu, Windows, macOS)
- Tests multiple Python versions (3.8 - 3.12)
- Runs linting with flake8
- Runs tests with pytest and coverage
- Builds distribution packages

### `release.yml` - Release and PyPI Publishing

**Trigger**:
- Push of version tags (e.g., `v1.2.3`)

**Purpose**:
- Runs full test suite on release
- Builds distribution packages for all platforms
- Creates GitHub release with artifacts
- Publishes to PyPI automatically

**Requirements**:
- `PYPI_API_TOKEN` secret must be configured
- Release environment may need approval settings

## Setup Instructions

To activate these workflows:

1. **Copy to `.github/` directory**:
   ```bash
   cp -r _github/ .github/
   ```

2. **Configure GitHub Pages**:
   - Go to repository Settings → Pages
   - Set Source to "GitHub Actions"
   - The documentation will be available at `https://username.github.io/audiostretchy/`

3. **Configure PyPI Publishing**:
   - Create PyPI API token at https://pypi.org/manage/account/token/
   - Add token as `PYPI_API_TOKEN` secret in repository settings
   - Optionally configure release environment with approval requirements

4. **Test Workflows**:
   - Create a pull request to test CI
   - Push to main to test documentation build
   - Create a tag like `v1.0.0-test` to test release workflow

## Customization

### Documentation Workflow

Edit `workflows/docs.yml` to customize:
- **Trigger conditions**: Modify `on.push.paths` to change which files trigger builds
- **Python version**: Change in `setup-python` step
- **Additional dependencies**: Add to pip install step
- **Build directory**: Modify `mkdocs build` command and upload path

### CI Workflow

Edit `workflows/ci.yml` to customize:
- **OS matrix**: Add/remove operating systems
- **Python versions**: Modify version matrix
- **Test commands**: Change pytest configuration
- **Linting rules**: Modify flake8 parameters

### Release Workflow

Edit `workflows/release.yml` to customize:
- **Tag pattern**: Change `tags` filter
- **Release notes**: Modify `generate_release_notes` setting
- **PyPI repository**: Add `repository-url` for test PyPI

## Security Considerations

- **Secrets**: Never commit API tokens or sensitive data
- **Permissions**: Use minimal required permissions in workflows
- **Environment protection**: Consider requiring reviews for release environment
- **Token scoping**: Use scoped tokens with minimal required permissions

## Troubleshooting

### Documentation Build Fails

1. Check MkDocs configuration in `src_docs/mkdocs.yml`
2. Verify all referenced files exist
3. Check Python package dependencies
4. Review workflow logs for specific errors

### CI Failures

1. Check test failures in pytest output
2. Verify system dependencies are installed
3. Check Python version compatibility
4. Review linting errors from flake8

### Release Failures

1. Verify PyPI token is configured correctly
2. Check package version conflicts
3. Ensure all tests pass before release
4. Review build artifact generation

For more information, see the [GitHub Actions documentation](https://docs.github.com/en/actions).