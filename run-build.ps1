# Simple build runner
$env:PATH = "C:\Program Files\nodejs;C:\Program Files\Git\bin;C:\Python311;C:\ProgramData\chocolatey\bin;" + $env:PATH

# Set environment variables
$env:APP_NAME = "VSCodium"
$env:BINARY_NAME = "codium"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = "x64"
$env:VSCODE_QUALITY = "stable"
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Write-Host "Checking dependencies..." -ForegroundColor Blue

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Node.js not found - installing..." -ForegroundColor Yellow
    choco install nodejs-lts -y
}

# Check npm
try {
    $npmVersion = npm --version
    Write-Host "npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "npm not found" -ForegroundColor Red
}

Write-Host "Starting build..." -ForegroundColor Blue
& bash -c "./build.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
}
