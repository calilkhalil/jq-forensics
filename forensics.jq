# jq-forensics - Forensic analysis functions for jq
# Main module that orchestrates all forensic functions


# Timestamp modules
include "src/fromwebkit";
include "src/toreadable";

# Transformation modules
include "src/todefang";
include "src/fromdefang";