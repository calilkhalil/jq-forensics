# jq-forensics

A collection of specialized jq functions for digital forensics and incident response to convert proprietary formats, parse artifacts, and streamline DFIR analysis without custom parsers.

## Why Not in jq Core?

These functions were originally proposed as PRs to add as built-in functions to jq itself. However, they are better suited as an external module because:

1. **Domain-specific functionality** - These functions are primarily useful for digital forensics and incident response, not general JSON processing
2. **No overhead for others** - Users who don't need forensic analysis don't carry these functions in their jq installation
3. **Faster iteration** - External modules can be updated and improved independently without waiting for jq releases
4. **jq's module system is designed for this** - The `~/.jq` auto-include mechanism allows custom functions to work exactly like built-ins
5. **Follows jq philosophy** - Keep the core lean, extend through modules

The jq maintainers suggested this approach, and it turned out to be the right call - it's easier to maintain, distribute, and use.

## Functions

### Timestamps

- **fromwebkit** - Converts those huge WebKit/Chrome timestamps into ISO 8601
- **toreadable** - Takes any timestamp and makes it human-friendly (YYYY-MM-DD HH:MM:SS)

### Transformations

- **todefang** - Makes malicious URLs/IPs/emails safe to share in docs
- **fromdefang** - Converts them back when you need the original

## Installation

### Option 1: Automatic Installation

**Linux / macOS:**
```bash
git clone https://github.com/calilkhalil/jq-forensics.git
cd jq-forensics
chmod +x scripts/install.sh
./scripts/install.sh
```

**Windows:**
```powershell
git clone https://github.com/calilkhalil/jq-forensics.git
cd jq-forensics
powershell -ExecutionPolicy Bypass -File scripts/install.ps1
```

> **Note:** On Windows, creating symlinks requires either:
> - Running PowerShell as Administrator, OR
> - Enabling Developer Mode in Windows Settings

### Option 2: Manual Installation

**Linux / macOS:**
```bash
# Clone the repository
git clone https://github.com/calilkhalil/jq-forensics.git

# Copy to user directory
mkdir -p ~/.jq-forensics
cp -r jq-forensics/src ~/.jq-forensics/
cp jq-forensics/forensics.jq ~/.jq-forensics/

# Create symlink
ln -sf ~/.jq-forensics/forensics.jq ~/.jq
```

**Windows:**
```powershell
# Clone the repository
git clone https://github.com/calilkhalil/jq-forensics.git

# Copy to user directory
mkdir $env:USERPROFILE\.jq-forensics
cp -r jq-forensics\src $env:USERPROFILE\.jq-forensics\
cp jq-forensics\forensics.jq $env:USERPROFILE\.jq-forensics\

# Create symlink (requires admin)
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.jq" -Target "$env:USERPROFILE\.jq-forensics\forensics.jq"
```

## Quick Start

After installation, the functions work like built-in jq functions:

```bash
# Analyze Chrome history with readable timestamps
jq '.[] | {
  url: .url,
  title: .title,
  last_visit: .last_visit_time | fromwebkit | toreadable
}' History.json

# Defang IOCs from incident report
jq '.indicators | map(todefang)' incident_iocs.json

# Process mixed IOCs in threat intel feed
echo '["http://evil.com", "192.168.1.1", "attacker@phish.org"]' | 
  jq 'map(todefang)'
# ["hxxp://evil[.]com", "192[.]168[.]1[.]1", "attacker[@]phish[.]org"]
```

## Architecture

This project follows the Single Responsibility Principle:
- Each function lives in its own module under `src/`
- `forensics.jq` orchestrates all modules
- Easy to extend: add a new module in `src/` and include it in `forensics.jq`

## Uninstall

### Linux / macOS
```bash
rm -rf ~/.jq-forensics
rm ~/.jq
```

### Windows
```powershell
Remove-Item -Recurse -Force $env:USERPROFILE\.jq-forensics
Remove-Item $env:USERPROFILE\.jq
```

## License

Public Domain / [Unlicense](https://unlicense.org)

This software is released into the public domain. You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.
