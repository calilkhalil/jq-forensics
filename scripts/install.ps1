# jq-forensics installer for Windows
$ErrorActionPreference = "Stop"

$InstallDir = "$env:USERPROFILE\.jq-forensics"
$JqFile = "$env:USERPROFILE\.jq"

Write-Host "Installing jq-forensics..."

# Create installation directory
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

# Copy module files
Write-Host "Copying module files to $InstallDir..."
Copy-Item -Path "src" -Destination $InstallDir -Recurse -Force
Copy-Item -Path "forensics.jq" -Destination $InstallDir -Force

# Check if .jq exists
if (Test-Path $JqFile) {
    $isSymlink = (Get-Item $JqFile).Attributes -band [System.IO.FileAttributes]::ReparsePoint
    
    if (-not $isSymlink) {
        Write-Host ""
        Write-Host "Warning: $JqFile already exists and is not a symlink." -ForegroundColor Yellow
        Write-Host "Please backup your existing file and remove it, then run:"
        Write-Host "  New-Item -ItemType SymbolicLink -Path '$JqFile' -Target '$InstallDir\forensics.jq'"
        Write-Host ""
        exit 1
    }
    
    # Remove existing symlink
    Remove-Item $JqFile -Force
}

# Create symlink (requires admin privileges or Developer Mode on Windows 10+)
Write-Host "Creating symlink $JqFile -> $InstallDir\forensics.jq..."
try {
    New-Item -ItemType SymbolicLink -Path $JqFile -Target "$InstallDir\forensics.jq" -Force | Out-Null
    Write-Host ""
    Write-Host "Installation complete." -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "Error: Could not create symlink (requires administrator privileges)." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator, or enable Developer Mode in Windows Settings."
    Write-Host ""
    Write-Host "Alternative methods:"
    Write-Host "  1. Create symlink manually with administrator PowerShell:"
    Write-Host "     New-Item -ItemType SymbolicLink -Path '$JqFile' -Target '$InstallDir\forensics.jq'"
    Write-Host ""
    Write-Host "  2. Copy the file directly (manual updates required):"
    Write-Host "     Copy-Item '$InstallDir\forensics.jq' '$JqFile'"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "Available functions:"
Write-Host "  - fromwebkit    Convert WebKit/Chrome timestamps"
Write-Host "  - toreadable    Convert timestamps to readable format"
Write-Host ""
Write-Host "Usage examples:"
Write-Host '  echo 13318523932000000 | jq "fromwebkit"'
Write-Host '  echo 13318523932000000 | jq "fromwebkit | toreadable"'
