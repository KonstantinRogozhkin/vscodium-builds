#!/bin/bash

# Скрипт для удаления черного фона из SVG файлов Neira и замены его на прозрачный

echo "🎨 Удаление черного фона из SVG файлов Neira..."

# Создаем резервные копии
mkdir -p icons/neira/backup
cp icons/neira/*.svg icons/neira/backup/

# Обрабатываем каждый SVG файл
for svg_file in icons/neira/neira-*.svg; do
    if [[ -f "$svg_file" ]]; then
        echo "Обрабатываем: $(basename "$svg_file")"
        
        # Удаляем строку с черным фоном (fill:#010101 или похожие темные цвета)
        # Это строка вида: <path style="fill:#010101; stroke:#010101;" d="M0 0L0 1024L1024 1024L1024 0L0 0z"/>
        sed -i.bak '/fill:#0[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f].*M0 0L0 1024L1024 1024L1024 0L0 0z/d' "$svg_file"
        
        # Также удаляем другие возможные варианты черного фона
        sed -i.bak '/fill:#000000/d' "$svg_file"
        sed -i.bak '/fill:#000/d' "$svg_file"
        
        # Удаляем временные .bak файлы
        rm -f "${svg_file}.bak"
        
        echo "✅ Обработан: $(basename "$svg_file")"
    fi
done

echo "🎉 Готово! Черный фон удален из всех SVG файлов."
echo "📁 Резервные копии сохранены в icons/neira/backup/"
