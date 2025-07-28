# Simple Visual Studio Community installer
# Run as administrator

Write-Host "=== Visual Studio Community Installer ===" -ForegroundColor Green

# Check if Visual Studio Community is already installed
$vsCommunityPath = "C:\Program Files\Microsoft Visual Studio\2022\Community"

if (Test-Path "$vsCommunityPath\VC\Auxiliary\Build\vcvars64.bat") {
    Write-Host "Visual Studio Community found: $vsCommunityPath" -ForegroundColor Green
    
    # Check for Spectre libraries
    $spectrePaths = @(
        "$vsCommunityPath\VC\Tools\MSVC\*\lib\x64\spectre",
        "$vsCommunityPath\VC\Tools\MSVC\*\lib\x86\spectre"
    )
    
    $spectreFound = $false
    foreach ($path in $spectrePaths) {
        if (Test-Path $path) {
            Write-Host "Spectre libraries found: $path" -ForegroundColor Green
            $spectreFound = $true
        }
    }
    
    if ($spectreFound) {
        Write-Host "Visual Studio Community with Spectre libraries is ready!" -ForegroundColor Green
    } else {
        Write-Host "Visual Studio Community found but Spectre libraries are missing." -ForegroundColor Yellow
        Write-Host "Please modify installation to add Spectre-mitigated libraries." -ForegroundColor Yellow
    }
} else {
    Write-Host "Visual Studio Community not found. Installing..." -ForegroundColor Yellow
    
    # Download Visual Studio Community
    $vsUrl = "https://aka.ms/vs/17/release/vs_community.exe"
    $vsFile = "vs_community.exe"
    
    try {
        Write-Host "Downloading Visual Studio Community..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $vsUrl -OutFile $vsFile -UseBasicParsing
        
        Write-Host "Installing Visual Studio Community..." -ForegroundColor Cyan
        
        # Basic installation parameters
        $arguments = @(
            "--quiet",
            "--wait",
            "--norestart",
            "--installPath", "C:\Program Files\Microsoft Visual Studio\2022\Community",
            "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64.Spectre"
        )
        
        Start-Process $vsFile -Wait -ArgumentList $arguments
        Remove-Item $vsFile -Force
        
        Write-Host "Visual Studio Community installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error installing Visual Studio Community: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Please install manually from: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Yellow
    }
}

Write-Host "Run check-spectre.ps1 to verify installation." -ForegroundColor Cyan 