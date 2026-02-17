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
# Change to project root to ensure relative includes work correctly
cd "$PROJECT_ROOT"

# Try to load and run tests
# First, test if forensics.jq loads correctly
if ! echo "null" | jq -L . -f forensics.jq . > /dev/null 2>&1; then
    echo -e "${RED}✗ Error: forensics.jq failed to load${NC}"
    echo "Trying to load forensics.jq:"
    echo "null" | jq -L . -f forensics.jq . 2>&1 || true
    exit 1
fi

# Load both files and run tests
# Combine the files content and pipe to jq
results=$(cat forensics.jq tests/tests.jq | jq -L . 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo -e "${RED}✗ Test execution failed:${NC}"
    echo "$results"
    echo ""
    echo "Debug info:"
    echo "  PROJECT_ROOT: $PROJECT_ROOT"
    echo "  FORENSICS_JQ: $FORENSICS_JQ"
    echo "  TESTS_JQ: $TESTS_JQ"
    echo "  Exit code: $exit_code"
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
