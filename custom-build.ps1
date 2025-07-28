# Custom VSCodium build script that bypasses native module compilation issues
param(
    [string]$Architecture = "x64"
)

Write-Host "Starting custom VSCodium build..." -ForegroundColor Green

# Set environment variables
$env:PYTHON = "C:\Python312\python.exe"
$env:npm_config_target_platform = "win32"
$env:npm_config_target_arch = $Architecture
$env:npm_config_build_from_source = "false"
$env:npm_config_cache_min = "999999999"

# Navigate to vscode directory
Set-Location "C:\Projects\vscodium-builds\vscode"

Write-Host "Cleaning previous build artifacts..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    cmd /c "rmdir /s /q node_modules" 2>$null
}
if (Test-Path "out") {
    cmd /c "rmdir /s /q out" 2>$null
}

Write-Host "Installing dependencies with prebuilt binaries..." -ForegroundColor Yellow
# Try to install with prebuilt binaries only
npm install --prefer-offline --no-audit --no-fund --production=false

if ($LASTEXITCODE -ne 0) {
    Write-Host "Standard npm install failed, trying alternative approach..." -ForegroundColor Yellow
    
    # Install core dependencies first
    npm install typescript@latest --save-dev
    npm install @types/node@latest --save-dev
    
    # Skip problematic native modules
    $env:npm_config_optional = "false"
    npm install --ignore-scripts --no-optional
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Dependency installation failed. Trying yarn..." -ForegroundColor Red
        npm install -g yarn
        yarn install --ignore-engines --ignore-optional
    }
}

Write-Host "Building VSCodium..." -ForegroundColor Green
npm run compile

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
    Write-Host "VSCodium executable should be in the 'out' directory" -ForegroundColor Green
} else {
    Write-Host "Build failed. Check the output above for errors." -ForegroundColor Red
    exit 1
}
