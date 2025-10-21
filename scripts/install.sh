#!/bin/bash

# moke installer script
# Automatically detects architecture and downloads the appropriate binary

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO="pnowosie/moke"
BINARY_NAME="moke"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to detect macOS architecture
detect_arch() {
    local arch
    arch=$(uname -m)
    
    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        arm64)
            echo "arm64"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
}

# Function to detect OS
detect_os() {
    local os
    os=$(uname -s)
    
    case "$os" in
        Darwin)
            echo "darwin"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            print_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac
}

# Function to get the latest release tag
get_latest_tag() {
    local tag
    tag=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [[ -z "$tag" ]]; then
        print_error "Failed to get latest release tag"
        exit 1
    fi
    
    echo "$tag"
}

# Function to download file
download_file() {
    local url="$1"
    local output="$2"
    
    print_info "Downloading $output..."
    if ! curl -L -s -o "$output" "$url"; then
        print_error "Failed to download $output"
        return 1
    fi
    return 0
}

# Function to validate checksum
validate_checksum() {
    local binary_file="$1"
    local checksum_file="$2"
    local expected_checksum
    local actual_checksum
    
    # Extract expected checksum for this binary
    expected_checksum=$(grep "$(basename "$binary_file")" "$checksum_file" | awk '{print $1}')
    
    if [[ -z "$expected_checksum" ]]; then
        print_error "Could not find checksum for $(basename "$binary_file") in checksums file"
        return 1
    fi
    
    # Calculate actual checksum
    actual_checksum=$(shasum -a 256 "$binary_file" | awk '{print $1}')
    
    if [[ "$expected_checksum" != "$actual_checksum" ]]; then
        print_error "Checksum validation failed!"
        print_error "Expected: $expected_checksum"
        print_error "Actual:   $actual_checksum"
        return 1
    else
        print_info "${actual_checksum} ${binary_file}"
    fi
    
    print_success "Checksum validation passed"
    return 0
}

# Function to cleanup on failure
cleanup() {
    local binary_file="$1"
    local checksum_file="$2"
    
    if [[ -f "$binary_file" ]]; then
        rm -f "$binary_file"
        print_info "Removed invalid binary: $binary_file"
    fi
    
    if [[ -f "$checksum_file" ]]; then
        rm -f "$checksum_file"
        print_info "Removed checksum file: $checksum_file"
    fi
}

# Function to cleanup downloaded artifacts
cleanup_artifacts() {
    local os arch binary_name binary_file checksum_file
    
    print_info "Cleaning up downloaded artifacts..."
    
    # Detect system to find the correct binary name
    os=$(detect_os)
    arch=$(detect_arch)
    binary_name="${BINARY_NAME}-${os}-${arch}"
    binary_file="${binary_name}"
    checksum_file="checksums.txt"
    
    local removed_count=0
    
    # Remove binary file
    if [[ -f "$binary_file" ]]; then
        rm -f "$binary_file"
        print_success "Removed binary: $binary_file"
        ((removed_count++))
    fi
    
    # Remove checksum file
    if [[ -f "$checksum_file" ]]; then
        rm -f "$checksum_file"
        print_success "Removed checksum file: $checksum_file"
        ((removed_count++))
    fi
    
    if [[ $removed_count -eq 0 ]]; then
        print_info "No artifacts found to clean up"
    else
        print_success "Cleanup complete! Removed $removed_count file(s)"
    fi
}

# Main installation function
install_moke() {
    local os arch tag binary_name binary_file checksum_file download_url checksum_url
    
    print_info "Starting moke installation..."
    
    # Detect system
    os=$(detect_os)
    arch=$(detect_arch)
    print_info "Detected OS: $os, Architecture: $arch"
    
    # Get latest release tag
    tag=$(get_latest_tag)
    print_info "Latest release: $tag"
    
    # Set up file names and URLs
    binary_name="${BINARY_NAME}-${os}-${arch}"
    binary_file="${binary_name}"
    checksum_file="checksums.txt"
    
    download_url="https://github.com/$REPO/releases/download/$tag/$binary_name"
    checksum_url="https://github.com/$REPO/releases/download/$tag/$checksum_file"
    
    # Download binary and checksum
    if ! download_file "$download_url" "$binary_file"; then
        exit 1
    fi
    
    if ! download_file "$checksum_url" "$checksum_file"; then
        cleanup "$binary_file" "$checksum_file"
        exit 1
    fi
    
    # Validate checksum
    if ! validate_checksum "$binary_file" "$checksum_file"; then
        cleanup "$binary_file" "$checksum_file"
        exit 1
    fi
    
    # Make binary executable
    chmod +x "$binary_file"
    print_success "Binary made executable"
    
    # Test the binary
    print_info "Testing binary..."
    if ! ./"$binary_file" -v >/dev/null 2>&1; then
        print_error "Binary test failed"
        cleanup "$binary_file" "$checksum_file"
        exit 1
    fi
    
    # Show version info
    print_info "Binary version info:"
    ./"$binary_file" -v
    
    # Install to system directory (optional)
    if [[ "${1:-}" == "--install" ]]; then
        print_info "Installing to $INSTALL_DIR..."
        if sudo mv "$binary_file" "$INSTALL_DIR/$BINARY_NAME"; then
            print_success "Installed moke to $INSTALL_DIR/$BINARY_NAME"
            print_info "You can now run: $BINARY_NAME -v"
        else
            print_error "Failed to install to $INSTALL_DIR"
            print_info "Binary is available as: ./$binary_file"
        fi
    else
        print_success "Binary ready: ./$binary_file"
        print_info "To install system-wide, run: $0 --install"
    fi
    
    # Cleanup checksum file
    rm -f "$checksum_file"
    
    print_info "Installation complete!"
}

# Show usage
show_usage() {
    echo "Usage: $0 [--download|--install|--cleanup]"
    echo ""
    echo "Options:"
    echo "  --download   Download and prepare binary locally"
    echo "  --install    Download and install binary to $INSTALL_DIR (requires sudo)"
    echo "  --cleanup    Remove downloaded artifacts from current directory"
    echo "  --help       Show this help message"
    echo ""
}

# Main script logic
main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --download)
            install_moke
            ;;
        --install)
            install_moke --install
            ;;
        --cleanup)
            cleanup_artifacts
            ;;
        "")
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
