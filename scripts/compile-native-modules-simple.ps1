# Simple native module compilation for VSCodium
Write-Host "=== Compiling Native Modules ===" -ForegroundColor Green

# Set environment variables
$env:CFLAGS = "/Qspectre-"
$env:CXXFLAGS = "/Qspectre-"
$env:MSVC_SPECTRE_LIBS = "0"
$env:SPECTRE_MITIGATION = "0"

Write-Host "Environment variables set" -ForegroundColor Cyan

# Check directory
if (-not (Test-Path "vscode\node_modules")) {
    Write-Host "Error: vscode\node_modules not found!" -ForegroundColor Red
    exit 1
}

# List of modules to compile
$modules = @(
    "native-is-elevated",
    "native-keymap", 
    "node-pty"
)

Write-Host "Compiling modules..." -ForegroundColor Cyan

$successCount = 0
$totalCount = $modules.Count

foreach ($module in $modules) {
    $modulePath = "vscode\node_modules\$module"
    
    if (Test-Path $modulePath) {
        Write-Host "Compiling $module..." -ForegroundColor Yellow
        
        try {
            Push-Location $modulePath
            $result = & "node-gyp" "rebuild" 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "OK: $module" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "FAILED: $module" -ForegroundColor Red
            }
        } catch {
            Write-Host "ERROR: $module" -ForegroundColor Red
        } finally {
            Pop-Location
        }
    } else {
        Write-Host "NOT FOUND: $module" -ForegroundColor Yellow
    }
}

Write-Host "Summary: $successCount/$totalCount modules compiled" -ForegroundColor Green

# Clear environment variables
Remove-Item Env:CFLAGS -ErrorAction SilentlyContinue
Remove-Item Env:CXXFLAGS -ErrorAction SilentlyContinue
Remove-Item Env:MSVC_SPECTRE_LIBS -ErrorAction SilentlyContinue
Remove-Item Env:SPECTRE_MITIGATION -ErrorAction SilentlyContinue

Write-Host "Compilation completed!" -ForegroundColor Green 