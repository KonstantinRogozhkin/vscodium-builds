#!/bin/bash

# Скрипт для тестирования workflow локально
# Использует act для запуска GitHub Actions локально

set -e

echo "🚀 Тестирование VSCodium GitHub Actions workflows"
echo "================================================"

# Проверяем наличие act
if ! command -v act &> /dev/null; then
    echo "❌ act не установлен. Установите его:"
    echo "   brew install act"
    echo "   или скачайте с https://github.com/nektos/act"
    exit 1
fi

# Проверяем наличие Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker не установлен. Установите Docker Desktop"
    exit 1
fi

# Функция для показа доступных workflows
show_workflows() {
    echo "📋 Доступные workflows:"
    echo "1. build-windows - Сборка для Windows"
    echo "2. manual-build - Универсальная сборка"
    echo "3. list - Показать все workflows"
    echo "4. exit - Выход"
}

# Функция для запуска build-windows workflow
run_build_windows() {
    echo "🏗️  Запуск build-windows workflow..."
    echo "⚠️  Внимание: это может занять много времени и ресурсов!"
    
    read -p "Продолжить? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        act workflow_dispatch -W .github/workflows/build-windows.yml \
            --input vscode_arch=x64 \
            --verbose
    fi
}

# Функция для запуска manual-build workflow
run_manual_build() {
    echo "🏗️  Запуск manual-build workflow..."
    echo "Выберите платформу:"
    echo "1. windows"
    echo "2. macos" 
    echo "3. linux"
    
    read -p "Введите номер (1-3): " platform_choice
    
    case $platform_choice in
        1) platform="windows" ;;
        2) platform="macos" ;;
        3) platform="linux" ;;
        *) echo "❌ Неверный выбор"; return ;;
    esac
    
    echo "Выберите архитектуру:"
    echo "1. x64"
    echo "2. arm64"
    
    read -p "Введите номер (1-2): " arch_choice
    
    case $arch_choice in
        1) architecture="x64" ;;
        2) architecture="arm64" ;;
        *) echo "❌ Неверный выбор"; return ;;
    esac
    
    echo "🏗️  Запуск сборки для $platform ($architecture)..."
    echo "⚠️  Внимание: это может занять много времени и ресурсов!"
    
    read -p "Продолжить? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        act workflow_dispatch -W .github/workflows/manual-build.yml \
            --input platform="$platform" \
            --input architecture="$architecture" \
            --input skip_compile=false \
            --verbose
    fi
}

# Функция для показа всех workflows
list_workflows() {
    echo "📋 Все workflows в репозитории:"
    act -l
}

# Главное меню
while true; do
    echo
    show_workflows
    echo
    read -p "Выберите действие (1-4): " choice
    
    case $choice in
        1)
            run_build_windows
            ;;
        2)
            run_manual_build
            ;;
        3)
            list_workflows
            ;;
        4)
            echo "👋 До свидания!"
            exit 0
            ;;
        *)
            echo "❌ Неверный выбор. Попробуйте снова."
            ;;
    esac
done
