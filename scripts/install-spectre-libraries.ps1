# Install Spectre-mitigated libraries via Visual Studio Installer
# Run as administrator

Write-Host "=== Installing Spectre-mitigated libraries ===" -ForegroundColor Green

# Check if Visual Studio Installer is available
$installerPaths = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\Installer\vs_installer.exe"
)

$installerFound = $false
$installerPath = ""

foreach ($path in $installerPaths) {
    if (Test-Path $path) {
        $installerFound = $true
        $installerPath = $path
        Write-Host "Visual Studio Installer found: $path" -ForegroundColor Green
        break
    }
}

if (-not $installerFound) {
    Write-Host "Visual Studio Installer not found!" -ForegroundColor Red
    Write-Host "Please install Visual Studio Build Tools first" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nTo install Spectre-mitigated libraries:" -ForegroundColor Cyan
Write-Host "1. Open Visual Studio Installer" -ForegroundColor White
Write-Host "2. Find 'Build Tools for Visual Studio 2022'" -ForegroundColor White
Write-Host "3. Click 'Modify'" -ForegroundColor White
Write-Host "4. Add these components:" -ForegroundColor White
Write-Host "   - Microsoft.VisualStudio.Component.VC.Tools.x86.x64.Spectre" -ForegroundColor Yellow
Write-Host "   - Microsoft.VisualStudio.Component.VC.Tools.ARM64.Spectre" -ForegroundColor Yellow
Write-Host "   - Microsoft.VisualStudio.Component.VC.Tools.ARM64EC.Spectre" -ForegroundColor Yellow
Write-Host "5. Click 'Modify' to install" -ForegroundColor White
Write-Host "6. Restart PowerShell after installation" -ForegroundColor White

Write-Host "`nOpening Visual Studio Installer..." -ForegroundColor Cyan
Start-Process $installerPath

Write-Host "`nAfter installation, run: .\scripts\check-spectre.ps1" -ForegroundColor Green 