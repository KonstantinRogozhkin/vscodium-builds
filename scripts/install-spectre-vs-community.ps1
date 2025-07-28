# Install Spectre-mitigated libraries in Visual Studio Community
# Run as administrator

Write-Host "=== Installing Spectre libraries in Visual Studio Community ===" -ForegroundColor Green

# Check if Visual Studio Installer is available
$installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"

if (-not (Test-Path $installerPath)) {
    Write-Host "Visual Studio Installer not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Found Visual Studio Installer: $installerPath" -ForegroundColor Green

# Try to install Spectre libraries via command line
Write-Host "Attempting to install Spectre-mitigated libraries..." -ForegroundColor Cyan

$arguments = @(
    "modify",
    "--installPath", "C:\Program Files\Microsoft Visual Studio\2022\Community",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64.Spectre",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64.Spectre",
    "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64EC.Spectre",
    "--quiet",
    "--norestart"
)

try {
    Write-Host "Running: $installerPath $($arguments -join ' ')" -ForegroundColor Yellow
    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -NoNewWindow
    Write-Host "Installation command completed" -ForegroundColor Green
} catch {
    Write-Host "Error running installer: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nPlease check if Spectre libraries were installed by running:" -ForegroundColor Cyan
Write-Host ".\scripts\check-spectre.ps1" -ForegroundColor White 