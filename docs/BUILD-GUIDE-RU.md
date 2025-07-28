# 🔧 Подробное руководство по сборке VSCodium

> Полное пошаговое руководство по сборке VSCodium с нуля до готового продукта

## 📋 Содержание

- [Подготовка окружения](#подготовка-окружения)
- [Локальная сборка](#локальная-сборка)
- [Автоматическая сборка](#автоматическая-сборка)
- [Создание пакетов](#создание-пакетов)
- [Оптимизация и отладка](#оптимизация-и-отладка)
- [Продвинутые настройки](#продвинутые-настройки)

## 🛠️ Подготовка окружения

### macOS

#### 1. Установка Xcode Command Line Tools
```bash
xcode-select --install
```

#### 2. Установка Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 3. Установка зависимостей
```bash
# Основные зависимости
brew install node@22 python@3.11 git jq

# Добавление Node.js в PATH
echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Установка Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# Проверка версий
node --version    # v22.15.1+
python3 --version # Python 3.11+
rustc --version   # rustc 1.70+
```

### Windows

#### 1. Установка Visual Studio Build Tools
```powershell
# Скачайте и установите Visual Studio Build Tools 2022
# https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

# Или через Chocolatey
choco install visualstudio2022buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools"

# ⚠️ ВАЖНО: Убедитесь, что установлена рабочая нагрузка "Разработка классических приложений на C++"
# node-gyp автоматически найдет установленные Build Tools без дополнительной настройки
# Команда npm config set msvs_version больше не нужна и была удалена в новых версиях npm
```

#### 2. Установка Node.js и Python
```powershell
# Через официальные установщики или Chocolatey
choco install nodejs-lts python311

# Или через winget
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.11
```

#### 3. Установка дополнительных инструментов
```powershell
# Git
winget install Git.Git

# 7-Zip
winget install 7zip.7zip

# WiX Toolset (для MSI пакетов)
winget install WiXToolset.WiX

# Rust
winget install Rustlang.Rustup
```

#### 4. Настройка PowerShell
```powershell
# Разрешение выполнения скриптов
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux (Ubuntu/Debian)

#### 1. Обновление системы
```bash
sudo apt update && sudo apt upgrade -y
```

#### 2. Установка основных зависимостей
```bash
sudo apt install -y \
  build-essential \
  curl \
  git \
  jq \
  python3 \
  python3-pip \
  pkg-config \
  libx11-dev \
  libxkbfile-dev \
  libsecret-1-dev \
  libkrb5-dev \
  fakeroot \
  rpm \
  imagemagick
```

#### 3. Установка Node.js
```bash
# Через NodeSource
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Или через snap
sudo snap install node --classic
```

#### 4. Установка Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

### Проверка окружения

Создайте скрипт для проверки всех зависимостей:

```bash
#!/bin/bash
# check-environment.sh

echo "🔍 Проверка окружения для сборки VSCodium"
echo "=========================================="

# Функция проверки команды
check_command() {
    if command -v $1 &> /dev/null; then
        echo "✅ $1: $(command -v $1)"
        if [ "$1" != "git" ]; then
            $1 --version | head -1
        else
            git --version
        fi
    else
        echo "❌ $1: не найден"
        return 1
    fi
    echo ""
}

# Проверка основных команд
check_command "node"
check_command "npm"
check_command "python3"
check_command "git"
check_command "jq"
check_command "rustc"
check_command "cargo"

# Проверка версий
echo "📊 Проверка версий:"
node_version=$(node --version | cut -d'v' -f2)
python_version=$(python3 --version | cut -d' ' -f2)
rust_version=$(rustc --version | cut -d' ' -f2)

echo "Node.js: $node_version (требуется 22.15.1+)"
echo "Python: $python_version (требуется 3.11+)"
echo "Rust: $rust_version (требуется 1.70+)"

# Проверка свободного места
echo ""
echo "💾 Свободное место на диске:"
df -h . | tail -1

echo ""
echo "🎯 Готовность к сборке:"
if command -v node &> /dev/null && command -v python3 &> /dev/null && command -v git &> /dev/null; then
    echo "✅ Базовые зависимости установлены"
else
    echo "❌ Не все зависимости установлены"
fi
```

## 🏗️ Локальная сборка

### 1. Клонирование репозитория

```bash
# Клонирование вашего форка
git clone https://github.com/KonstantinRogozhkin/vscodium-builds.git
cd vscodium-builds

# Или клонирование оригинального репозитория
git clone https://github.com/VSCodium/vscodium.git
cd vscodium
```

### 2. Быстрая сборка для разработки

#### macOS/Linux
```bash
# Простая сборка
./dev/build.sh

# Сборка с флагами
./dev/build.sh -i    # Insiders версия
./dev/build.sh -l    # Последняя версия VS Code
./dev/build.sh -p    # С созданием пакетов
./dev/build.sh -s    # Без загрузки исходников
```

#### Windows
```powershell
# PowerShell
powershell -ExecutionPolicy ByPass -File .\dev\build.ps1

# Или через Git Bash
"C:\Program Files\Git\bin\bash.exe" ./dev/build.sh
```

### 3. Пошаговая сборка

#### Шаг 1: Получение исходного кода VS Code
```bash
# Настройка переменных
export SHOULD_BUILD="yes"
export VSCODE_QUALITY="stable"  # или "insider"
export VSCODE_ARCH="x64"        # или "arm64"

# Получение исходников
./get_repo.sh
```

#### Шаг 2: Применение патчей
```bash
# Патчи применяются автоматически в get_repo.sh
# Но можно применить вручную:
cd vscode
git apply ../patches/*.patch
```

#### Шаг 3: Установка зависимостей
```bash
cd vscode
npm install
```

#### Шаг 4: Компиляция
```bash
# Проверки
npm run monaco-compile-check
npm run valid-layers-check

# Компиляция без минификации (быстрее для разработки)
npm run gulp compile-build-without-mangling

# Компиляция расширений
npm run gulp compile-extension-media
npm run gulp compile-extensions-build

# Минификация (для продакшена)
npm run gulp minify-vscode
```

#### Шаг 5: Создание приложения

##### macOS
```bash
npm run gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"
```

##### Windows
```bash
npm run gulp "vscode-win32-${VSCODE_ARCH}-min-ci"
```

##### Linux
```bash
npm run gulp "vscode-linux-${VSCODE_ARCH}-min-ci"
```

### 4. Результаты сборки

После успешной сборки вы найдете:

#### macOS
```
VSCode-darwin-arm64/
└── VSCodium.app/
```

#### Windows
```
VSCode-win32-x64/
├── VSCodium.exe
├── resources/
└── ...
```

#### Linux
```
VSCode-linux-x64/
├── codium
├── resources/
└── ...
```

## 🤖 Автоматическая сборка

### GitHub Actions

#### 1. Настройка репозитория

```bash
# Форк оригинального репозитория
gh repo fork VSCodium/vscodium --clone

# Или создание нового репозитория
gh repo create vscodium-builds --public --clone
```

#### 2. Включение Actions

1. Перейдите в настройки репозитория
2. Откройте раздел "Actions" → "General"
3. Выберите "Allow all actions and reusable workflows"
4. Сохраните настройки

#### 3. Запуск сборки

##### Через веб-интерфейс
1. Откройте раздел "Actions"
2. Выберите нужный workflow
3. Нажмите "Run workflow"
4. Настройте параметры
5. Запустите сборку

##### Через CLI
```bash
# Установка GitHub CLI
brew install gh  # macOS
# или
winget install GitHub.cli  # Windows

# Авторизация
gh auth login

# Запуск сборки Windows
gh workflow run "Build Windows" --field vscode_arch=x64

# Запуск универсальной сборки
gh workflow run "Manual Build" \
  --field platform=windows \
  --field architecture=x64 \
  --field skip_compile=false

# Мониторинг
gh run list
gh run view [RUN_ID]
```

#### 4. Кастомизация workflows

##### Изменение триггеров
```yaml
# .github/workflows/build-windows.yml
on:
  push:
    branches: [ master, develop ]  # Добавьте ветки
  schedule:
    - cron: '0 2 * * 1'  # Еженедельная сборка
  workflow_dispatch:  # Ручной запуск
```

##### Добавление уведомлений
```yaml
- name: Notify on success
  if: success()
  uses: 8398a7/action-slack@v3
  with:
    status: success
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

##### Настройка кэширования
```yaml
- name: Cache node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

## 📦 Создание пакетов

### Windows

#### 1. Создание установщика (.exe)
```bash
# Требует NSIS (Nullsoft Scriptable Install System)
cd vscode
npm run gulp "vscode-win32-${VSCODE_ARCH}-inno-updater"
```

#### 2. Создание MSI пакета
```bash
# Требует WiX Toolset
npm run gulp "vscode-win32-${VSCODE_ARCH}-msi"
```

#### 3. Создание ZIP архива
```bash
npm run gulp "vscode-win32-${VSCODE_ARCH}-archive"
```

### macOS

#### 1. Создание DMG образа
```bash
cd vscode
npm run gulp "vscode-darwin-${VSCODE_ARCH}-dmg"
```

#### 2. Подпись приложения (требует Apple Developer Account)
```bash
# Настройка сертификатов
security find-identity -v -p codesigning

# Подпись
codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" VSCodium.app

# Нотаризация
xcrun notarytool submit VSCodium.dmg --keychain-profile "notarytool-profile" --wait
```

### Linux

#### 1. Создание DEB пакета
```bash
cd vscode
npm run gulp "vscode-linux-${VSCODE_ARCH}-build-deb"
```

#### 2. Создание RPM пакета
```bash
npm run gulp "vscode-linux-${VSCODE_ARCH}-build-rpm"
```

#### 3. Создание AppImage
```bash
# Требует appimagetool
npm run gulp "vscode-linux-${VSCODE_ARCH}-prepare-appimage"
./build/linux/appimage/build.sh
```

#### 4. Создание Snap пакета
```bash
# Требует snapcraft
snapcraft
```

### Универсальный скрипт создания пакетов

```bash
#!/bin/bash
# create-packages.sh

set -e

PLATFORM=${1:-$(uname | tr '[:upper:]' '[:lower:]')}
ARCH=${2:-x64}

echo "🏗️  Создание пакетов для $PLATFORM ($ARCH)"

case $PLATFORM in
    "darwin"|"osx")
        echo "📦 Создание macOS пакетов..."
        npm run gulp "vscode-darwin-${ARCH}-dmg"
        ;;
    "linux")
        echo "📦 Создание Linux пакетов..."
        npm run gulp "vscode-linux-${ARCH}-build-deb"
        npm run gulp "vscode-linux-${ARCH}-build-rpm"
        npm run gulp "vscode-linux-${ARCH}-prepare-appimage"
        ;;
    "windows"|"win32")
        echo "📦 Создание Windows пакетов..."
        npm run gulp "vscode-win32-${ARCH}-inno-updater"
        npm run gulp "vscode-win32-${ARCH}-msi"
        npm run gulp "vscode-win32-${ARCH}-archive"
        ;;
    *)
        echo "❌ Неподдерживаемая платформа: $PLATFORM"
        exit 1
        ;;
esac

echo "✅ Пакеты созданы успешно!"
```

## 🔧 Оптимизация и отладка

### Ускорение сборки

#### 1. Использование кэша
```bash
# Сохранение node_modules
export npm_config_cache="/tmp/npm-cache"

# Использование ccache для C++ компиляции
export CC="ccache gcc"
export CXX="ccache g++"
```

#### 2. Параллельная сборка
```bash
# Увеличение количества процессов
export MAKEFLAGS="-j$(nproc)"
export NODE_OPTIONS="--max-old-space-size=8192"
```

#### 3. Пропуск ненужных этапов
```bash
# Пропуск тестов
export SKIP_TESTS="true"

# Пропуск Remote Extension Host
export SHOULD_BUILD_REH="no"
export SHOULD_BUILD_REH_WEB="no"
```

### Отладка проблем

#### 1. Включение подробного вывода
```bash
export DEBUG="*"
export VERBOSE="true"
npm run gulp compile-build-without-mangling -- --verbose
```

#### 2. Анализ ошибок компиляции
```bash
# Проверка TypeScript ошибок
npm run monaco-compile-check 2>&1 | tee compile-errors.log

# Проверка слоев
npm run valid-layers-check 2>&1 | tee layers-errors.log
```

#### 3. Профилирование сборки
```bash
# Измерение времени выполнения
time npm run gulp compile-build-without-mangling

# Анализ использования памяти
/usr/bin/time -v npm run gulp compile-build-without-mangling
```

### Решение частых проблем

#### 1. Ошибки памяти
```bash
# Увеличение лимита памяти для Node.js
export NODE_OPTIONS="--max-old-space-size=16384"

# Очистка кэша npm
npm cache clean --force
```

#### 2. Ошибки Python
```bash
# Указание версии Python
export PYTHON=$(which python3)
npm config set python $(which python3)
```

#### 3. Ошибки Rust
```bash
# Обновление Rust
rustup update

# Очистка кэша Cargo
cargo clean
```

#### 4. Ошибки с msvs_version
```bash
# ❌ УСТАРЕЛО: npm config set msvs_version 2019
# ✅ ПРАВИЛЬНО: node-gyp автоматически находит Build Tools

# Если появляется ошибка "npm config set msvs_version is not a valid npm command":
# 1. Убедитесь, что установлены Visual Studio Build Tools с поддержкой C++
# 2. Проверьте, что установлена рабочая нагрузка "Desktop development with C++"
# 3. Перезапустите терминал и попробуйте сборку снова
# 4. node-gyp автоматически определит доступные версии Visual Studio
```

## ⚡ Продвинутые настройки

### Кастомизация продукта

#### 1. Изменение брендинга
```javascript
// product.json
{
  "nameShort": "VSCodium",
  "nameLong": "VSCodium",
  "applicationName": "codium",
  "win32MutexName": "vscodium",
  "darwinBundleIdentifier": "com.vscodium",
  "linuxIconName": "vscodium"
}
```

#### 2. Настройка расширений
```javascript
// product.json
{
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  }
}
```

#### 3. Отключение телеметрии
```javascript
// Уже настроено в VSCodium
{
  "enableTelemetry": false,
  "enableCrashReporter": false,
  "enableExperiments": false
}
```

### Создание собственных патчей

#### 1. Создание патча
```bash
cd vscode
# Внесите изменения в код
git add .
git commit -m "Custom changes"
git format-patch HEAD~1 --stdout > ../patches/custom.patch
```

#### 2. Применение патча
```bash
cd vscode
git apply ../patches/custom.patch
```

### Настройка CI/CD

#### 1. Автоматические релизы
```yaml
# .github/workflows/release.yml
- name: Create Release
  uses: actions/create-release@v1
  with:
    tag_name: ${{ env.RELEASE_VERSION }}
    release_name: VSCodium ${{ env.RELEASE_VERSION }}
    draft: false
    prerelease: false
```

#### 2. Уведомления
```yaml
- name: Discord notification
  uses: Ilshidur/action-discord@master
  with:
    args: 'VSCodium ${{ env.RELEASE_VERSION }} собран успешно!'
  env:
    DISCORD_WEBHOOK: ${{ secrets.DISCORD_WEBHOOK }}
```

#### 3. Тестирование сборок
```yaml
- name: Test build
  run: |
    if [[ "$RUNNER_OS" == "macOS" ]]; then
      ./VSCode-darwin-*/VSCodium.app/Contents/MacOS/Electron --version
    elif [[ "$RUNNER_OS" == "Windows" ]]; then
      ./VSCode-win32-*/VSCodium.exe --version
    else
      ./VSCode-linux-*/codium --version
    fi
```

### Мониторинг и аналитика

#### 1. Сбор метрик сборки
```bash
#!/bin/bash
# build-metrics.sh

START_TIME=$(date +%s)
./build.sh
END_TIME=$(date +%s)

BUILD_TIME=$((END_TIME - START_TIME))
BUILD_SIZE=$(du -sh VSCode-* | cut -f1)

echo "Build time: ${BUILD_TIME}s"
echo "Build size: ${BUILD_SIZE}"

# Отправка метрик в систему мониторинга
curl -X POST "https://metrics.example.com/builds" \
  -H "Content-Type: application/json" \
  -d "{\"time\": $BUILD_TIME, \"size\": \"$BUILD_SIZE\"}"
```

#### 2. Автоматическое тестирование
```bash
#!/bin/bash
# smoke-test.sh

BINARY_PATH="$1"

echo "🧪 Запуск smoke тестов для $BINARY_PATH"

# Проверка запуска
timeout 30s "$BINARY_PATH" --version || exit 1

# Проверка базовой функциональности
timeout 60s "$BINARY_PATH" --list-extensions || exit 1

echo "✅ Smoke тесты прошли успешно"
```

---

**Это руководство покрывает все аспекты сборки VSCodium от базовой настройки до продвинутых техник оптимизации и автоматизации.**
