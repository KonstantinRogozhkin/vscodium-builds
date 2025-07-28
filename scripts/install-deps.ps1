# VSCodium Dependencies Installer for Windows
# Date: 26 July 2025

Write-Host "=== VSCodium Dependencies Installer ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow

# Function to check if command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Function to install via winget
function Install-WingetPackage($packageId, $packageName) {
    if (Test-Command "winget") {
        Write-Host "Installing $packageName via winget..." -ForegroundColor Cyan
        try {
            & winget install -e --id $packageId --accept-source-agreements --accept-package-agreements
            return $true
        }
        catch {
            Write-Host "Error installing $packageName via winget: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "winget not found. Skipping $packageName" -ForegroundColor Yellow
        return $false
    }
}

# Check and install winget
Write-Host "1. Checking winget..." -ForegroundColor Green
if (-not (Test-Command "winget")) {
    Write-Host "winget not found. Try installing from Microsoft Store:" -ForegroundColor Yellow
    Write-Host "https://www.microsoft.com/p/app-installer/9nblggh4nns1" -ForegroundColor Cyan
}

# Check and install Node.js
Write-Host "2. Checking Node.js..." -ForegroundColor Green
if (-not (Test-Command "node")) {
    Write-Host "Node.js not found. Installing..." -ForegroundColor Yellow
    $nodeUrl = "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi"
    $nodeFile = "nodejs-installer.msi"
    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeFile
        Write-Host "Installing Node.js..." -ForegroundColor Cyan
        Start-Process msiexec.exe -Wait -ArgumentList "/i $nodeFile /quiet /norestart"
        Remove-Item $nodeFile -Force
    }
    catch {
        Write-Host "Error installing Node.js: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    $nodeVersion = node --version
    Write-Host "Node.js already installed: $nodeVersion" -ForegroundColor Green
}

# Check and install Python
Write-Host "3. Checking Python..." -ForegroundColor Green
if (-not (Test-Command "python")) {
    Write-Host "Python not found. Installing..." -ForegroundColor Yellow
    $pythonUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    $pythonFile = "python-installer.exe"
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonFile
        Write-Host "Installing Python..." -ForegroundColor Cyan
        Start-Process $pythonFile -Wait -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1"
        Remove-Item $pythonFile -Force
    }
    catch {
        Write-Host "Error installing Python: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    $pythonVersion = python --version
    Write-Host "Python already installed: $pythonVersion" -ForegroundColor Green
}

# Check and install Rust
Write-Host "4. Checking Rust..." -ForegroundColor Green
if (-not (Test-Command "rustc")) {
    Write-Host "Rust not found. Installing..." -ForegroundColor Yellow
    Install-WingetPackage "Rustlang.Rustup" "Rust"
    if (Test-Command "rustup") {
        Write-Host "Initializing Rust..." -ForegroundColor Cyan
        rustup default stable
    }
}
else {
    $rustVersion = rustc --version
    Write-Host "Rust already installed: $rustVersion" -ForegroundColor Green
}

# Check and install jq
Write-Host "5. Checking jq..." -ForegroundColor Green
if (-not (Test-Command "jq")) {
    Write-Host "jq not found. Installing..." -ForegroundColor Yellow
    Install-WingetPackage "jqlang.jq" "jq"
}
else {
    $jqVersion = jq --version
    Write-Host "jq already installed: $jqVersion" -ForegroundColor Green
}

# Check and install 7-Zip
Write-Host "6. Checking 7-Zip..." -ForegroundColor Green
if (-not (Test-Command "7z")) {
    Write-Host "7-Zip not found. Installing..." -ForegroundColor Yellow
    Install-WingetPackage "7zip.7zip" "7-Zip"
}
else {
    Write-Host "7-Zip already installed" -ForegroundColor Green
}

# Check and install WiX Toolset
Write-Host "7. Checking WiX Toolset..." -ForegroundColor Green
if (-not (Test-Command "candle")) {
    Write-Host "WiX Toolset not found. Installing..." -ForegroundColor Yellow
    Install-WingetPackage "WiXToolset.WiXToolset" "WiX Toolset"
}
else {
    Write-Host "WiX Toolset already installed" -ForegroundColor Green
}

# Check Git
Write-Host "8. Checking Git..." -ForegroundColor Green
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host "Git already installed: $gitVersion" -ForegroundColor Green
}
else {
    Write-Host "Git not found. Install Git for Windows:" -ForegroundColor Yellow
    Write-Host "https://git-scm.com/download/win" -ForegroundColor Cyan
}

# Check PowerShell
Write-Host "9. Checking PowerShell..." -ForegroundColor Green
$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell version: $psVersion" -ForegroundColor Green

# Check sed (via Git Bash)
Write-Host "10. Checking sed..." -ForegroundColor Green
if (Test-Path "C:\Program Files\Git\bin\sed.exe") {
    Write-Host "sed found in Git Bash" -ForegroundColor Green
}
else {
    Write-Host "sed not found. Make sure Git for Windows is installed with Git Bash" -ForegroundColor Yellow
}

# Final dependency check
Write-Host "=== Final Dependency Check ===" -ForegroundColor Green

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
        Write-Host "✓ $($dep.Name) - INSTALLED" -ForegroundColor Green
    }
    else {
        if ($dep.Required) {
            Write-Host "✗ $($dep.Name) - NOT INSTALLED (REQUIRED)" -ForegroundColor Red
            $allInstalled = $false
        }
        else {
            Write-Host "⚠ $($dep.Name) - NOT INSTALLED (OPTIONAL)" -ForegroundColor Yellow
        }
    }
}

Write-Host "=== Check Result ===" -ForegroundColor Green
if ($allInstalled) {
    Write-Host "All required dependencies installed! Ready to build VSCodium." -ForegroundColor Green
}
else {
    Write-Host "Not all required dependencies installed. Install missing components." -ForegroundColor Red
}

Write-Host "To build VSCodium run:" -ForegroundColor Cyan
Write-Host "powershell -ExecutionPolicy ByPass -File .\dev\build.ps1" -ForegroundColor White

Write-Host "Installation completed!" -ForegroundColor Green 