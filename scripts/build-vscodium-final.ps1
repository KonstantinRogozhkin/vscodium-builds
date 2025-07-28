# Final VSCodium build with native modules
Write-Host "=== Final VSCodium Build ===" -ForegroundColor Green

# Set environment variables
$env:CFLAGS = "/Qspectre-"
$env:CXXFLAGS = "/Qspectre-"
$env:MSVC_SPECTRE_LIBS = "0"
$env:SPECTRE_MITIGATION = "0"
$env:npm_config_target_arch = "x64"
$env:npm_config_target_platform = "win32"
$env:npm_config_msvs_version = "2022"

Write-Host "Environment variables set" -ForegroundColor Cyan

# Clean previous build
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
if (Test-Path "vscode\node_modules") {
    Remove-Item "vscode\node_modules" -Recurse -Force
}

# Run the build script
Write-Host "Starting VSCodium build..." -ForegroundColor Cyan
Write-Host "This will take a long time..." -ForegroundColor Yellow

try {
    & "powershell" "-ExecutionPolicy" "ByPass" "-File" ".\dev\build.ps1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=== BUILD SUCCESSFUL ===" -ForegroundColor Green
        
        # Check if executable was created
        if (Test-Path "Code - OSS.exe") {
            Write-Host "VSCodium executable found: Code - OSS.exe" -ForegroundColor Green
            
            # Test if it runs
            Write-Host "Testing VSCodium..." -ForegroundColor Cyan
            try {
                $process = Start-Process ".\Code - OSS.exe" -ArgumentList "--version" -PassThru -WindowStyle Hidden
                Start-Sleep -Seconds 5
                if (-not $process.HasExited) {
                    $process.Kill()
                    Write-Host "VSCodium started successfully!" -ForegroundColor Green
                } else {
                    Write-Host "VSCodium may have issues with native modules" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "VSCodium has issues: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "VSCodium executable not found!" -ForegroundColor Red
        }
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
Remove-Item Env:npm_config_target_arch -ErrorAction SilentlyContinue
Remove-Item Env:npm_config_target_platform -ErrorAction SilentlyContinue
Remove-Item Env:npm_config_msvs_version -ErrorAction SilentlyContinue

Write-Host "`nBuild completed!" -ForegroundColor Green 