#!/bin/bash
# this_file: scripts/release.sh

set -e

echo "🚀 AudioStretchy Release Script"
echo "==============================="

# Check if we're in the right directory
if [ ! -f "pyproject.toml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Check if version is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a version number"
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.3"
    exit 1
fi

VERSION=$1

# Validate version format (basic semver check)
if ! echo "$VERSION" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$' >/dev/null; then
    echo "❌ Error: Version must be in semver format (e.g., 1.2.3 or 1.2.3-beta)"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Error: Releases can only be made from the main branch"
    echo "Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Error: Working directory is not clean. Please commit all changes first."
    git status
    exit 1
fi

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Run tests
echo "🧪 Running tests..."
./scripts/test.sh

# Build the package
echo "🏗️ Building package..."
./scripts/build.sh

# Create git tag
echo "🏷️ Creating git tag v$VERSION..."
git tag -a "v$VERSION" -m "Release version $VERSION"

# Push tag to remote
echo "📤 Pushing tag to remote..."
git push origin "v$VERSION"

echo "✅ Release process completed!"
echo "🎉 Version $VERSION has been tagged and pushed"
echo "📝 GitHub Actions will now build and publish the release"
echo "🔗 Create a release at: https://github.com/$(git config remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/releases/new?tag=v$VERSION"