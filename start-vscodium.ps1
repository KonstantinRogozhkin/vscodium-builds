# Скрипт для запуска VSCodium
# Автор: AI Assistant
# Дата: 26 июля 2025

param(
    [string]$Path = ".",
    [string]$ExeName = "Code - OSS.exe",
    [string[]]$Arguments = @(),
    [switch]$Background = $false
)

# Проверяем существование исполняемого файла
$exePath = Join-Path $Path $ExeName
if (-not (Test-Path $exePath)) {
    Write-Error "Файл '$exePath' не найден!"
    exit 1
}

Write-Host "Запускаем VSCodium..." -ForegroundColor Green
Write-Host "Путь: $exePath" -ForegroundColor Yellow
Write-Host "Аргументы: $($Arguments -join ' ')" -ForegroundColor Yellow
Write-Host "Режим: $(if ($Background) { 'Фоновый' } else { 'Обычный' })" -ForegroundColor Yellow

try {
    # Запускаем VSCodium с переданными аргументами, используя оператор & для правильной обработки пробелов
    if ($Arguments.Count -gt 0) {
        if ($Background) {
            Start-Process -FilePath $exePath -ArgumentList $Arguments -WindowStyle Normal
        } else {
            & $exePath @Arguments
        }
    } else {
        if ($Background) {
            Start-Process -FilePath $exePath -WindowStyle Normal
        } else {
            & $exePath
        }
    }
    
    Write-Host "VSCodium запущен успешно!" -ForegroundColor Green
} catch {
    Write-Error "Ошибка при запуске VSCodium: $_"
    exit 1
} 