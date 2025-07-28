# Simple VSCodium build script
param(
    [string]$Architecture = "x64"
)

Write-Host "Starting VSCodium build..." -ForegroundColor Green

# Add paths to programs
$env:PATH += ";C:\Program Files\nodejs"
$env:PATH += ";C:\Program Files\Git\bin"
$env:PATH += ";C:\Python311"
$env:PATH += ";C:\ProgramData\chocolatey\bin"

# Set environment variables
$env:APP_NAME = "Neira"
$env:BINARY_NAME = "neira"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = $Architecture
$env:VSCODE_QUALITY = "stable"
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Write-Host "Environment variables set" -ForegroundColor Green

# Check Git
try {
    $gitVersion = git --version
    Write-Host "Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "Git not found" -ForegroundColor Red
    return
}

# Get VSCode repository if needed
if (-not (Test-Path "vscode")) {
    Write-Host "Getting VSCode repository..." -ForegroundColor Blue
    & bash -c "./get_repo.sh"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to get repository" -ForegroundColor Red
        return
    }
}

# Start build
Write-Host "Starting build process..." -ForegroundColor Blue

if (Test-Path "build.sh") {
    & bash -c "./build.sh"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "build.sh not found" -ForegroundColor Red
}
