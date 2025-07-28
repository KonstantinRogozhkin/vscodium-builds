#!/usr/bin/env bash

echo "=== Тест иконок Neira ==="
echo ""

# Проверяем наличие файлов иконок
echo "Проверка файлов иконок:"
for file in neira-512_page_01.svg neira-512_page_02.svg neira-512_page_03.svg neira-512_page_04.svg neira-512_page_05.svg; do
    if [[ -f "neira/$file" ]]; then
        echo "✓ $file найден"
    else
        echo "✗ $file НЕ найден"
    fi
done

echo ""

# Проверяем размеры файлов
echo "Размеры файлов иконок:"
for file in neira-512_page_01.svg neira-512_page_02.svg neira-512_page_03.svg neira-512_page_04.svg neira-512_page_05.svg; do
    if [[ -f "neira/$file" ]]; then
        size=$(stat -c%s "neira/$file" 2>/dev/null || stat -f%z "neira/$file" 2>/dev/null || echo "неизвестно")
        echo "$file: $size байт"
    fi
done

echo ""

# Проверяем наличие основных утилит
echo "Проверка зависимостей:"
deps=("rsvg-convert" "convert" "composite" "sed")
for dep in "${deps[@]}"; do
    if command -v "$dep" &> /dev/null; then
        echo "✓ $dep найден"
    else
        echo "✗ $dep НЕ найден"
    fi
done

echo ""

# Пробуем конвертировать одну иконку в PNG для теста
echo "Тест конвертации SVG в PNG:"
if command -v rsvg-convert &> /dev/null && [[ -f "neira/neira-512_page_04.svg" ]]; then
    rsvg-convert -w 64 -h 64 "neira/neira-512_page_04.svg" -o "test_neira_64.png"
    if [[ -f "test_neira_64.png" ]]; then
        echo "✓ Конвертация успешна, создан test_neira_64.png"
        rm "test_neira_64.png"
    else
        echo "✗ Ошибка конвертации"
    fi
else
    echo "✗ Невозможно протестировать конвертацию (rsvg-convert не найден или файл отсутствует)"
fi

echo ""
echo "=== Тест завершен ===" 