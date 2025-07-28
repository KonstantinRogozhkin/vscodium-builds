# Compile native modules using Visual Studio Community
Write-Host "=== Compiling with Visual Studio Community ===" -ForegroundColor Green

# Set environment to use Visual Studio Community
$env:GYP_MSVS_VERSION = "2022"
$env:npm_config_msvs_version = "2022"
$env:npm_config_target_arch = "x64"
$env:npm_config_target_platform = "win32"

# Try to use Visual Studio Community instead of Build Tools
$vsCommunityPath = "C:\Program Files\Microsoft Visual Studio\2022\Community"
if (Test-Path $vsCommunityPath) {
    $env:VS2022INSTALLDIR = $vsCommunityPath
    Write-Host "Using Visual Studio Community: $vsCommunityPath" -ForegroundColor Green
} else {
    Write-Host "Visual Studio Community not found!" -ForegroundColor Red
    exit 1
}

# Set Spectre mitigation to false
$env:CFLAGS = "/Qspectre-"
$env:CXXFLAGS = "/Qspectre-"
$env:MSVC_SPECTRE_LIBS = "0"
$env:SPECTRE_MITIGATION = "0"

Write-Host "Environment configured" -ForegroundColor Cyan

# Try to compile one module manually
$modulePath = "vscode\node_modules\native-is-elevated"
if (Test-Path $modulePath) {
    Write-Host "Compiling native-is-elevated..." -ForegroundColor Yellow
    
    try {
        Push-Location $modulePath
        
        # Clean previous build
        if (Test-Path "build") {
            Remove-Item "build" -Recurse -Force
        }
        
        # Run node-gyp rebuild
        $result = & "node-gyp" "rebuild" 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SUCCESS: native-is-elevated compiled!" -ForegroundColor Green
        } else {
            Write-Host "FAILED: $result" -ForegroundColor Red
        }
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        Pop-Location
    }
} else {
    Write-Host "Module not found!" -ForegroundColor Red
}

Write-Host "Compilation attempt completed!" -ForegroundColor Green 