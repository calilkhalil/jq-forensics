#!/usr/bin/env bash
set -e

# Get script directory and change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

INSTALL_DIR="${HOME}/.jq-forensics"
JQ_FILE="${HOME}/.jq"

echo "Installing jq-forensics..."

# Create installation directory
mkdir -p "${INSTALL_DIR}"

# Copy all module files
echo "Copying module files to ${INSTALL_DIR}..."
cp -r src "${INSTALL_DIR}/"
cp forensics.jq "${INSTALL_DIR}/"

# Build single .jq file by concatenating all modules
echo "Building combined jq module..."
cat > "${INSTALL_DIR}/.jq" << 'EOF'
# jq-forensics - Forensic analysis functions for jq
# Auto-generated - Do not edit directly

EOF

# Concatenate all source modules (from project root)
for file in src/*.jq; do
    if [ -f "$file" ]; then
        echo "# Source: $file" >> "${INSTALL_DIR}/.jq"
        cat "$file" >> "${INSTALL_DIR}/.jq"
        echo "" >> "${INSTALL_DIR}/.jq"
    fi
done

# Check if ~/.jq exists and handle appropriately
if [ -e "${JQ_FILE}" ] && [ ! -L "${JQ_FILE}" ]; then
    echo ""
    echo "Warning: ${JQ_FILE} already exists and is not a symlink."
    echo "Removing existing file (CI/automated install)..."
    rm -f "${JQ_FILE}"
fi

# Create symlink (force to overwrite existing symlink)
echo "Creating symlink ${JQ_FILE} -> ${INSTALL_DIR}/.jq..."
ln -sf "${INSTALL_DIR}/.jq" "${JQ_FILE}"

echo ""
echo "Installation complete."
echo ""
echo "Available functions:"
echo "  - fromwebkit    Convert WebKit/Chrome timestamps"
echo "  - fromcocoa     Convert macOS/iOS Cocoa timestamps"
echo "  - fromunix      Convert Unix timestamps"
echo "  - toreadable    Convert timestamps to readable format"
echo "  - todefang      Defang IOCs (URLs, IPs, emails)"
echo "  - fromdefang    Restore defanged IOCs"
echo ""
echo "Usage examples:"
echo "  echo '13318523932000000' | jq 'fromwebkit'"
echo "  echo '13318523932000000' | jq 'fromwebkit | toreadable'"
echo "  echo '1741420298' | jq 'fromunix | toreadable'"