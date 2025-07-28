# Script for installing VSCodium build dependencies
# Run as administrator

Write-Host "=== VSCodium Build Dependencies Installer ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please restart PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Function to test if a command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install package via winget
function Install-WingetPackage {
    param($PackageId, $PackageName)
    
    Write-Host "Installing $PackageName via winget..." -ForegroundColor Cyan
    
    try {
        winget install $PackageId --accept-source-agreements --accept-package-agreements
        return $true
    }
    catch {
        Write-Host "Error installing $PackageName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to install MSI from URL
function Install-MSIFromUrl {
    param($Url, $FileName, $PackageName)
    
    Write-Host "Downloading $PackageName..." -ForegroundColor Cyan
    
    try {
        $tempFile = "$env:TEMP\$FileName"
        Invoke-WebRequest -Uri $Url -OutFile $tempFile -UseBasicParsing
        
        Write-Host "Installing $PackageName..." -ForegroundColor Cyan
        Start-Process msiexec.exe -Wait -ArgumentList "/i `"$tempFile`" /quiet /norestart"
        
        Remove-Item $tempFile -Force
        return $true
    }
    catch {
        Write-Host "Error installing $PackageName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Check and install Node.js
Write-Host "`n1. Checking Node.js..." -ForegroundColor Green
if (Test-Command "node") {
    $nodeVersion = node --version
    Write-Host "Node.js already installed: $nodeVersion" -ForegroundColor Green
}
else {
    Write-Host "Node.js not found. Installing..." -ForegroundColor Yellow
    $nodeUrl = "https://nodejs.org/dist/v18.19.0/node-v18.19.0-x64.msi"
    Install-MSIFromUrl $nodeUrl "node-v18.19.0-x64.msi" "Node.js"
}

# Check and install Python
Write-Host "`n2. Checking Python..." -ForegroundColor Green
if (Test-Command "python") {
    $pythonVersion = python --version
    Write-Host "Python already installed: $pythonVersion" -ForegroundColor Green
}
else {
    Write-Host "Python not found. Installing..." -ForegroundColor Yellow
    $pythonUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    $tempFile = "$env:TEMP\python-3.11.8-amd64.exe"
    
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $tempFile -UseBasicParsing
        Start-Process $tempFile -Wait -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1"
        Remove-Item $tempFile -Force
    }
    catch {
        Write-Host "Error installing Python: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check and install Rust
Write-Host "`n3. Checking Rust..." -ForegroundColor Green
if (Test-Command "rustc") {
    $rustVersion = rustc --version
    Write-Host "Rust already installed: $rustVersion" -ForegroundColor Green
}
else {
    Write-Host "Rust not found. Installing..." -ForegroundColor Yellow
    $rustUrl = "https://win.rustup.rs/x86_64"
    $tempFile = "$env:TEMP\rustup-init.exe"
    
    try {
        Invoke-WebRequest -Uri $rustUrl -OutFile $tempFile -UseBasicParsing
        Start-Process $tempFile -Wait -ArgumentList "-y"
        Remove-Item $tempFile -Force
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
    catch {
        Write-Host "Error installing Rust: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check and install jq
Write-Host "`n4. Checking jq..." -ForegroundColor Green
if (Test-Command "jq") {
    $jqVersion = jq --version
    Write-Host "jq already installed: $jqVersion" -ForegroundColor Green
}
else {
    Write-Host "jq not found. Installing..." -ForegroundColor Yellow
    $jqUrl = "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-windows-amd64.exe"
    $jqDir = "C:\Program Files\jq"
    $jqExe = "$jqDir\jq.exe"
    
    try {
        if (-not (Test-Path $jqDir)) {
            New-Item -ItemType Directory -Path $jqDir -Force
        }
        Invoke-WebRequest -Uri $jqUrl -OutFile $jqExe -UseBasicParsing
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$jqDir*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$jqDir", "Machine")
            $env:Path += ";$jqDir"
        }
    }
    catch {
        Write-Host "Error installing jq: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check and install 7-Zip
Write-Host "`n5. Checking 7-Zip..." -ForegroundColor Green
if (Test-Command "7z") {
    Write-Host "7-Zip already installed" -ForegroundColor Green
}
else {
    Write-Host "7-Zip not found. Installing..." -ForegroundColor Yellow
    $sevenZipUrl = "https://www.7-zip.org/a/7z2301-x64.exe"
    $tempFile = "$env:TEMP\7z2301-x64.exe"
    
    try {
        Invoke-WebRequest -Uri $sevenZipUrl -OutFile $tempFile -UseBasicParsing
        Start-Process $tempFile -Wait -ArgumentList "/S"
        Remove-Item $tempFile -Force
        
        # Add to PATH
        $sevenZipPath = "C:\Program Files\7-Zip"
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$sevenZipPath*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$sevenZipPath", "Machine")
            $env:Path += ";$sevenZipPath"
        }
    }
    catch {
        Write-Host "Error installing 7-Zip: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check and install WiX Toolset
Write-Host "`n6. Checking WiX Toolset..." -ForegroundColor Green
if (Test-Command "candle") {
    Write-Host "WiX Toolset already installed" -ForegroundColor Green
}
else {
    Write-Host "WiX Toolset not found. Installing..." -ForegroundColor Yellow
    $wixUrl = "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311.exe"
    $tempFile = "$env:TEMP\wix311.exe"
    
    try {
        Invoke-WebRequest -Uri $wixUrl -OutFile $tempFile -UseBasicParsing
        Start-Process $tempFile -Wait -ArgumentList "/quiet"
        Remove-Item $tempFile -Force
        
        # Add to PATH
        $wixPath = "C:\Program Files (x86)\WiX Toolset v3.11\bin"
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$wixPath*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$wixPath", "Machine")
            $env:Path += ";$wixPath"
        }
    }
    catch {
        Write-Host "Error installing WiX Toolset: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check Git
Write-Host "`n7. Checking Git..." -ForegroundColor Green
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host "Git already installed: $gitVersion" -ForegroundColor Green
}
else {
    Write-Host "Git not found. Please install Git for Windows:" -ForegroundColor Yellow
    Write-Host "https://git-scm.com/download/win" -ForegroundColor Cyan
}

# Check PowerShell
Write-Host "`n8. Checking PowerShell..." -ForegroundColor Green
$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell version: $psVersion" -ForegroundColor Green

# Check sed (via Git Bash)
Write-Host "`n9. Checking sed..." -ForegroundColor Green
if (Test-Path "C:\Program Files\Git\bin\sed.exe") {
    Write-Host "sed found in Git Bash" -ForegroundColor Green
}
else {
    Write-Host "sed not found. Make sure Git for Windows is installed with Git Bash" -ForegroundColor Yellow
}

# Check Visual Studio Build Tools
Write-Host "`n10. Checking Visual Studio Build Tools..." -ForegroundColor Green
$vsInstallPath = "C:\BuildTools"
$vcvarsPath = "$vsInstallPath\VC\Auxiliary\Build\vcvars64.bat"

if (Test-Path $vcvarsPath) {
    Write-Host "Visual Studio Build Tools found" -ForegroundColor Green
    
    # Check Spectre-mitigated libraries
    $spectrePaths = @(
        "$vsInstallPath\VC\Tools\MSVC\*\lib\x64\spectre",
        "$vsInstallPath\VC\Tools\MSVC\*\lib\x86\spectre"
    )
    
    $spectreFound = $false
    foreach ($path in $spectrePaths) {
        if (Test-Path $path) {
            Write-Host "Spectre-mitigated libraries found: $path" -ForegroundColor Green
            $spectreFound = $true
        }
    }
    
    if (-not $spectreFound) {
        Write-Host "Spectre-mitigated libraries not found" -ForegroundColor Yellow
        Write-Host "Run: powershell -ExecutionPolicy ByPass -File .\scripts\install-vs-buildtools.ps1" -ForegroundColor Cyan
    }
} else {
    Write-Host "Visual Studio Build Tools not found" -ForegroundColor Yellow
    Write-Host "Run: powershell -ExecutionPolicy ByPass -File .\scripts\install-vs-buildtools.ps1" -ForegroundColor Cyan
}

# Final dependency check
Write-Host "`n=== Final Dependency Check ===" -ForegroundColor Green

$dependencies = @(
    @{Name="Node.js"; Command="node"; Required=$true},
    @{Name="Python"; Command="python"; Required=$true},
    @{Name="Git"; Command="git"; Required=$true},
    @{Name="Rust"; Command="rustc"; Required=$true},
    @{Name="jq"; Command="jq"; Required=$true},
    @{Name="7-Zip"; Command="7z"; Required=$true},
    @{Name="WiX Toolset"; Command="candle"; Required=$true},
    @{Name="PowerShell"; Command="powershell"; Required=$true},
    @{Name="winget"; Command="winget"; Required=$false}
)

$allInstalled = $true

foreach ($dep in $dependencies) {
    if (Test-Command $dep.Command) {
        Write-Host "$($dep.Name) - INSTALLED" -ForegroundColor Green
    }
    else {
        if ($dep.Required) {
            Write-Host "$($dep.Name) - NOT INSTALLED (REQUIRED)" -ForegroundColor Red
            $allInstalled = $false
        }
        else {
            Write-Host "$($dep.Name) - NOT INSTALLED (OPTIONAL)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Check Result ===" -ForegroundColor Green
if ($allInstalled) {
    Write-Host "All required dependencies are installed! You can proceed with VSCodium build." -ForegroundColor Green
}
else {
    Write-Host "Not all required dependencies are installed. Please install missing components." -ForegroundColor Red
}

Write-Host "`nTo build VSCodium, run:" -ForegroundColor Cyan
Write-Host "powershell -ExecutionPolicy ByPass -File .\dev\build.ps1" -ForegroundColor White

Write-Host "`nInstallation completed!" -ForegroundColor Green 