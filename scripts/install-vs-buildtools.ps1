# Скрипт установки Visual Studio Build Tools с Spectre-mitigated libraries
# Дата создания: 26 июля 2025 года

Write-Host "=== Установка Visual Studio Build Tools с Spectre-mitigated libraries ===" -ForegroundColor Green
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

# Функция для скачивания и установки Visual Studio Build Tools
function Install-VSBuildTools {
    Write-Host "Скачиваю Visual Studio Build Tools..." -ForegroundColor Cyan
    
    # URL для Visual Studio Build Tools 2022
    $vsUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
    $vsFile = "vs_buildtools.exe"
    
    try {
        # Скачиваем установщик
        Invoke-WebRequest -Uri $vsUrl -OutFile $vsFile
        
        Write-Host "Устанавливаю Visual Studio Build Tools с необходимыми компонентами..." -ForegroundColor Cyan
        
        # Параметры установки включают все необходимые компоненты
        $arguments = @(
            "--quiet",
            "--wait",
            "--norestart",
            "--nocache",
            "--installPath", "C:\BuildTools",
            "--add", "Microsoft.VisualStudio.Workload.VCTools",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
            "--add", "Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre",
            "--add", "Microsoft.VisualStudio.Component.Windows10SDK.19041",
            "--add", "Microsoft.VisualStudio.Component.Windows10SDK.20348",
            "--add", "Microsoft.VisualStudio.Component.Windows11SDK.22621",
            "--add", "Microsoft.VisualStudio.Component.VC.ATL",
            "--add", "Microsoft.VisualStudio.Component.VC.ATLMFC",
            "--add", "Microsoft.VisualStudio.Component.VC.CLI.Support",
            "--add", "Microsoft.VisualStudio.Component.VC.Modules.x86.x64",
            "--add", "Microsoft.VisualStudio.Component.VC.Redist.14.Latest",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64EC",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64.Spectre",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64.Spectre",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.ARM64EC.Spectre"
        )
        
        # Запускаем установку
        Start-Process $vsFile -Wait -ArgumentList $arguments
        
        # Удаляем установщик
        Remove-Item $vsFile -Force
        
        Write-Host "Visual Studio Build Tools установлен успешно!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Ошибка установки Visual Studio Build Tools: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Функция для проверки установленных компонентов Visual Studio
function Test-VSComponents {
    Write-Host "`nПроверка установленных компонентов Visual Studio..." -ForegroundColor Green
    
    $vsInstallPath = "C:\BuildTools"
    $vcvarsPath = "$vsInstallPath\VC\Auxiliary\Build\vcvars64.bat"
    
    if (Test-Path $vcvarsPath) {
        Write-Host "✓ Visual Studio Build Tools найден в $vsInstallPath" -ForegroundColor Green
        
        # Проверяем наличие Spectre-mitigated libraries
        $spectrePaths = @(
            "$vsInstallPath\VC\Tools\MSVC\*\lib\x64\spectre",
            "$vsInstallPath\VC\Tools\MSVC\*\lib\x86\spectre",
            "$vsInstallPath\VC\Tools\MSVC\*\lib\arm64\spectre"
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
            return $false
        }
        
        return $true
    }
    else {
        Write-Host "✗ Visual Studio Build Tools не найден" -ForegroundColor Red
        return $false
    }
}

# Функция для настройки переменных окружения
function Set-VSEnvironment {
    Write-Host "`nНастройка переменных окружения..." -ForegroundColor Green
    
    $vsInstallPath = "C:\BuildTools"
    $vcvarsPath = "$vsInstallPath\VC\Auxiliary\Build\vcvars64.bat"
    
    if (Test-Path $vcvarsPath) {
        # Добавляем пути в PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        $vsPaths = @(
            "$vsInstallPath\VC\Tools\MSVC\*\bin\Hostx64\x64",
            "$vsInstallPath\VC\Tools\MSVC\*\bin\Hostx64\x86",
            "$vsInstallPath\VC\Tools\MSVC\*\bin\Hostx64\arm64",
            "$vsInstallPath\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin",
            "$vsInstallPath\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"
        )
        
        foreach ($path in $vsPaths) {
            $expandedPath = (Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
            if ($expandedPath -and $currentPath -notlike "*$expandedPath*") {
                [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$expandedPath", "Machine")
                Write-Host "Добавлен путь: $expandedPath" -ForegroundColor Cyan
            }
        }
        
        Write-Host "Переменные окружения настроены" -ForegroundColor Green
    }
}

# Основная логика установки
Write-Host "`n1. Проверка текущей установки Visual Studio Build Tools..." -ForegroundColor Green

if (Test-VSComponents) {
    Write-Host "Visual Studio Build Tools уже установлен с необходимыми компонентами" -ForegroundColor Green
}
else {
    Write-Host "Visual Studio Build Tools не установлен или отсутствуют необходимые компоненты" -ForegroundColor Yellow
    
    # Пробуем установить через winget
    Write-Host "`n2. Попытка установки через winget..." -ForegroundColor Green
    $wingetSuccess = Install-WingetPackage "Microsoft.VisualStudio.2022.BuildTools" "Visual Studio Build Tools 2022"
    
    if (-not $wingetSuccess) {
        Write-Host "`n3. Установка через официальный установщик..." -ForegroundColor Green
        Install-VSBuildTools
    }
    
    # Проверяем результат установки
    Write-Host "`n4. Проверка результата установки..." -ForegroundColor Green
    if (Test-VSComponents) {
        Write-Host "Установка завершена успешно!" -ForegroundColor Green
        Set-VSEnvironment
    }
    else {
        Write-Host "`n=== РУЧНАЯ УСТАНОВКА ===" -ForegroundColor Red
        Write-Host "Автоматическая установка не удалась. Выполните следующие шаги:" -ForegroundColor Yellow
        Write-Host "1. Скачайте Visual Studio Build Tools 2022:" -ForegroundColor Cyan
        Write-Host "   https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022" -ForegroundColor White
        Write-Host "2. Запустите установщик и выберите:" -ForegroundColor Cyan
        Write-Host "   - C++ build tools" -ForegroundColor White
        Write-Host "   - Windows 10/11 SDK" -ForegroundColor White
        Write-Host "   - Spectre-mitigated libraries (x86/x64/ARM64)" -ForegroundColor White
        Write-Host "3. Перезапустите PowerShell после установки" -ForegroundColor Cyan
    }
}

# Финальная проверка
Write-Host "`n=== ФИНАЛЬНАЯ ПРОВЕРКА ===" -ForegroundColor Green

$vsComponents = @(
    @{Name="Visual Studio Build Tools"; Path="C:\BuildTools\VC\Auxiliary\Build\vcvars64.bat"; Required=$true},
    @{Name="Spectre-mitigated libraries (x64)"; Path="C:\BuildTools\VC\Tools\MSVC\*\lib\x64\spectre"; Required=$true},
    @{Name="Spectre-mitigated libraries (x86)"; Path="C:\BuildTools\VC\Tools\MSVC\*\lib\x86\spectre"; Required=$true},
    @{Name="Windows SDK"; Path="C:\BuildTools\Windows Kits\10\Include"; Required=$true}
)

$allComponentsFound = $true

foreach ($component in $vsComponents) {
    if (Test-Path $component.Path) {
        Write-Host "✓ $($component.Name) - НАЙДЕН" -ForegroundColor Green
    }
    else {
        if ($component.Required) {
            Write-Host "✗ $($component.Name) - НЕ НАЙДЕН (ОБЯЗАТЕЛЬНО)" -ForegroundColor Red
            $allComponentsFound = $false
        }
        else {
            Write-Host "⚠ $($component.Name) - НЕ НАЙДЕН (ОПЦИОНАЛЬНО)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n=== РЕЗУЛЬТАТ ===" -ForegroundColor Green
if ($allComponentsFound) {
    Write-Host "Все необходимые компоненты Visual Studio Build Tools установлены!" -ForegroundColor Green
    Write-Host "Можно приступать к сборке VSCodium." -ForegroundColor Green
}
else {
    Write-Host "Не все компоненты установлены. Выполните ручную установку." -ForegroundColor Red
}

Write-Host "`nДля сборки VSCodium выполните:" -ForegroundColor Cyan
Write-Host "powershell -ExecutionPolicy ByPass -File .\dev\build.ps1" -ForegroundColor White

Write-Host "`nУстановка Visual Studio Build Tools завершена!" -ForegroundColor Green 