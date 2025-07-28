# VSCodium Build Setup and Build Script for Windows
# Этот скрипт автоматически устанавливает зависимости и запускает сборку VSCodium

param(
    [string]$Architecture = "x64",  # x64 или arm64
    [string]$Quality = "stable"     # stable или insider
)

Write-Host "🚀 VSCodium Build Setup для Windows" -ForegroundColor Green
Write-Host "Архитектура: $Architecture" -ForegroundColor Yellow
Write-Host "Качество: $Quality" -ForegroundColor Yellow

# Проверяем, запущен ли PowerShell от администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠️  Для установки зависимостей требуются права администратора." -ForegroundColor Red
    Write-Host "Перезапустите PowerShell от имени администратора или установите зависимости вручную." -ForegroundColor Yellow
}

# Функция для проверки установки программы
function Test-ProgramInstalled {
    param([string]$ProgramName)
    try {
        & $ProgramName --version 2>$null | Out-Null
        return $true
    } catch {
        return $false
    }
}

# Проверяем и устанавливаем Chocolatey (если нужно)
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    if ($isAdmin) {
        Write-Host "📦 Устанавливаем Chocolatey..." -ForegroundColor Blue
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        refreshenv
    } else {
        Write-Host "⚠️  Chocolatey не установлен. Установите его вручную или запустите скрипт от администратора." -ForegroundColor Yellow
    }
}

# Устанавливаем Node.js 22.15.1
if (-not (Test-ProgramInstalled "node")) {
    if ($isAdmin -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "📦 Устанавливаем Node.js 22.15.1..." -ForegroundColor Blue
        choco install nodejs --version=22.15.1 -y
        refreshenv
    } else {
        Write-Host "⚠️  Node.js не установлен. Скачайте и установите Node.js 22.15.1 с https://nodejs.org/" -ForegroundColor Yellow
        Write-Host "Или запустите этот скрипт от администратора для автоматической установки." -ForegroundColor Yellow
        return
    }
}

# Устанавливаем Python (если не установлен)
if (-not (Test-ProgramInstalled "python")) {
    if ($isAdmin -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "📦 Устанавливаем Python..." -ForegroundColor Blue
        choco install python -y
        refreshenv
    } else {
        Write-Host "⚠️  Python не установлен. Скачайте и установите Python с https://python.org/" -ForegroundColor Yellow
    }
}

# Проверяем Visual Studio Build Tools
$vsBuildTools = Get-ChildItem "C:\Program Files*" -Filter "*Visual Studio*" -Directory -ErrorAction SilentlyContinue
if (-not $vsBuildTools) {
    Write-Host "⚠️  Visual Studio Build Tools не найдены." -ForegroundColor Yellow
    Write-Host "Скачайте и установите Visual Studio Build Tools или Visual Studio Community" -ForegroundColor Yellow
    Write-Host "с поддержкой C++ разработки: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Yellow
}

# Проверяем установку Node.js
Write-Host "🔍 Проверяем установленные зависимости..." -ForegroundColor Blue

try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js не найден" -ForegroundColor Red
    return
}

try {
    $npmVersion = npm --version
    Write-Host "✅ npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm не найден" -ForegroundColor Red
    return
}

try {
    $gitVersion = git --version
    Write-Host "✅ Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git не найден" -ForegroundColor Red
    return
}

# Устанавливаем переменные окружения для сборки
Write-Host "🔧 Настраиваем переменные окружения..." -ForegroundColor Blue

$env:APP_NAME = "VSCodium"
$env:BINARY_NAME = "codium"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = $Architecture
$env:VSCODE_QUALITY = $Quality
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Write-Host "✅ Переменные окружения установлены:" -ForegroundColor Green
Write-Host "   OS_NAME: $env:OS_NAME" -ForegroundColor Gray
Write-Host "   VSCODE_ARCH: $env:VSCODE_ARCH" -ForegroundColor Gray
Write-Host "   VSCODE_QUALITY: $env:VSCODE_QUALITY" -ForegroundColor Gray

# Запускаем подготовку и сборку
Write-Host "🚀 Начинаем сборку VSCodium..." -ForegroundColor Green

# Проверяем наличие bash
if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git Bash не найден. Устанавливаем Git for Windows..." -ForegroundColor Red
    Write-Host "Скачайте и установите Git for Windows с https://git-scm.com/" -ForegroundColor Yellow
    Write-Host "Или запустите этот скрипт от администратора для автоматической установки." -ForegroundColor Yellow
    return
}

# Клонируем репозиторий VSCode (если нужно)
if (-not (Test-Path "vscode")) {
    Write-Host "📥 Получаем исходный код VSCode..." -ForegroundColor Blue
    & bash -c "./get_repo.sh"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Ошибка при получении исходного кода VSCode" -ForegroundColor Red
        return
    }
}

# Подготавливаем VSCode для сборки
Write-Host "🔧 Подготавливаем VSCode..." -ForegroundColor Blue
& bash -c "./prepare_vscode.sh"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка при подготовке VSCode" -ForegroundColor Red
    return
}

# Запускаем основную сборку
Write-Host "🔨 Запускаем сборку..." -ForegroundColor Blue
& bash -c "./build.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Сборка VSCodium завершена успешно!" -ForegroundColor Green
    Write-Host "Проверьте папку с результатами сборки." -ForegroundColor Yellow
} else {
    Write-Host "❌ Ошибка при сборке VSCodium" -ForegroundColor Red
    Write-Host "Проверьте логи выше для диагностики проблемы." -ForegroundColor Yellow
}
