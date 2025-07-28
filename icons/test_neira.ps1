Write-Host "=== Тест иконок Neira ===" -ForegroundColor Green
Write-Host ""

# Проверяем наличие файлов иконок
Write-Host "Проверка файлов иконок:" -ForegroundColor Yellow
$files = @("neira-512_page_01.svg", "neira-512_page_02.svg", "neira-512_page_03.svg", "neira-512_page_04.svg", "neira-512_page_05.svg")

foreach ($file in $files) {
    $path = "neira\$file"
    if (Test-Path $path) {
        Write-Host "✓ $file найден" -ForegroundColor Green
    } else {
        Write-Host "✗ $file НЕ найден" -ForegroundColor Red
    }
}

Write-Host ""

# Проверяем размеры файлов
Write-Host "Размеры файлов иконок:" -ForegroundColor Yellow
foreach ($file in $files) {
    $path = "neira\$file"
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        Write-Host "$file`: $size байт"
    }
}

Write-Host ""

# Проверяем наличие основных утилит (для Windows)
Write-Host "Проверка зависимостей:" -ForegroundColor Yellow
$deps = @("rsvg-convert", "convert", "composite", "sed")

foreach ($dep in $deps) {
    try {
        $null = Get-Command $dep -ErrorAction Stop
        Write-Host "✓ $dep найден" -ForegroundColor Green
    } catch {
        Write-Host "✗ $dep НЕ найден" -ForegroundColor Red
    }
}

Write-Host ""

# Проверяем структуру папок
Write-Host "Структура папок:" -ForegroundColor Yellow
if (Test-Path "neira") {
    Write-Host "✓ Папка neira существует" -ForegroundColor Green
    $neiraFiles = Get-ChildItem "neira" -Name "*.svg"
    Write-Host "Найдено SVG файлов в neira: $($neiraFiles.Count)"
} else {
    Write-Host "✗ Папка neira НЕ существует" -ForegroundColor Red
}

Write-Host ""

# Проверяем наличие основного скрипта сборки
Write-Host "Проверка скриптов сборки:" -ForegroundColor Yellow
if (Test-Path "build_icons_neira.sh") {
    Write-Host "✓ build_icons_neira.sh найден" -ForegroundColor Green
} else {
    Write-Host "✗ build_icons_neira.sh НЕ найден" -ForegroundColor Red
}

if (Test-Path "build_icons.sh") {
    Write-Host "✓ build_icons.sh найден" -ForegroundColor Green
} else {
    Write-Host "✗ build_icons.sh НЕ найден" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Тест завершен ===" -ForegroundColor Green
Write-Host ""
Write-Host "Для использования иконок Neira:" -ForegroundColor Cyan
Write-Host "1. Установите необходимые зависимости (rsvg-convert, ImageMagick)" -ForegroundColor White
Write-Host "2. Запустите: bash build_icons_neira.sh -n" -ForegroundColor White
Write-Host "3. Или используйте WSL/Git Bash для запуска скриптов" -ForegroundColor White 