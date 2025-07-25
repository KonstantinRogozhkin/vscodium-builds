#!/bin/bash

# Скрипт для мониторинга сборки VSCodium

echo "🔍 Мониторинг сборки VSCodium"
echo "=============================="

# Функция для показа статуса
show_status() {
    echo "📊 Текущие сборки:"
    gh run list --limit=3
    echo ""
}

# Функция для показа деталей последней сборки
show_details() {
    local run_id=$(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')
    if [ -n "$run_id" ]; then
        echo "🔍 Детали сборки #$run_id:"
        gh run view $run_id
        echo ""
    fi
}

# Функция для показа логов
show_logs() {
    local run_id=$(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')
    if [ -n "$run_id" ]; then
        echo "📋 Последние логи:"
        gh run view $run_id --log --log-failed
    fi
}

# Функция для скачивания артефактов
download_artifacts() {
    local run_id=$(gh run list --status=completed --limit=1 --json databaseId --jq '.[0].databaseId')
    if [ -n "$run_id" ]; then
        echo "📦 Скачивание артефактов..."
        mkdir -p ./artifacts
        gh run download $run_id --dir ./artifacts
        echo "✅ Артефакты скачаны в ./artifacts/"
        ls -la ./artifacts/
    else
        echo "❌ Нет завершенных сборок для скачивания"
    fi
}

# Главное меню
while true; do
    echo "Выберите действие:"
    echo "1. Показать статус сборок"
    echo "2. Показать детали последней сборки"
    echo "3. Показать логи"
    echo "4. Скачать артефакты (только для завершенных сборок)"
    echo "5. Открыть в браузере"
    echo "6. Автообновление (каждые 30 сек)"
    echo "7. Выход"
    echo ""
    
    read -p "Введите номер (1-7): " choice
    
    case $choice in
        1)
            show_status
            ;;
        2)
            show_details
            ;;
        3)
            show_logs
            ;;
        4)
            download_artifacts
            ;;
        5)
            open https://github.com/KonstantinRogozhkin/vscodium-builds/actions
            ;;
        6)
            echo "🔄 Автообновление каждые 30 секунд (Ctrl+C для остановки)..."
            while true; do
                clear
                echo "🔍 Мониторинг сборки VSCodium - $(date)"
                echo "=============================="
                show_status
                show_details
                echo "Следующее обновление через 30 секунд..."
                sleep 30
            done
            ;;
        7)
            echo "👋 До свидания!"
            exit 0
            ;;
        *)
            echo "❌ Неверный выбор. Попробуйте снова."
            ;;
    esac
    
    echo ""
    read -p "Нажмите Enter для продолжения..."
    clear
done
