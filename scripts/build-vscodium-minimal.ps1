# Minimal VSCodium build without WiX Toolset
# Run as administrator

Write-Host "=== Building VSCodium with minimal dependencies ===" -ForegroundColor Green

# Set environment variables to disable Spectre mitigation
$env:CFLAGS = "/Qspectre-"
$env:CXXFLAGS = "/Qspectre-"
$env:MSVC_SPECTRE_LIBS = "0"
$env:SPECTRE_MITIGATION = "0"

# Disable WiX Toolset requirement
$env:SKIP_WIX = "1"
$env:BUILD_WITHOUT_WIX = "1"

Write-Host "Environment variables set:" -ForegroundColor Cyan
Write-Host "CFLAGS: $env:CFLAGS" -ForegroundColor White
Write-Host "CXXFLAGS: $env:CXXFLAGS" -ForegroundColor White
Write-Host "MSVC_SPECTRE_LIBS: $env:MSVC_SPECTRE_LIBS" -ForegroundColor White
Write-Host "SPECTRE_MITIGATION: $env:SPECTRE_MITIGATION" -ForegroundColor White
Write-Host "SKIP_WIX: $env:SKIP_WIX" -ForegroundColor White

# Check if we're in the right directory
if (-not (Test-Path "dev\build.ps1")) {
    Write-Host "Error: dev\build.ps1 not found!" -ForegroundColor Red
    Write-Host "Please run this script from the vscodium-builds directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nStarting VSCodium build with minimal dependencies..." -ForegroundColor Cyan
Write-Host "This may take a long time..." -ForegroundColor Yellow
Write-Host "Note: WiX Toolset is disabled, installer may not be created" -ForegroundColor Yellow

try {
    # Run the build script
    & "powershell" "-ExecutionPolicy" "ByPass" "-File" ".\dev\build.ps1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=== BUILD SUCCESSFUL ===" -ForegroundColor Green
        Write-Host "VSCodium has been built successfully!" -ForegroundColor Green
        Write-Host "Note: Installer may not be available due to missing WiX Toolset" -ForegroundColor Yellow
    } else {
        Write-Host "`n=== BUILD FAILED ===" -ForegroundColor Red
        Write-Host "Build failed with exit code: $LASTEXITCODE" -ForegroundColor Red
    }
} catch {
    Write-Host "`n=== BUILD ERROR ===" -ForegroundColor Red
    Write-Host "Error during build: $($_.Exception.Message)" -ForegroundColor Red
}

# Clear environment variables
Remove-Item Env:CFLAGS -ErrorAction SilentlyContinue
Remove-Item Env:CXXFLAGS -ErrorAction SilentlyContinue
Remove-Item Env:MSVC_SPECTRE_LIBS -ErrorAction SilentlyContinue
Remove-Item Env:SPECTRE_MITIGATION -ErrorAction SilentlyContinue
Remove-Item Env:SKIP_WIX -ErrorAction SilentlyContinue
Remove-Item Env:BUILD_WITHOUT_WIX -ErrorAction SilentlyContinue

Write-Host "`nBuild script completed!" -ForegroundColor Green 