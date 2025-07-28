# Complete VSCodium build script with dependency installation
param(
    [string]$Architecture = "x64"
)

Write-Host "Installing dependencies and building VSCodium..." -ForegroundColor Green

# Install Chocolatey if not installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Blue
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install dependencies
Write-Host "Installing Node.js..." -ForegroundColor Blue
choco install nodejs-lts -y

Write-Host "Installing Python..." -ForegroundColor Blue
choco install python -y

Write-Host "Installing Visual Studio Build Tools..." -ForegroundColor Blue
choco install visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools" -y

# Restart PowerShell to get updated PATH
Write-Host "Restarting PowerShell with updated PATH..." -ForegroundColor Yellow
powershell -Command {
    # Set environment variables
    $env:APP_NAME = "VSCodium"
    $env:BINARY_NAME = "codium"
    $env:OS_NAME = "windows"
    $env:VSCODE_ARCH = "x64"
    $env:VSCODE_QUALITY = "stable"
    $env:CI_BUILD = "no"
    $env:SHOULD_BUILD = "yes"
    $env:NODE_OPTIONS = "--max-old-space-size=8192"
    
    Write-Host "Environment variables set" -ForegroundColor Green
    
    # Check dependencies
    try {
        $nodeVersion = node --version
        Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
    } catch {
        Write-Host "Node.js not found" -ForegroundColor Red
        exit 1
    }
    
    try {
        $npmVersion = npm --version
        Write-Host "npm: $npmVersion" -ForegroundColor Green
    } catch {
        Write-Host "npm not found" -ForegroundColor Red
        exit 1
    }
    
    # Get VSCode repository if needed
    if (-not (Test-Path "vscode")) {
        Write-Host "Getting VSCode repository..." -ForegroundColor Blue
        & bash -c "./get_repo.sh"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to get repository" -ForegroundColor Red
            exit 1
        }
    }
    
    # Start build
    Write-Host "Starting build..." -ForegroundColor Blue
    & bash -c "./build.sh"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
}
