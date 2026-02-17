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
echo ""
echo "Running tests..."

# jq automatically loads ~/.jq, so we just need to load tests.jq
# tests.jq already has 'run_tests' as top-level expression, so it executes automatically
results=$(echo "null" | jq -f tests/tests.jq 2>&1)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo -e "${RED}✗ Test execution failed:${NC}"
    echo "jq output:"
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
