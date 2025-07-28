# Fix Spectre mitigation in native modules
Write-Host "=== Fixing Spectre Mitigation in Native Modules ===" -ForegroundColor Green

# List of modules to fix
$modules = @(
    "native-is-elevated",
    "native-keymap", 
    "node-pty",
    "@vscode\spdlog",
    "@vscode\windows-process-tree",
    "@vscode\windows-mutex",
    "@vscode\windows-registry",
    "@vscode\sqlite3",
    "@vscode\deviceid"
)

Write-Host "Fixing modules..." -ForegroundColor Cyan

foreach ($module in $modules) {
    $modulePath = "vscode\node_modules\$module"
    
    if (Test-Path $modulePath) {
        Write-Host "Fixing $module..." -ForegroundColor Yellow
        
        # Look for .vcxproj files
        $vcxprojFiles = Get-ChildItem -Path $modulePath -Recurse -Filter "*.vcxproj"
        
        foreach ($file in $vcxprojFiles) {
            Write-Host "  Modifying $($file.Name)" -ForegroundColor White
            
            # Read file content
            $content = Get-Content $file.FullName -Raw
            
            # Replace Spectre mitigation settings
            $content = $content -replace '<SpectreMitigation>true</SpectreMitigation>', '<SpectreMitigation>false</SpectreMitigation>'
            $content = $content -replace '<SpectreMitigation>Enabled</SpectreMitigation>', '<SpectreMitigation>Disabled</SpectreMitigation>'
            $content = $content -replace '<SpectreMitigation>1</SpectreMitigation>', '<SpectreMitigation>0</SpectreMitigation>'
            
            # Add SpectreMitigation if not present
            if ($content -notmatch 'SpectreMitigation') {
                $content = $content -replace '(<PropertyGroup[^>]*>)', '$1<SpectreMitigation>false</SpectreMitigation>'
            }
            
            # Write back
            Set-Content $file.FullName $content -NoNewline
        }
        
        Write-Host "  ✓ $module fixed" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ $module not found" -ForegroundColor Yellow
    }
}

Write-Host "`nAll modules processed!" -ForegroundColor Green
Write-Host "Now try compiling native modules again." -ForegroundColor Cyan 