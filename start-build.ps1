# Простой скрипт запуска сборки VSCodium
param(
    [string]$Architecture = "x64"
)

Write-Host "🚀 Запуск сборки VSCodium" -ForegroundColor Green

# Добавляем пути к программам
$env:PATH += ";C:\Program Files\nodejs"
$env:PATH += ";C:\Program Files\Git\bin"
$env:PATH += ";C:\Python311"

# Устанавливаем переменные окружения
$env:APP_NAME = "VSCodium"
$env:BINARY_NAME = "codium"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = $Architecture
$env:VSCODE_QUALITY = "stable"
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Write-Host "✅ Переменные окружения установлены" -ForegroundColor Green

# Проверяем Git
try {
    $gitVersion = git --version
    Write-Host "✅ Git: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git не найден" -ForegroundColor Red
    return
}

# Запускаем сборку
Write-Host "🔨 Запускаем сборку..." -ForegroundColor Blue

if (Test-Path "build.sh") {
    & bash -c "./build.sh"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 Сборка завершена успешно!" -ForegroundColor Green
    } else {
        Write-Host "❌ Ошибка при сборке: $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "❌ build.sh не найден" -ForegroundColor Red
}
