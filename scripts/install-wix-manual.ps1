# Manual WiX Toolset installation
Write-Host "=== Installing WiX Toolset manually ===" -ForegroundColor Green

# Check if already installed
$wixPath = "C:\Program Files (x86)\WiX Toolset v3.11\bin"
if (Test-Path $wixPath) {
    Write-Host "WiX Toolset already installed at: $wixPath" -ForegroundColor Green
    exit 0
}

# Download WiX Toolset
$wixUrl = "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311.exe"
$wixFile = "$env:TEMP\wix311.exe"

Write-Host "Downloading WiX Toolset..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $wixUrl -OutFile $wixFile -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Install WiX Toolset
Write-Host "Installing WiX Toolset..." -ForegroundColor Cyan
try {
    Start-Process -FilePath $wixFile -ArgumentList "/quiet" -Wait
    Write-Host "Installation completed!" -ForegroundColor Green
} catch {
    Write-Host "Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Clean up
Remove-Item $wixFile -Force -ErrorAction SilentlyContinue

# Verify installation
if (Test-Path $wixPath) {
    Write-Host "WiX Toolset successfully installed!" -ForegroundColor Green
    Write-Host "Path: $wixPath" -ForegroundColor White
} else {
    Write-Host "Installation verification failed!" -ForegroundColor Red
    exit 1
}

Write-Host "WiX Toolset installation completed!" -ForegroundColor Green 