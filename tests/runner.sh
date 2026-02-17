#!/usr/bin/env bash
# Test runner for jq-forensics using jq pipelines
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Running jq-forensics tests..."
echo ""

# Load forensics functions and run tests
FORENSICS_JQ="$PROJECT_ROOT/forensics.jq"
TESTS_JQ="$SCRIPT_DIR/tests.jq"

if [ ! -f "$FORENSICS_JQ" ]; then
    echo -e "${RED}Error: forensics.jq not found at $FORENSICS_JQ${NC}"
    exit 1
fi

if [ ! -f "$TESTS_JQ" ]; then
    echo -e "${RED}Error: tests.jq not found at $TESTS_JQ${NC}"
    exit 1
fi

# Run tests and process results
# Change to project root
cd "$PROJECT_ROOT"

# Use the installed profile or create combined .jq file
if [ -L "$HOME/.jq" ] || [ -f "$HOME/.jq" ]; then
    # Profile is installed, resolve symlink to get actual file
    if [ -L "$HOME/.jq" ]; then
        JQ_FILE=$(readlink -f "$HOME/.jq")
    else
        JQ_FILE="$HOME/.jq"
    fi
    echo "Using installed profile: $JQ_FILE"
elif [ -f "$HOME/.jq-forensics/.jq" ]; then
    # Use the file from install directory
    JQ_FILE="$HOME/.jq-forensics/.jq"
    echo "Using profile from install directory: $JQ_FILE"
elif [ -f ".jq" ]; then
    # Combined file exists in project root
    JQ_FILE=".jq"
    echo "Using .jq from project root"
else
    # Create combined .jq file like install script does
    echo "Creating combined .jq file..."
    cat > .jq << 'EOF'
# jq-forensics - Forensic analysis functions for jq
# Auto-generated - Do not edit directly

EOF
    
    # Concatenate all source modules
    for file in src/*.jq; do
        if [ -f "$file" ]; then
            echo "# Source: $file" >> .jq
            cat "$file" >> .jq
            echo "" >> .jq
        fi
    done
    JQ_FILE=".jq"
    echo "Created .jq file in project root"
fi

echo "JQ_FILE: $JQ_FILE"
echo "Testing if file exists and is readable:"
ls -la "$JQ_FILE" || echo "ERROR: File not found!"

# Load combined .jq file and tests
# Combine both files into one (like install.sh does)
# tests.jq ends with "run_tests" which will execute automatically
echo ""
echo "Running tests..."

# Create temporary combined file
TEMP_FILE=$(mktemp)
cat "$JQ_FILE" tests/tests.jq > "$TEMP_FILE"

# Debug: show last few lines of combined file to verify run_tests is there
echo "Last 5 lines of combined file:"
tail -5 "$TEMP_FILE"
echo ""

# When using -f with a file that ends with a top-level expression,
# jq automatically executes that expression
# Since tests.jq ends with "run_tests", it will execute automatically
echo "Executing jq..."
results=$(echo "null" | jq -f "$TEMP_FILE" 2>&1)
exit_code=$?

# Clean up temp file
rm -f "$TEMP_FILE"

if [ $exit_code -ne 0 ]; then
    echo -e "${RED}✗ Test execution failed:${NC}"
    echo "jq output:"
    echo "$results"
    echo ""
    echo "Debug info:"
    echo "  PROJECT_ROOT: $PROJECT_ROOT"
    echo "  JQ_FILE: $JQ_FILE"
    echo "  TESTS_JQ: $TESTS_JQ"
    echo "  Exit code: $exit_code"
    echo ""
    echo "Trying to validate syntax..."
    # Try to check if the combined file has valid syntax
    echo "null" | jq -f "$JQ_FILE" . > /dev/null 2>&1 && echo "JQ_FILE syntax OK" || echo "JQ_FILE has syntax errors"
    echo "null" | jq -f tests/tests.jq . > /dev/null 2>&1 && echo "tests.jq syntax OK" || echo "tests.jq has syntax errors"
    exit 1
fi

# Check if results are empty or invalid
if [ -z "$results" ]; then
    echo -e "${RED}✗ Test execution produced no output${NC}"
    exit 1
fi

# Verify results is valid JSON
if ! echo "$results" | jq empty 2>/dev/null; then
    echo -e "${RED}✗ Test results are not valid JSON:${NC}"
    echo "$results"
    exit 1
fi

# Parse results and display
echo "$results" | jq -r '.[] | if .passed then "✓ \(.name)" else "✗ \(.name)" end' | while read -r line; do
    if [[ "$line" == ✓* ]]; then
        echo -e "${GREEN}$line${NC}"
    else
        echo -e "${RED}$line${NC}"
    fi
done

# Count totals from the results
total_passed=$(echo "$results" | jq '[.[] | select(.passed == true)] | length')
total_failed=$(echo "$results" | jq '[.[] | select(.passed == false)] | length')
total=$(echo "$results" | jq 'length')

echo ""
echo "=========================================="
echo -e "Total: $total | ${GREEN}Passed: $total_passed${NC} | ${RED}Failed: $total_failed${NC}"
echo "=========================================="

if [ "$total_failed" -eq 0 ]; then
    exit 0
else
    exit 1
fi
