#!/bin/bash
# Install cclogviewer-mcp globally
# Tries: 1) Download pre-built binary  2) go install  3) Build from source

set -e

BINARY_NAME="cclogviewer-mcp"
INSTALL_DIR="${HOME}/.local/bin"
REPO="SeleznovIvan/cclogviewer"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
error() { echo -e "${RED}$1${NC}"; }

# Ensure install directory exists
mkdir -p "$INSTALL_DIR"

# Check if already installed
if command -v "$BINARY_NAME" &> /dev/null; then
    info "✓ $BINARY_NAME is already installed at $(which $BINARY_NAME)"
    exit 0
fi

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
[[ "$ARCH" == "x86_64" ]] && ARCH="amd64"
[[ "$ARCH" == "aarch64" ]] && ARCH="arm64"

# Handle Windows (if running in Git Bash/WSL)
SUFFIX=""
if [[ "$OS" == "mingw"* ]] || [[ "$OS" == "msys"* ]] || [[ "$OS" == "cygwin"* ]]; then
    OS="windows"
    SUFFIX=".exe"
    BINARY_NAME="cclogviewer-mcp.exe"
fi

echo "Detected platform: ${OS}-${ARCH}"
echo ""

# Method 1: Download pre-built binary (primary)
RELEASE_URL="https://github.com/${REPO}/releases/latest/download/cclogviewer-mcp-${OS}-${ARCH}${SUFFIX}"

echo "Attempting to download pre-built binary..."
if curl -fsSL "$RELEASE_URL" -o "$INSTALL_DIR/$BINARY_NAME" 2>/dev/null; then
    chmod +x "$INSTALL_DIR/$BINARY_NAME"
    info "✓ Installed to $INSTALL_DIR/$BINARY_NAME"

    # Check if INSTALL_DIR is in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        warn ""
        warn "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        warn "  export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
    exit 0
fi

warn "Pre-built binary not available for ${OS}-${ARCH}"
echo ""

# Method 2: go install (fallback)
if command -v go &> /dev/null; then
    echo "Attempting go install..."
    if go install "github.com/${REPO}/cmd/cclogviewer-mcp@latest" 2>/dev/null; then
        info "✓ Installed via go install"
        exit 0
    fi
    warn "go install failed"
    echo ""
fi

# Method 3: Build from source (last resort)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
CCLOGVIEWER_DIR="$PLUGIN_ROOT/mcp/cclogviewer"

if [[ -d "$CCLOGVIEWER_DIR" ]] && command -v go &> /dev/null; then
    echo "Attempting to build from source..."
    cd "$CCLOGVIEWER_DIR"
    if make build-mcp 2>/dev/null; then
        cp bin/cclogviewer-mcp "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/$BINARY_NAME"
        info "✓ Built and installed to $INSTALL_DIR/$BINARY_NAME"
        exit 0
    fi
    warn "Build from source failed"
fi

# All methods failed
error ""
error "ERROR: Could not install $BINARY_NAME"
error ""
echo "Please install manually:"
echo "  1. Download from: https://github.com/${REPO}/releases"
echo "  2. Or install Go 1.21+ and run:"
echo "     go install github.com/${REPO}/cmd/cclogviewer-mcp@latest"
exit 1
