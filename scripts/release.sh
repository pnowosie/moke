#!/bin/bash

# Release script for moke
# This script helps create version tags and trigger releases

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [VERSION]"
    echo ""
    echo "Commands:"
    echo "  create VERSION    Create a new release with the specified version"
    echo "  list             List existing tags"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 create 1.0.0"
    echo "  $0 create 1.2.3-beta"
    echo "  $0 list"
    echo ""
    echo "Version format:"
    echo "  - Use semantic versioning (e.g., 1.0.0, 1.2.3, 2.0.0-beta)"
    echo "  - The script will automatically add 'v' prefix to the tag"
}

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\-\.]+)?$ ]]; then
        echo -e "${RED}Error: Invalid version format '$version'${NC}"
        echo "Version should follow semantic versioning (e.g., 1.0.0, 1.2.3-beta)"
        exit 1
    fi
}

# Function to check if tag exists
tag_exists() {
    local tag=$1
    git rev-parse "refs/tags/$tag" >/dev/null 2>&1
}

# Function to create release
create_release() {
    local version=$1
    local tag="v$version"
    
    echo -e "${BLUE}Creating release for version $version...${NC}"
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${RED}Error: Not in a git repository${NC}"
        exit 1
    fi
    
    # Check if working directory is clean
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}Warning: Working directory has uncommitted changes${NC}"
        echo "Please commit or stash your changes before creating a release"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Release cancelled"
            exit 1
        fi
    fi
    
    # Check if tag already exists
    if tag_exists "$tag"; then
        echo -e "${RED}Error: Tag '$tag' already exists${NC}"
        echo "Use 'git tag -d $tag' to delete it locally, or 'git push origin :refs/tags/$tag' to delete it remotely"
        exit 1
    fi
    
    # Create and push tag
    echo "Creating tag '$tag'..."
    git tag -a "$tag" -m "Release $version"
    
    echo "Pushing tag to remote..."
    git push origin "$tag"
    
    echo -e "${GREEN}Release '$version' created successfully!${NC}"
    echo ""
    echo "The GitHub Actions workflow will now:"
    echo "1. Build binaries for Linux (amd64, arm64) and macOS (amd64, arm64)"
    echo "2. Create a GitHub release with downloadable binaries"
    echo "3. Upload checksums for verification"
    echo ""
    echo "You can monitor the progress at:"
    echo "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/actions"
}

# Function to list tags
list_tags() {
    echo -e "${BLUE}Existing tags:${NC}"
    git tag -l --sort=-version:refname | head -20
    echo ""
    echo "Use 'git tag -l' to see all tags"
}

# Main script logic
case "${1:-help}" in
    "create")
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Version required${NC}"
            echo ""
            show_usage
            exit 1
        fi
        validate_version "$2"
        create_release "$2"
        ;;
    "list")
        list_tags
        ;;
    "help"|"--help"|"-h")
        show_usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac
