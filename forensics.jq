# jq-forensics - Forensic analysis functions for jq
# Main module that orchestrates all forensic functions
#
# Usage:
#   jq -L . 'include "forensics"; fromwebkit' data.json
#   or if installed: jq 'fromwebkit' data.json

# Timestamp conversion modules
include "src/fromwebkit";
include "src/toreadable";
