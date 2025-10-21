#!/bin/bash

# Build script for moke with dynamic version information
# This script extracts git information and injects it into the binary at build time

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SEMVER="0.0.0"
DATE="2020-01-01"
HASH="0000000"
PLATFORM="local"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --version)
            SEMVER="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--platform PLATFORM] [--version VERSION]"
            echo "  --platform: Target platform (local, linux-amd64, linux-arm64, darwin-amd64, darwin-arm64)"
            echo "  --version: Override version (default: extracted from git)"
            echo "  --help: Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Building moke with dynamic version information...${NC}"
echo -e "${BLUE}Platform: $PLATFORM${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Not in a git repository. Using default version values.${NC}"
else
    # Extract version information from git
    echo "Extracting version information from git..."
    
    # Get version from git describe if not overridden
    if [ "$SEMVER" = "0.0.0" ]; then
        if [ "$PLATFORM" = "local" ]; then
            # For local platform, use 0.0.0-dirty format
            SEMVER="0.0.0-dirty"
        else
            SEMVER=$(git describe --tags --always --dirty 2>/dev/null || echo "0.0.0")
            # Remove 'v' prefix if present
            SEMVER=${SEMVER#v}
        fi
    fi
    
    # Get commit date in YYYY-MM-DD format
    DATE=$(git log -1 --format=%cd --date=short 2>/dev/null || echo "2020-01-01")
    
    # Get short commit hash
    HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "0000000")
    
    echo "  Semver: $SEMVER"
    echo "  Date: $DATE"
    echo "  Hash: $HASH"
fi

# Set build parameters based on platform
case $PLATFORM in
    "local")
        OUTPUT="build/moke"
        GOOS=""
        GOARCH=""
        ;;
    "linux-amd64")
        OUTPUT="build/moke-linux-amd64"
        GOOS="linux"
        GOARCH="amd64"
        ;;
    "linux-arm64")
        OUTPUT="build/moke-linux-arm64"
        GOOS="linux"
        GOARCH="arm64"
        ;;
    "darwin-amd64")
        OUTPUT="build/moke-darwin-amd64"
        GOOS="darwin"
        GOARCH="amd64"
        ;;
    "darwin-arm64")
        OUTPUT="build/moke-darwin-arm64"
        GOOS="darwin"
        GOARCH="arm64"
        ;;
    *)
        echo -e "${RED}Error: Unknown platform '$PLATFORM'${NC}"
        echo "Supported platforms: local, linux-amd64, linux-arm64, darwin-amd64, darwin-arm64"
        exit 1
        ;;
esac

# Create build directory
mkdir -p build

# Build the application with dynamic version information
echo "Building application for $PLATFORM..."
if [ -n "$GOOS" ] && [ -n "$GOARCH" ]; then
    GOOS=$GOOS GOARCH=$GOARCH go build -ldflags "-X main.Semver=$SEMVER -X main.Date=$DATE -X main.Hash=$HASH" -o $OUTPUT cmd/moke.go
else
    go build -ldflags "-X main.Semver=$SEMVER -X main.Date=$DATE -X main.Hash=$HASH" -o $OUTPUT cmd/moke.go
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    echo "Binary created: $OUTPUT"
    
    # Make executable
    chmod +x $OUTPUT
    
    # Test the version output
    echo ""
    echo "Testing version output:"
    $OUTPUT -v
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
