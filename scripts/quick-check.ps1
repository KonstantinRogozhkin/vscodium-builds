# Quick VSCodium build check
Write-Host "=== VSCodium Build Check ===" -ForegroundColor Green

# Check Visual Studio
$vsFound = $false
$vsPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise",
    "C:\BuildTools",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools",
    "C:\Program Files\Microsoft Visual Studio\2022\BuildTools"
)

foreach ($path in $vsPaths) {
    if (Test-Path "$path\VC\Auxiliary\Build\vcvars64.bat") {
        Write-Host "Visual Studio found: $path" -ForegroundColor Green
        $vsFound = $true
        break
    }
}

if (-not $vsFound) {
    Write-Host "Visual Studio not found!" -ForegroundColor Red
    exit 1
}

# Check tools
Write-Host "Checking tools..." -ForegroundColor Green

$tools = @("node", "python", "git", "rustc", "jq", "7z", "candle")
$allToolsFound = $true

foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Host "OK: $tool" -ForegroundColor Green
    } else {
        Write-Host "MISSING: $tool" -ForegroundColor Red
        $allToolsFound = $false
    }
}

Write-Host "=== RESULT ===" -ForegroundColor Green

if ($allToolsFound) {
    Write-Host "All tools available" -ForegroundColor Green
    Write-Host "Try: .\scripts\build-vscodium-no-spectre.ps1" -ForegroundColor White
} else {
    Write-Host "Some tools missing" -ForegroundColor Red
    Write-Host "Run: .\scripts\install-dependencies-fixed.ps1" -ForegroundColor Yellow
}

Write-Host "Check completed!" -ForegroundColor Green 