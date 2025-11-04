#!/usr/bin/env bash
set -e

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

# Concatenate all source modules
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
    echo "Please backup your existing file and remove it, then run:"
    echo "  ln -sf ${INSTALL_DIR}/.jq ${JQ_FILE}"
    echo ""
    exit 1
fi

# Create symlink
echo "Creating symlink ${JQ_FILE} -> ${INSTALL_DIR}/.jq..."
ln -sf "${INSTALL_DIR}/.jq" "${JQ_FILE}"

echo ""
echo "Installation complete."
echo ""
echo "Available functions:"
echo "  - fromwebkit    Convert WebKit/Chrome timestamps"
echo "  - toreadable    Convert timestamps to readable format"
echo ""
echo "Usage examples:"
echo "  echo '13318523932000000' | jq 'fromwebkit'"
echo "  echo '13318523932000000' | jq 'fromwebkit | toreadable'"
