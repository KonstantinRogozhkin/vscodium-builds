# Скрипт установки зависимостей для сборки VSCodium на Windows
# Дата создания: 26 июля 2025 года

Write-Host "=== Установка зависимостей для сборки VSCodium ===" -ForegroundColor Green
Write-Host "Дата: $(Get-Date)" -ForegroundColor Yellow

# Функция для проверки установки программы
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Функция для установки через winget
function Install-WingetPackage($packageId, $packageName) {
    if (Test-Command "winget") {
        Write-Host "Устанавливаю $packageName через winget..." -ForegroundColor Cyan
        try {
            & winget install -e --id $packageId --accept-source-agreements --accept-package-agreements
            return $true
        }
        catch {
            Write-Host "Ошибка установки $packageName через winget: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "winget не найден. Пропускаю установку $packageName" -ForegroundColor Yellow
        return $false
    }
}

# Функция для скачивания и установки MSI
function Install-MSIFromUrl($url, $fileName, $packageName) {
    Write-Host "Скачиваю $packageName..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $url -OutFile $fileName
        Write-Host "Устанавливаю $packageName..." -ForegroundColor Cyan
        Start-Process msiexec.exe -Wait -ArgumentList "/i $fileName /quiet /norestart"
        Remove-Item $fileName -Force
        return $true
    }
    catch {
        Write-Host "Ошибка установки $packageName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Проверяем и устанавливаем winget
Write-Host "`n1. Проверка winget..." -ForegroundColor Green
if (-not (Test-Command "winget")) {
    Write-Host "winget не найден. Попробуйте установить его из Microsoft Store:" -ForegroundColor Yellow
    Write-Host "https://www.microsoft.com/p/app-installer/9nblggh4nns1" -ForegroundColor Cyan
    Write-Host "Или обновите Windows до версии 10.0.17063 или новее" -ForegroundColor Yellow
}

# Проверяем и устанавливаем Node.js
Write-Host "`n2. Проверка Node.js..." -ForegroundColor Green
if (-not (Test-Command "node")) {
    Write-Host "Node.js не найден. Устанавливаю..." -ForegroundColor Yellow
    $nodeUrl = "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi"
    $nodeFile = "nodejs-installer.msi"
    Install-MSIFromUrl $nodeUrl $nodeFile "Node.js"
}
else {
    $nodeVersion = node --version
    Write-Host "Node.js уже установлен: $nodeVersion" -ForegroundColor Green
}

# Проверяем и устанавливаем Python
Write-Host "`n3. Проверка Python..." -ForegroundColor Green
if (-not (Test-Command "python")) {
    Write-Host "Python не найден. Устанавливаю..." -ForegroundColor Yellow
    $pythonUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
    $pythonFile = "python-installer.exe"
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonFile
        Write-Host "Устанавливаю Python..." -ForegroundColor Cyan
        Start-Process $pythonFile -Wait -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1"
        Remove-Item $pythonFile -Force
    }
    catch {
        Write-Host "Ошибка установки Python: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    $pythonVersion = python --version
    Write-Host "Python уже установлен: $pythonVersion" -ForegroundColor Green
}

# Проверяем и устанавливаем Rust
Write-Host "`n4. Проверка Rust..." -ForegroundColor Green
if (-not (Test-Command "rustc")) {
    Write-Host "Rust не найден. Устанавливаю..." -ForegroundColor Yellow
    Install-WingetPackage "Rustlang.Rustup" "Rust"
    if (Test-Command "rustup") {
        Write-Host "Инициализирую Rust..." -ForegroundColor Cyan
        rustup default stable
    }
}
else {
    $rustVersion = rustc --version
    Write-Host "Rust уже установлен: $rustVersion" -ForegroundColor Green
}

# Проверяем и устанавливаем jq
Write-Host "`n5. Проверка jq..." -ForegroundColor Green
if (-not (Test-Command "jq")) {
    Write-Host "jq не найден. Устанавливаю..." -ForegroundColor Yellow
    Install-WingetPackage "jqlang.jq" "jq"
}
else {
    $jqVersion = jq --version
    Write-Host "jq уже установлен: $jqVersion" -ForegroundColor Green
}

# Проверяем и устанавливаем 7-Zip
Write-Host "`n6. Проверка 7-Zip..." -ForegroundColor Green
if (-not (Test-Command "7z")) {
    Write-Host "7-Zip не найден. Устанавливаю..." -ForegroundColor Yellow
    Install-WingetPackage "7zip.7zip" "7-Zip"
}
else {
    Write-Host "7-Zip уже установлен" -ForegroundColor Green
}

# Проверяем и устанавливаем WiX Toolset
Write-Host "`n7. Проверка WiX Toolset..." -ForegroundColor Green
if (-not (Test-Command "candle")) {
    Write-Host "WiX Toolset не найден. Устанавливаю..." -ForegroundColor Yellow
    Install-WingetPackage "WiXToolset.WiXToolset" "WiX Toolset"
}
else {
    Write-Host "WiX Toolset уже установлен" -ForegroundColor Green
}

# Проверяем Git
Write-Host "`n8. Проверка Git..." -ForegroundColor Green
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host "Git уже установлен: $gitVersion" -ForegroundColor Green
}
else {
    Write-Host "Git не найден. Установите Git for Windows:" -ForegroundColor Yellow
    Write-Host "https://git-scm.com/download/win" -ForegroundColor Cyan
}

# Проверяем PowerShell
Write-Host "`n9. Проверка PowerShell..." -ForegroundColor Green
$psVersion = $PSVersionTable.PSVersion
Write-Host "PowerShell версия: $psVersion" -ForegroundColor Green

# Проверяем sed (через Git Bash)
Write-Host "`n10. Проверка sed..." -ForegroundColor Green
if (Test-Path "C:\Program Files\Git\bin\sed.exe") {
    Write-Host "sed найден в Git Bash" -ForegroundColor Green
}
else {
    Write-Host "sed не найден. Убедитесь, что Git for Windows установлен с Git Bash" -ForegroundColor Yellow
}

# Проверяем Visual Studio Build Tools
Write-Host "`n11. Проверка Visual Studio Build Tools..." -ForegroundColor Green
$vsInstallPath = "C:\BuildTools"
$vcvarsPath = "$vsInstallPath\VC\Auxiliary\Build\vcvars64.bat"

if (Test-Path $vcvarsPath) {
    Write-Host "Visual Studio Build Tools найден" -ForegroundColor Green
    
    # Проверяем Spectre-mitigated libraries
    $spectrePaths = @(
        "$vsInstallPath\VC\Tools\MSVC\*\lib\x64\spectre",
        "$vsInstallPath\VC\Tools\MSVC\*\lib\x86\spectre"
    )
    
    $spectreFound = $false
    foreach ($path in $spectrePaths) {
        if (Test-Path $path) {
            Write-Host "✓ Spectre-mitigated libraries найдены: $path" -ForegroundColor Green
            $spectreFound = $true
        }
    }
    
    if (-not $spectreFound) {
        Write-Host "⚠ Spectre-mitigated libraries не найдены" -ForegroundColor Yellow
        Write-Host "Запустите: powershell -ExecutionPolicy ByPass -File .\scripts\install-vs-buildtools.ps1" -ForegroundColor Cyan
    }
} else {
    Write-Host "Visual Studio Build Tools не найден" -ForegroundColor Yellow
    Write-Host "Запустите: powershell -ExecutionPolicy ByPass -File .\scripts\install-vs-buildtools.ps1" -ForegroundColor Cyan
}

# Финальная проверка всех зависимостей
Write-Host "`n=== Финальная проверка зависимостей ===" -ForegroundColor Green

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
        Write-Host "✓ $($dep.Name) - УСТАНОВЛЕН" -ForegroundColor Green
    }
    else {
        if ($dep.Required) {
            Write-Host "✗ $($dep.Name) - НЕ УСТАНОВЛЕН (ОБЯЗАТЕЛЬНО)" -ForegroundColor Red
            $allInstalled = $false
        }
        else {
            Write-Host "⚠ $($dep.Name) - НЕ УСТАНОВЛЕН (ОПЦИОНАЛЬНО)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== Результат проверки ===" -ForegroundColor Green
if ($allInstalled) {
    Write-Host "Все обязательные зависимости установлены! Можно приступать к сборке VSCodium." -ForegroundColor Green
}
else {
    Write-Host "Не все обязательные зависимости установлены. Установите недостающие компоненты." -ForegroundColor Red
}

Write-Host "`nДля сборки VSCodium выполните:" -ForegroundColor Cyan
Write-Host "powershell -ExecutionPolicy ByPass -File .\dev\build.ps1" -ForegroundColor White

Write-Host "`nУстановка завершена!" -ForegroundColor Green 