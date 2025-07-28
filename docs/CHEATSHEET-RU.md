# 🚀 VSCodium - Шпаргалка

> Быстрый справочник по командам и процедурам сборки VSCodium

## ⚡ Быстрый старт

### 1. Скачать готовую сборку
```bash
# Открыть страницу с артефактами
open https://github.com/KonstantinRogozhkin/vscodium-builds/actions

# Или через CLI
gh run list --limit=5
gh run download [RUN_ID] --dir ./downloads
```

### 2. Запустить новую сборку
```bash
# Windows x64
gh workflow run "Build Windows" --field vscode_arch=x64

# Универсальная сборка
gh workflow run "Manual Build" \
  --field platform=windows \
  --field architecture=x64
```

### 3. Локальная сборка
```bash
git clone https://github.com/KonstantinRogozhkin/vscodium-builds.git
cd vscodium-builds
./dev/build.sh
```

## 🔧 Команды сборки

### Подготовка
```bash
# Проверка зависимостей
node --version    # 22.15.1+
python3 --version # 3.11+
rustc --version   # 1.70+

# Клонирование
git clone [REPO_URL]
cd vscodium-builds
```

### Быстрая сборка
```bash
# Базовая сборка
./dev/build.sh

# С флагами
./dev/build.sh -i    # Insiders
./dev/build.sh -l    # Latest
./dev/build.sh -p    # Packages
./dev/build.sh -s    # Skip source
```

### Полная сборка
```bash
# Настройка переменных
export SHOULD_BUILD="yes"
export VSCODE_ARCH="x64"
export VSCODE_QUALITY="stable"

# Получение исходников
./get_repo.sh

# Сборка
./build.sh

# Создание пакетов
./prepare_assets.sh
```

## 🤖 GitHub Actions

### Запуск через CLI
```bash
# Установка и авторизация
brew install gh
gh auth login

# Список workflows
gh workflow list

# Запуск сборки
gh workflow run "Build Windows" --field vscode_arch=x64
gh workflow run "Manual Build" --field platform=windows --field architecture=x64

# Мониторинг
gh run list
gh run view [RUN_ID]
gh run watch [RUN_ID]
```

### Скачивание артефактов
```bash
# Список сборок
gh run list --limit=5

# Скачивание
gh run download [RUN_ID] --dir ./artifacts

# Автоматическое скачивание последней
gh run download $(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')
```

## 📦 Типы пакетов

### Windows
- **`.exe`** - Установщик (рекомендуется)
- **`.msi`** - MSI пакет
- **`.zip`** - Портативная версия

### macOS
- **`.dmg`** - Образ диска (рекомендуется)
- **`.zip`** - Архив приложения

### Linux
- **`.deb`** - Ubuntu/Debian
- **`.rpm`** - RedHat/CentOS/Fedora
- **`.tar.gz`** - Универсальный архив
- **`.AppImage`** - Портативное приложение

## 🛠️ Установка зависимостей

### macOS
```bash
# Homebrew
brew install node@22 python@3.11 git jq

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# PATH
echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
source ~/.cargo/env
```

### Windows
```powershell
# Chocolatey
choco install nodejs-lts python311 git 7zip

# WinGet
winget install OpenJS.NodeJS.LTS Python.Python.3.11 Git.Git 7zip.7zip

# Rust
winget install Rustlang.Rustup
```

### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y build-essential curl git jq python3 nodejs npm

# Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## 🔍 Мониторинг и отладка

### Проверка статуса
```bash
# Статус сборок
gh run list

# Детали сборки
gh run view [RUN_ID]

# Логи
gh run view [RUN_ID] --log

# Интерактивный мониторинг
./monitor-build.sh
```

### Отладка локальной сборки
```bash
# Подробный вывод
DEBUG=1 ./dev/build.sh

# Проверка зависимостей
./check-environment.sh

# Очистка кэша
npm cache clean --force
rm -rf node_modules
```

## 🚨 Решение проблем

### Ошибки памяти
```bash
export NODE_OPTIONS="--max-old-space-size=8192"
```

### Ошибки Python
```bash
export PYTHON=$(which python3)
npm config set python $(which python3)
```

### Ошибки Rust
```bash
rustup update
cargo clean
```

### Ошибки msvs_version (Windows)
```bash
# ❌ УСТАРЕЛО: npm config set msvs_version 2019
# ✅ ПРАВИЛЬНО: node-gyp автоматически находит Build Tools
# Убедитесь, что установлены Visual Studio Build Tools с поддержкой C++
```

### Нехватка места
```bash
# Очистка Docker
docker system prune -a

# Очистка node_modules
find . -name "node_modules" -type d -exec rm -rf {} +
```

## ⚙️ Переменные окружения

### Основные
```bash
export SHOULD_BUILD="yes"           # Включить сборку
export VSCODE_ARCH="x64"            # Архитектура (x64, arm64)
export VSCODE_QUALITY="stable"      # Качество (stable, insider)
export OS_NAME="linux"              # ОС (linux, osx, windows)
```

### Оптимизация
```bash
export NODE_OPTIONS="--max-old-space-size=8192"
export MAKEFLAGS="-j$(nproc)"
export SHOULD_BUILD_REH="no"
export SHOULD_BUILD_REH_WEB="no"
```

## 📁 Структура проекта

```
vscodium-builds/
├── .github/workflows/     # GitHub Actions
├── dev/build.sh          # Быстрая сборка
├── build.sh              # Основная сборка
├── get_repo.sh           # Получение исходников
├── prepare_assets.sh     # Создание пакетов
├── monitor-build.sh      # Мониторинг
├── patches/              # Патчи VSCodium
└── docs/                 # Документация
```

## 🔗 Полезные ссылки

- **Репозиторий**: https://github.com/KonstantinRogozhkin/vscodium-builds
- **Actions**: https://github.com/KonstantinRogozhkin/vscodium-builds/actions
- **Оригинальный VSCodium**: https://github.com/VSCodium/vscodium
- **VS Code**: https://github.com/microsoft/vscode

## 📊 Время сборки

| Этап | Время |
|------|-------|
| Компиляция | 15-25 мин |
| Создание пакетов | 10-15 мин |
| **Общее время** | **25-40 мин** |

## 🎯 Быстрые команды

```bash
# Проверить статус последней сборки
gh run list --limit=1

# Скачать последние артефакты
gh run download $(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')

# Запустить сборку и следить за прогрессом
gh workflow run "Build Windows" --field vscode_arch=x64 && \
sleep 10 && \
gh run watch $(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')

# Локальная сборка с пакетами
./dev/build.sh -p

# Проверить размер сборки
du -sh VSCode-*
```

---

**💡 Совет**: Добавьте эти команды в ваши алиасы для еще более быстрого доступа!
