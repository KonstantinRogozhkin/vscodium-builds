# 🚀 Neira - Автоматическая сборка

> **Neira** - это кастомная версия Visual Studio Code с открытым исходным кодом, основанная на VSCodium, с собственным брендингом и русской локализацией по умолчанию.

## 📋 Содержание

- [Быстрый старт](#быстрый-старт)
- [Автоматическая сборка](#автоматическая-сборка)
- [Ручная сборка](#ручная-сборка)
- [Скачивание готовых сборок](#скачивание-готовых-сборок)
- [Поддерживаемые платформы](#поддерживаемые-платформы)
- [Устранение неполадок](#устранение-неполадок)
- [Участие в разработке](#участие-в-разработке)

## 🚀 Быстрый старт

### Для пользователей (скачать готовую сборку)

1. Перейдите в раздел [**Actions**](https://github.com/KonstantinRogozhkin/vscodium-builds/actions)
2. Выберите последнюю успешную сборку (зеленая галочка ✅)
3. Скачайте нужный артефакт из секции **"Artifacts"**
4. Установите Neira как обычную программу

### Для разработчиков (запустить новую сборку)

1. Перейдите в [**Actions**](https://github.com/KonstantinRogozhkin/vscodium-builds/actions) → **"Manual Build"**
2. Нажмите **"Run workflow"**
3. Выберите платформу и архитектуру
4. Дождитесь завершения (~30-40 минут)
5. Скачайте артефакты Neira

## ✨ Особенности Neira

**Neira** - это кастомизированная версия VS Code, основанная на VSCodium, с дополнительными улучшениями:

### 🎨 Собственный брендинг
- **Название приложения**: Neira (вместо VSCodium)
- **Исполняемый файл**: `neira` (вместо `codium`)
- **Уникальные иконки**: Прозрачные иконки Neira с современным дизайном
- **Настроенные идентификаторы**: Собственные ID приложения для всех платформ

### 🌍 Русская локализация
- **Русский язык по умолчанию**: Интерфейс на русском языке из коробки
- **Локализованные сообщения**: Все системные уведомления на русском
- **Поддержка мультиязычности**: Возможность переключения на другие языки

### 🔧 Техническая база
- **Основа**: VSCodium (VS Code без телеметрии Microsoft)
- **Автоматическая сборка**: GitHub Actions с поддержкой всех платформ
- **Совместимость**: Полная совместимость с расширениями VS Code
- **Открытый исходный код**: Все изменения доступны в репозитории

### 📦 Форматы распространения
- **macOS**: `.dmg` установщик и `.app` пакет
- **Windows**: `.exe`, `.msi` установщики и `.zip` архив
- **Linux**: `.deb`, `.rpm` пакеты и `.tar.gz` архив
- **CLI инструменты**: Командная строка `neira` для всех платформ

## 🤖 Автоматическая сборка

### GitHub Actions Workflows

Репозиторий содержит несколько автоматизированных сборочных процессов:

#### 1. **Build Windows** - Сборка для Windows
- **Триггеры**: Push в master, Pull Request, ручной запуск
- **Архитектуры**: x64, ARM64
- **Артефакты**: .exe, .msi, .zip файлы

#### 2. **Manual Build** - Универсальная сборка
- **Триггеры**: Только ручной запуск
- **Платформы**: Windows, macOS, Linux
- **Архитектуры**: x64, ARM64

### Запуск сборки через веб-интерфейс

1. **Откройте раздел Actions**: https://github.com/KonstantinRogozhkin/vscodium-builds/actions
2. **Выберите workflow**:
   - `Build Windows` - для Windows
   - `Manual Build` - для любой платформы
3. **Нажмите "Run workflow"**
4. **Настройте параметры**:
   - Платформа (windows/macos/linux)
   - Архитектура (x64/arm64)
   - Пропустить компиляцию (для ускорения)
5. **Запустите сборку**

### Запуск сборки через командную строку

```bash
# Установите GitHub CLI
brew install gh

# Авторизуйтесь
gh auth login

# Запустите сборку Windows x64
gh workflow run "Build Windows" --field vscode_arch=x64

# Запустите универсальную сборку
gh workflow run "Manual Build" \
  --field platform=windows \
  --field architecture=x64 \
  --field skip_compile=false

# Проверьте статус
gh run list --limit=3

# Скачайте артефакты (после завершения)
gh run download [RUN_ID] --dir ./artifacts
```

## 🔨 Ручная сборка

### Требования

#### Общие зависимости
- **Node.js** 22.15.1+
- **Python** 3.11+
- **Git**
- **jq**
- **Rust** (rustup)

#### macOS
```bash
# Установка через Homebrew
brew install node@22 python@3.11 git jq
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Windows
- **PowerShell**
- **Visual Studio Build Tools** или **Visual Studio Community**
- **WiX Toolset** (для MSI пакетов)
- **7-Zip**

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install -y build-essential libx11-dev libxkbfile-dev \
  libsecret-1-dev libkrb5-dev fakeroot rpm imagemagick
```

### Процесс сборки

#### 1. Клонирование репозитория
```bash
git clone https://github.com/KonstantinRogozhkin/vscodium-builds.git
cd vscodium-builds
```

#### 2. Быстрая сборка (для разработки)
```bash
# macOS/Linux
./dev/build.sh

# Windows
powershell -ExecutionPolicy ByPass -File .\dev\build.ps1
```

#### 3. Полная сборка (для продакшена)
```bash
# Настройка переменных окружения
export SHOULD_BUILD="yes"
export SHOULD_BUILD_REH="no"
export CI_BUILD="no"
export OS_NAME="linux"  # или "osx", "windows"
export VSCODE_ARCH="x64"  # или "arm64"
export VSCODE_QUALITY="stable"

# Получение исходного кода
./get_repo.sh

# Сборка
./build.sh
```

#### 4. Создание пакетов
```bash
# Подготовка ассетов
./prepare_assets.sh

# Создание контрольных сумм
./prepare_checksums.sh
```

### Флаги сборки

Скрипт `dev/build.sh` поддерживает следующие флаги:

- **`-i`** - Сборка Insiders версии
- **`-l`** - Использовать последнюю версию VS Code
- **`-o`** - Пропустить этап сборки
- **`-p`** - Создать пакеты/установщики
- **`-s`** - Не загружать исходный код заново

```bash
# Примеры использования
./dev/build.sh -i          # Insiders версия
./dev/build.sh -l          # Последняя версия
./dev/build.sh -p          # С созданием пакетов
./dev/build.sh -i -l -p    # Комбинация флагов
```

## 📦 Скачивание готовых сборок

### Через веб-интерфейс

1. **Перейдите в Actions**: https://github.com/KonstantinRogozhkin/vscodium-builds/actions
2. **Выберите завершенную сборку** (зеленая галочка ✅)
3. **Прокрутите вниз до "Artifacts"**
4. **Скачайте нужный файл**:
   - `vscodium-windows-x64` - Windows 64-bit
   - `vscodium-windows-arm64` - Windows ARM64
   - `vscodium-macos-*` - macOS
   - `vscodium-linux-*` - Linux

### Через командную строку

```bash
# Список последних сборок
gh run list --limit=5

# Скачивание артефактов
gh run download [RUN_ID] --dir ./downloads

# Автоматическое скачивание последней сборки
./monitor-build.sh  # выберите опцию 4
```

### Типы файлов

#### Windows
- **`.exe`** - Установщик (рекомендуется)
- **`.msi`** - MSI пакет для корпоративного развертывания
- **`.zip`** - Портативная версия

#### macOS
- **`.dmg`** - Образ диска (рекомендуется)
- **`.zip`** - Архив приложения

#### Linux
- **`.deb`** - Пакет для Ubuntu/Debian
- **`.rpm`** - Пакет для RedHat/CentOS/Fedora
- **`.tar.gz`** - Универсальный архив
- **`.AppImage`** - Портативное приложение

## 🖥️ Поддерживаемые платформы

| Платформа | Архитектуры | Статус | Примечания |
|-----------|-------------|--------|------------|
| **Windows** | x64, ARM64 | ✅ Полная поддержка | Все типы пакетов |
| **macOS** | x64, ARM64 (Apple Silicon) | ✅ Полная поддержка | Требует macOS 10.15+ |
| **Linux** | x64, ARM64 | ✅ Полная поддержка | Ubuntu 18.04+, CentOS 7+ |

### Системные требования

#### Минимальные
- **ОЗУ**: 1 ГБ
- **Диск**: 200 МБ свободного места
- **ОС**: Windows 10, macOS 10.15, Ubuntu 18.04

#### Рекомендуемые
- **ОЗУ**: 4 ГБ+
- **Диск**: 1 ГБ свободного места
- **ОС**: Последние версии

## 🛠️ Мониторинг сборки

### Скрипт мониторинга

```bash
# Запуск интерактивного мониторинга
./monitor-build.sh

# Доступные опции:
# 1. Показать статус сборок
# 2. Показать детали последней сборки  
# 3. Показать логи
# 4. Скачать артефакты
# 5. Открыть в браузере
# 6. Автообновление каждые 30 сек
```

### Тестирование workflow локально

```bash
# Установка act (для локального тестирования)
brew install act

# Запуск тестового скрипта
./test-workflow.sh

# Ручной запуск workflow
act workflow_dispatch -W .github/workflows/build-windows.yml \
  --input vscode_arch=x64
```

## 🚨 Устранение неполадок

### Частые проблемы

#### 1. Ошибка "No space left on device"
```bash
# Очистка кэша Docker (если используете act)
docker system prune -a

# Очистка node_modules
find . -name "node_modules" -type d -exec rm -rf {} +
```

#### 2. Ошибки компиляции
```bash
# Проверка версий зависимостей
node --version    # Должно быть 22.15.1+
python3 --version # Должно быть 3.11+
rustc --version   # Должно быть 1.70+

# Переустановка зависимостей
rm -rf node_modules package-lock.json
npm install
```

#### 3. Таймауты сборки
- Увеличьте timeout в workflow файлах
- Проверьте интернет-соединение
- Используйте флаг `-s` для пропуска загрузки исходников

#### 4. Ошибки подписи (только для официальных релизов)
- Подпись кода требует специальных сертификатов
- Для личного использования подпись не обязательна
- Удалите секции signing из workflow

### Логи и отладка

```bash
# Просмотр логов сборки
gh run view [RUN_ID] --log

# Просмотр логов конкретного job
gh run view [RUN_ID] --job=[JOB_ID] --log

# Локальная отладка
DEBUG=1 ./dev/build.sh
```

### Получение помощи

1. **Проверьте логи** в Actions
2. **Сравните с оригинальными** workflow VSCodium
3. **Создайте Issue** с описанием проблемы
4. **Приложите логи** и информацию о системе

## 🤝 Участие в разработке

### Структура проекта

```
vscodium-builds/
├── .github/workflows/     # GitHub Actions workflows
│   ├── build-windows.yml  # Автоматическая сборка Windows
│   ├── manual-build.yml   # Универсальная сборка
│   └── README.md          # Документация workflows
├── dev/                   # Скрипты для разработки
│   └── build.sh           # Быстрая сборка
├── build/                 # Скрипты сборки
├── patches/               # Патчи для VS Code
├── docs/                  # Документация
├── monitor-build.sh       # Мониторинг сборки
├── test-workflow.sh       # Тестирование workflows
├── README-RU.md          # Русская документация
└── DEPLOY.md             # Инструкции по деплою
```

### Добавление новых функций

1. **Форкните репозиторий**
2. **Создайте ветку** для новой функции
3. **Внесите изменения**
4. **Протестируйте** локально
5. **Создайте Pull Request**

### Кастомизация сборки

#### Изменение версий зависимостей
```yaml
# В .github/workflows/*.yml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '22.15.1'  # Измените здесь
```

#### Добавление новых архитектур
```yaml
# В matrix strategy
matrix:
  vscode_arch:
    - x64
    - arm64
    - ia32  # Добавьте новую
```

#### Настройка времени хранения артефактов
```yaml
- name: Upload artifacts
  uses: actions/upload-artifact@v4
  with:
    retention-days: 30  # 1-90 дней
```

## 📊 Статистика и метрики

### Время сборки (примерное)

| Этап | Windows | macOS | Linux |
|------|---------|-------|-------|
| **Компиляция** | 15-25 мин | 20-30 мин | 15-25 мин |
| **Сборка пакетов** | 10-15 мин | 15-20 мин | 10-15 мин |
| **Общее время** | 25-40 мин | 35-50 мин | 25-40 мин |

### Размеры артефактов

| Тип файла | Размер | Описание |
|-----------|--------|----------|
| **Windows .exe** | ~80-100 МБ | Установщик |
| **Windows .msi** | ~80-100 МБ | MSI пакет |
| **Windows .zip** | ~200-250 МБ | Портативная версия |
| **macOS .dmg** | ~100-120 МБ | Образ диска |
| **Linux .deb** | ~80-100 МБ | DEB пакет |
| **Linux .AppImage** | ~200-250 МБ | Портативное приложение |

## 🔗 Полезные ссылки

- **Официальный VSCodium**: https://vscodium.com/
- **Исходный код VS Code**: https://github.com/microsoft/vscode
- **Документация VS Code**: https://code.visualstudio.com/docs
- **GitHub Actions**: https://docs.github.com/en/actions
- **Electron**: https://www.electronjs.org/

## 📄 Лицензия

Этот проект использует лицензию MIT. VSCodium распространяется под лицензией MIT.

---

**Создано с ❤️ для русскоязычного сообщества разработчиков**

> Если у вас есть вопросы или предложения, создайте Issue или Pull Request!
