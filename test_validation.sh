#!/usr/bin/env bash
# Validation script to test jq-forensics without installation

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 0. Checking project structure ==="
echo "Current directory: $(pwd)"
echo "Script directory: $SCRIPT_DIR"
echo "Checking if src/ exists:"
ls -la src/ 2>&1 || echo "ERROR: src/ directory not found!"
echo ""
echo "Checking src/*.jq files:"
ls -la src/*.jq 2>&1 || echo "ERROR: No .jq files found in src/"
echo ""

echo "=== 1. Creating combined .jq file (like install.sh) ==="
cat > /tmp/test.jq << 'EOF'
# jq-forensics - Forensic analysis functions for jq
# Auto-generated - Do not edit directly

EOF

FILE_COUNT=0
for file in src/*.jq; do
  if [ -f "$file" ]; then
    echo "# Source: $file" >> /tmp/test.jq
    cat "$file" >> /tmp/test.jq
    echo "" >> /tmp/test.jq
    FILE_COUNT=$((FILE_COUNT + 1))
    echo "  Added: $file"
  fi
done

echo "✓ Arquivo combinado criado em /tmp/test.jq"
echo "  Total files added: $FILE_COUNT"
echo "  File size: $(wc -l < /tmp/test.jq) lines"
echo "Últimas 10 linhas:"
tail -10 /tmp/test.jq
echo ""

echo "=== 2. Testing if combined file loads ==="
if echo "null" | jq -f /tmp/test.jq . > /dev/null 2>&1; then
  echo "✓ Arquivo combinado carrega corretamente"
else
  echo "✗ ERRO: Arquivo combinado não carrega"
  echo "null" | jq -f /tmp/test.jq . 2>&1
  exit 1
fi
echo ""

echo "=== 3. Combining with tests.jq ==="
cat /tmp/test.jq tests/tests.jq > /tmp/test_with_tests.jq
echo "✓ Arquivo combinado com tests criado"
echo "Últimas 10 linhas:"
tail -10 /tmp/test_with_tests.jq
echo ""

echo "=== 4. Testing combined file with tests (should execute run_tests) ==="
echo "null" | jq -f /tmp/test_with_tests.jq 2>&1
EXIT_CODE=$?
echo "Exit code: $EXIT_CODE"
echo ""

if [ $EXIT_CODE -ne 0 ]; then
  echo "=== 5. Trying explicit run_tests call ==="
  echo "null" | jq -f /tmp/test.jq -f tests/tests.jq "run_tests" 2>&1
  EXIT_CODE2=$?
  echo "Exit code: $EXIT_CODE2"
  echo ""
fi

echo "=== 6. jq version ==="
jq --version

echo ""
echo "=== Cleanup ==="
rm -f /tmp/test.jq /tmp/test_with_tests.jq
echo "✓ Arquivos temporários removidos"
