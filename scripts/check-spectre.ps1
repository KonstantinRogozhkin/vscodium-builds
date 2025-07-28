# Check for Spectre-mitigated libraries
# Run as administrator

Write-Host "=== Checking Spectre-mitigated libraries ===" -ForegroundColor Green

# Check for Visual Studio Community and Build Tools
$vsPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise",
    "C:\BuildTools",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools",
    "C:\Program Files\Microsoft Visual Studio\2022\BuildTools"
)

$vsFound = $false
$vsPath = ""

foreach ($path in $vsPaths) {
    if (Test-Path "$path\VC\Auxiliary\Build\vcvars64.bat") {
        $vsFound = $true
        $vsPath = $path
        if ($path -like "*Community*") {
            Write-Host "Visual Studio Community found: $path" -ForegroundColor Green
        } elseif ($path -like "*BuildTools*") {
            Write-Host "Visual Studio Build Tools found: $path" -ForegroundColor Green
        } else {
            Write-Host "Visual Studio found: $path" -ForegroundColor Green
        }
        break
    }
}

if (-not $vsFound) {
    Write-Host "Visual Studio Build Tools not found" -ForegroundColor Red
    Write-Host "Please install Visual Studio Build Tools 2022" -ForegroundColor Yellow
    exit 1
}

# Check for Spectre-mitigated libraries
Write-Host "Checking Spectre-mitigated libraries..." -ForegroundColor Green

$spectrePaths = @(
    "$vsPath\VC\Tools\MSVC\*\lib\x64\spectre",
    "$vsPath\VC\Tools\MSVC\*\lib\x86\spectre",
    "$vsPath\VC\Tools\MSVC\*\lib\arm64\spectre"
)

$spectreFound = $false

foreach ($path in $spectrePaths) {
    if (Test-Path $path) {
        Write-Host "Found: $path" -ForegroundColor Green
        $spectreFound = $true
    } else {
        Write-Host "Not found: $path" -ForegroundColor Red
    }
}

if ($spectreFound) {
    Write-Host "Spectre-mitigated libraries are installed!" -ForegroundColor Green
} else {
    Write-Host "Spectre-mitigated libraries are missing!" -ForegroundColor Red
    Write-Host "Please install them via Visual Studio Installer" -ForegroundColor Yellow
}

Write-Host "Check completed!" -ForegroundColor Green 