# Manually compile native modules for VSCodium
# Run as administrator

Write-Host "=== Compiling Native Modules for VSCodium ===" -ForegroundColor Green

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

# Check if we're in the right directory
if (-not (Test-Path "vscode\node_modules")) {
    Write-Host "Error: vscode\node_modules not found!" -ForegroundColor Red
    Write-Host "Please run this script from the vscodium-builds directory." -ForegroundColor Yellow
    exit 1
}

# List of native modules to compile
$nativeModules = @(
    "@vscode\spdlog",
    "native-is-elevated", 
    "native-keymap",
    "native-watchdog",
    "node-pty",
    "@vscode\windows-process-tree",
    "@vscode\windows-mutex",
    "@vscode\windows-registry",
    "@vscode\windows-ca-certs",
    "@vscode\sqlite3",
    "@vscode\deviceid",
    "windows-foreground-love",
    "@parcel\watcher",
    "@playwright\browser-chromium",
    "kerberos"
)

Write-Host "`nCompiling native modules..." -ForegroundColor Cyan

$successCount = 0
$totalCount = $nativeModules.Count

foreach ($module in $nativeModules) {
    $modulePath = "vscode\node_modules\$module"
    
    if (Test-Path $modulePath) {
        Write-Host "Compiling $module..." -ForegroundColor Yellow
        
        try {
            # Change to module directory
            Push-Location $modulePath
            
            # Run node-gyp rebuild
            $result = & "node-gyp" "rebuild" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ $module compiled successfully" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "✗ $module failed to compile" -ForegroundColor Red
                Write-Host "Error: $result" -ForegroundColor Red
            }
        } catch {
            Write-Host "✗ $module failed to compile" -ForegroundColor Red
            Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "⚠ $module not found" -ForegroundColor Yellow
    }
}

Write-Host "`n=== COMPILATION SUMMARY ===" -ForegroundColor Green
Write-Host "Successfully compiled: $successCount/$totalCount modules" -ForegroundColor White

if ($successCount -eq $totalCount) {
    Write-Host "All native modules compiled successfully!" -ForegroundColor Green
} else {
    Write-Host "Some modules failed to compile. VSCodium may not work properly." -ForegroundColor Yellow
}

# Clear environment variables
Remove-Item Env:CFLAGS -ErrorAction SilentlyContinue
Remove-Item Env:CXXFLAGS -ErrorAction SilentlyContinue
Remove-Item Env:MSVC_SPECTRE_LIBS -ErrorAction SilentlyContinue
Remove-Item Env:SPECTRE_MITIGATION -ErrorAction SilentlyContinue
Remove-Item Env:npm_config_target_arch -ErrorAction SilentlyContinue
Remove-Item Env:npm_config_target_platform -ErrorAction SilentlyContinue
Remove-Item Env:npm_config_msvs_version -ErrorAction SilentlyContinue

Write-Host "`nNative module compilation completed!" -ForegroundColor Green 