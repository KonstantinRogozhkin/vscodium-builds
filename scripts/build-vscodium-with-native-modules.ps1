# Build VSCodium with properly compiled native modules
# Run as administrator

Write-Host "=== Building VSCodium with Native Modules ===" -ForegroundColor Green

# Set environment variables to disable Spectre mitigation
$env:CFLAGS = "/Qspectre-"
$env:CXXFLAGS = "/Qspectre-"
$env:MSVC_SPECTRE_LIBS = "0"
$env:SPECTRE_MITIGATION = "0"

# Additional environment variables for node-gyp
$env:npm_config_target_arch = "x64"
$env:npm_config_target_platform = "win32"
$env:npm_config_msvs_version = "2022"

Write-Host "Environment variables set:" -ForegroundColor Cyan
Write-Host "CFLAGS: $env:CFLAGS" -ForegroundColor White
Write-Host "CXXFLAGS: $env:CXXFLAGS" -ForegroundColor White
Write-Host "MSVC_SPECTRE_LIBS: $env:MSVC_SPECTRE_LIBS" -ForegroundColor White
Write-Host "SPECTRE_MITIGATION: $env:SPECTRE_MITIGATION" -ForegroundColor White
Write-Host "npm_config_target_arch: $env:npm_config_target_arch" -ForegroundColor White
Write-Host "npm_config_target_platform: $env:npm_config_target_platform" -ForegroundColor White
Write-Host "npm_config_msvs_version: $env:npm_config_msvs_version" -ForegroundColor White

# Check if we're in the right directory
if (-not (Test-Path "dev\build.ps1")) {
    Write-Host "Error: dev\build.ps1 not found!" -ForegroundColor Red
    Write-Host "Please run this script from the vscodium-builds directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "`nStarting VSCodium build with native modules..." -ForegroundColor Cyan
Write-Host "This may take a long time..." -ForegroundColor Yellow

try {
    # Run the build script with environment variables
    & "powershell" "-ExecutionPolicy" "ByPass" "-File" ".\dev\build.ps1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n=== BUILD SUCCESSFUL ===" -ForegroundColor Green
        Write-Host "VSCodium has been built successfully with native modules!" -ForegroundColor Green
        
        # Verify native modules
        Write-Host "`nVerifying native modules..." -ForegroundColor Cyan
        $nativeModules = @(
            "node_modules\@vscode\spdlog\build\Release\spdlog.node",
            "node_modules\native-is-elevated\build\Release\iselevated.node",
            "node_modules\native-keymap\build\Release\native-keymap.node",
            "node_modules\node-pty\build\Release\pty.node"
        )
        
        $allModulesFound = $true
        foreach ($module in $nativeModules) {
            if (Test-Path "vscode\$module") {
                Write-Host "✓ $module" -ForegroundColor Green
            } else {
                Write-Host "✗ $module" -ForegroundColor Red
                $allModulesFound = $false
            }
        }
        
        if ($allModulesFound) {
            Write-Host "`nAll native modules compiled successfully!" -ForegroundColor Green
        } else {
            Write-Host "`nSome native modules are missing!" -ForegroundColor Yellow
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

Write-Host "`nBuild script completed!" -ForegroundColor Green 