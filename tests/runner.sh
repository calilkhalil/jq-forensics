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

# Change to project root
cd "$PROJECT_ROOT"

# Check if profile is installed
if [ ! -f "$HOME/.jq" ] && [ ! -L "$HOME/.jq" ]; then
    echo -e "${RED}Error: jq-forensics profile not installed${NC}"
    echo "Please run: bash scripts/install.sh"
    exit 1
fi

# Check if tests.jq exists
if [ ! -f "tests/tests.jq" ]; then
    echo -e "${RED}Error: tests/tests.jq not found${NC}"
    exit 1
fi

echo "Profile installed: $HOME/.jq"
echo "Verifying functions are available..."
# Quick test to ensure functions are loaded
if ! echo "13318523932000000" | jq 'fromwebkit' > /dev/null 2>&1; then
    echo -e "${RED}Error: Functions not available. Profile may not be loading correctly.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Functions loaded${NC}"

# Verify tests.jq syntax
echo "Verifying tests.jq syntax..."
if ! echo "null" | jq -f tests/tests.jq > /dev/null 2>&1; then
    echo -e "${RED}Error: tests/tests.jq has syntax errors${NC}"
    echo "null" | jq -f tests/tests.jq 2>&1 || true
    exit 1
fi
echo -e "${GREEN}✓ tests.jq syntax OK${NC}"
echo ""
echo "Running tests..."

# jq automatically loads ~/.jq, so we just need to load tests.jq
# tests.jq already has 'run_tests' as top-level expression, so it executes automatically
# We pass 'null' as input, but tests.jq ignores it and just runs run_tests
echo "Executing: echo 'null' | jq -f tests/tests.jq"
results=$(echo "null" | jq -f tests/tests.jq 2>&1)
exit_code=$?

echo "jq exit code: $exit_code"
echo "jq output (first 500 chars):"
echo "$results" | head -c 500
echo ""

if [ $exit_code -ne 0 ]; then
    echo -e "${RED}✗ Test execution failed (exit code: $exit_code):${NC}"
    echo "Full jq output:"
    echo "$results"
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
    echo "Raw output:"
    echo "$results"
    echo ""
    echo "Trying to parse as JSON..."
    echo "$results" | jq . 2>&1 || true
    exit 1
fi

# Verify results is an array
array_check=$(echo "$results" | jq -r 'type == "array"' 2>/dev/null || echo "false")
if [ "$array_check" != "true" ]; then
    echo -e "${RED}✗ Test results are not an array (type: $(echo "$results" | jq -r 'type' 2>/dev/null || echo "unknown")):${NC}"
    echo "$results"
    exit 1
fi

# Parse results and display
echo "$results" | jq -r '.[] | if .passed then "✓ \(.name)" else "✗ \(.name)" end' | while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" == ✓* ]]; then
        echo -e "${GREEN}$line${NC}"
    else
        echo -e "${RED}$line${NC}"
    fi
done

# Count totals from the results
total_passed=$(echo "$results" | jq -r '[.[] | select(.passed == true)] | length' 2>/dev/null || echo "0")
total_failed=$(echo "$results" | jq -r '[.[] | select(.passed == false)] | length' 2>/dev/null || echo "0")
total=$(echo "$results" | jq -r 'length' 2>/dev/null || echo "0")

echo ""
echo "=========================================="
echo -e "Total: $total | ${GREEN}Passed: $total_passed${NC} | ${RED}Failed: $total_failed${NC}"
echo "=========================================="

if [ "$total_failed" -eq 0 ]; then
    exit 0
else
    exit 1
fi
