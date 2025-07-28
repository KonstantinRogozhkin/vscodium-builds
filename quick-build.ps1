# Быстрая сборка VSCodium (предполагается, что зависимости уже установлены)

param(
    [string]$Architecture = "x64",  # x64 или arm64
    [string]$Quality = "stable"     # stable или insider
)

Write-Host "🚀 Быстрая сборка VSCodium для Windows" -ForegroundColor Green
Write-Host "Архитектура: $Architecture" -ForegroundColor Yellow
Write-Host "Качество: $Quality" -ForegroundColor Yellow

# Устанавливаем переменные окружения
$env:APP_NAME = "VSCodium"
$env:BINARY_NAME = "codium"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = $Architecture
$env:VSCODE_QUALITY = $Quality
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

Write-Host "🔧 Переменные окружения установлены" -ForegroundColor Green

# Проверяем наличие bash (Git Bash)
try {
    bash --version | Out-Null
    Write-Host "✅ Bash найден" -ForegroundColor Green
} catch {
    Write-Host "❌ Bash не найден. Установите Git for Windows." -ForegroundColor Red
    return
}

# Запускаем сборку
Write-Host "🔨 Запускаем сборку VSCodium..." -ForegroundColor Blue

# Если папка vscode не существует, клонируем репозиторий
if (-not (Test-Path "vscode")) {
    Write-Host "📥 Получаем исходный код VSCode..." -ForegroundColor Blue
    & bash -c "./get_repo.sh"
}

# Подготавливаем и собираем
& bash -c "./prepare_vscode.sh; ./build.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Сборка завершена успешно!" -ForegroundColor Green
    
    # Показываем информацию о результатах
    if (Test-Path "VSCode-win32-$Architecture") {
        Write-Host "📁 Результаты сборки находятся в папке: VSCode-win32-$Architecture" -ForegroundColor Yellow
        $buildSize = (Get-ChildItem "VSCode-win32-$Architecture" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "📊 Размер сборки: $([math]::Round($buildSize, 2)) MB" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Ошибка при сборке" -ForegroundColor Red
} 