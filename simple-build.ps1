# Упрощенный скрипт сборки VSCodium для Windows
# Требует предустановленных: Node.js, Git, Python, Visual Studio Build Tools

param(
    [string]$Architecture = "x64",  # x64 или arm64
    [string]$Quality = "stable"     # stable или insider
)

Write-Host "🚀 Упрощенная сборка VSCodium для Windows" -ForegroundColor Green
Write-Host "Архитектура: $Architecture" -ForegroundColor Yellow
Write-Host "Качество: $Quality" -ForegroundColor Yellow

# Функция для проверки команды
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Проверяем зависимости
Write-Host "🔍 Проверяем зависимости..." -ForegroundColor Blue

# Добавляем пути к установленным программам
$env:PATH += ";C:\Program Files\nodejs"
$env:PATH += ";C:\Program Files\Git\bin"
$env:PATH += ";C:\Python311"
$env:PATH += ";C:\Python311\Scripts"

$dependencies = @("git")
$missing = @()

foreach ($dep in $dependencies) {
    if (Test-Command $dep) {
        try {
            $version = & $dep --version 2>$null
            Write-Host "✅ $dep`: $version" -ForegroundColor Green
        } catch {
            Write-Host "✅ $dep`: установлен" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ $dep`: не найден" -ForegroundColor Red
        $missing += $dep
    }
}

if ($missing.Count -gt 0) {
    Write-Host "❌ Отсутствуют зависимости: $($missing -join ', ')" -ForegroundColor Red
    Write-Host "Установите их и повторите попытку." -ForegroundColor Yellow
    return
}

# Устанавливаем переменные окружения
Write-Host "🔧 Настраиваем переменные окружения..." -ForegroundColor Blue

$env:APP_NAME = "VSCodium"
$env:BINARY_NAME = "codium"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = $Architecture
$env:VSCODE_QUALITY = $Quality
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Write-Host "✅ Переменные окружения установлены" -ForegroundColor Green

# Проверяем наличие исходного кода
if (-not (Test-Path "vscode")) {
    Write-Host "📥 Исходный код VSCode не найден. Получаем..." -ForegroundColor Blue
    
    # Получаем репозиторий
    if (Test-Path "get_repo.sh") {
        Write-Host "📦 Запускаем get_repo.sh..." -ForegroundColor Blue
        & bash -c "./get_repo.sh"
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Ошибка при получении репозитория" -ForegroundColor Red
            return
        }
    } else {
        Write-Host "❌ get_repo.sh не найден" -ForegroundColor Red
        return
    }
}

# Подготавливаем VSCode
if (Test-Path "prepare_vscode.sh") {
    Write-Host "🔧 Подготавливаем VSCode..." -ForegroundColor Blue
    & bash -c "./prepare_vscode.sh"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Ошибка при подготовке VSCode" -ForegroundColor Red
        return
    }
} else {
    Write-Host "❌ prepare_vscode.sh не найден" -ForegroundColor Red
    return
}

# Запускаем сборку
if (Test-Path "build.sh") {
    Write-Host "🔨 Запускаем сборку..." -ForegroundColor Blue
    & bash -c "./build.sh"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 Сборка VSCodium завершена успешно!" -ForegroundColor Green
        Write-Host "Результаты сборки находятся в соответствующих папках." -ForegroundColor Yellow
    } else {
        Write-Host "❌ Ошибка при сборке VSCodium" -ForegroundColor Red
        Write-Host "Код ошибки: $LASTEXITCODE" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ build.sh не найден" -ForegroundColor Red
    return
}
