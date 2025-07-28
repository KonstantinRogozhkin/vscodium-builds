# Install Visual Studio Community 2022 with Spectre-mitigated libraries
# Run as administrator

Write-Host "=== Installing Visual Studio Community 2022 ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Function to download and install Visual Studio Community
function Install-VSCommunity {
    Write-Host "Downloading Visual Studio Community 2022..." -ForegroundColor Cyan
    
    # URL for Visual Studio Community 2022
    $vsUrl = "https://aka.ms/vs/17/release/vs_community.exe"
    $vsFile = "vs_community.exe"
    
    try {
        # Download installer
        Write-Host "Downloading from: $vsUrl" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $vsUrl -OutFile $vsFile -UseBasicParsing
        
        Write-Host "Installing Visual Studio Community with required components..." -ForegroundColor Cyan
        
        # Installation parameters including all necessary components
        $arguments = @(
            "--quiet",
            "--wait",
            "--norestart",
            "--nocache",
            "--installPath", "C:\Program Files\Microsoft Visual Studio\2022\Community",
            "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
            "--add", "Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre",
            "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",
            "--add", "Microsoft.VisualStudio.Component.Windows10SDK.20348",
            "--add", "Microsoft.VisualStudio.Component.Windows11SDK.22621",
            "--add", "Microsoft.VisualStudio.Component.VC.ATL",
            "--add", "Microsoft.VisualStudio.Component.VC.ATLMFC",
            "--add", "Microsoft.VisualStudio.Component.VC.CLI.Support",
            "--add", "Microsoft.VisualStudio.Component.VC.Modules.x86.x64",
            "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64EC",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64.Spectre",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64.Spectre",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64EC.Spectre"
        )
        
        # Start installation
        Write-Host "Starting installation with parameters: $($arguments -join ' ')" -ForegroundColor Yellow
        Start-Process $vsFile -Wait -ArgumentList $arguments
        
        # Remove installer
        Remove-Item $vsFile -Force
        
        Write-Host "Visual Studio Community installed successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error installing Visual Studio Community: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Check if Visual Studio Community is already installed
$vsCommunityPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community"
)

$vsCommunityFound = $false
$vsCommunityPath = ""

foreach ($path in $vsCommunityPaths) {
    if (Test-Path "$path\VC\Auxiliary\Build\vcvars64.bat") {
        $vsCommunityFound = $true
        $vsCommunityPath = $path
        Write-Host "Visual Studio Community found: $path" -ForegroundColor Green
        break
    }
}

if ($vsCommunityFound) {
    Write-Host "Visual Studio Community is already installed!" -ForegroundColor Green
    
    # Check if Spectre libraries are available
    $spectrePaths = @(
        "$vsCommunityPath\VC\Tools\MSVC\*\lib\x64\spectre",
        "$vsCommunityPath\VC\Tools\MSVC\*\lib\x86\spectre",
        "$vsCommunityPath\VC\Tools\MSVC\*\lib\arm64\spectre"
    )
    
    $spectreFound = $false
    foreach ($path in $spectrePaths) {
        if (Test-Path $path) {
            Write-Host "✓ Spectre libraries found: $path" -ForegroundColor Green
            $spectreFound = $true
        }
    }
    
    if ($spectreFound) {
        Write-Host "`n=== SUCCESS ===" -ForegroundColor Green
        Write-Host "Visual Studio Community with Spectre libraries is ready!" -ForegroundColor Green
        Write-Host "You can now build VSCodium." -ForegroundColor Green
    } else {
        Write-Host "`n=== MODIFICATION NEEDED ===" -ForegroundColor Yellow
        Write-Host "Visual Studio Community is installed but Spectre libraries are missing." -ForegroundColor Yellow
        Write-Host "Please modify the installation to add Spectre-mitigated libraries." -ForegroundColor Yellow
        
        # Try to open Visual Studio Installer
        $installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
        if (Test-Path $installerPath) {
            Write-Host "Opening Visual Studio Installer..." -ForegroundColor Cyan
            Start-Process $installerPath
        }
    }
} else {
    Write-Host "Visual Studio Community not found. Installing..." -ForegroundColor Yellow
    
    # Check available disk space (need at least 10 GB)
    $drive = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    
    Write-Host "Available disk space: $freeSpaceGB GB" -ForegroundColor Cyan
    
    if ($freeSpaceGB -lt 10) {
        Write-Host "Warning: Less than 10 GB free space available!" -ForegroundColor Red
        Write-Host "Visual Studio Community requires significant disk space." -ForegroundColor Yellow
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Host "Installation cancelled." -ForegroundColor Yellow
            exit 1
        }
    }
    
    # Install Visual Studio Community
    $installSuccess = Install-VSCommunity
    
    if ($installSuccess) {
        Write-Host "`n=== INSTALLATION COMPLETED ===" -ForegroundColor Green
        Write-Host "Visual Studio Community has been installed successfully!" -ForegroundColor Green
        Write-Host "Please restart your computer to ensure all components are properly configured." -ForegroundColor Yellow
    } else {
        Write-Host "`n=== INSTALLATION FAILED ===" -ForegroundColor Red
        Write-Host "Please try manual installation:" -ForegroundColor Yellow
        Write-Host "1. Download Visual Studio Community 2022 from:" -ForegroundColor Cyan
        Write-Host "   https://visualstudio.microsoft.com/downloads/" -ForegroundColor White
        Write-Host "2. Run installer as administrator" -ForegroundColor Cyan
        Write-Host "3. Select 'Desktop development with C++'" -ForegroundColor Cyan
        Write-Host "4. Make sure 'Spectre-mitigated libraries' are selected" -ForegroundColor Cyan
    }
}

Write-Host "`nAfter installation, run:" -ForegroundColor Cyan
Write-Host ".\scripts\check-spectre.ps1" -ForegroundColor White

Write-Host "`nTo build VSCodium, run:" -ForegroundColor Cyan
Write-Host "powershell -ExecutionPolicy ByPass -File .\dev\build.ps1" -ForegroundColor White

Write-Host "`nInstallation script completed!" -ForegroundColor Green 