# 🚀 Руководство по сборке VSCodium на Windows

## 📋 Необходимые зависимости

### 1. Node.js 22.15.1
- Скачайте с [nodejs.org](https://nodejs.org/)
- Или установите через Chocolatey: `choco install nodejs --version=22.15.1`

### 2. Python 3.x
- Скачайте с [python.org](https://python.org/)
- Или установите через Chocolatey: `choco install python`

### 3. Visual Studio Build Tools
- Скачайте [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/)
- Или установите Visual Studio Community с поддержкой C++
- **Важно:** Убедитесь, что установлена рабочая нагрузка **"Разработка классических приложений на C++"** (`Desktop development with C++`)
- node-gyp автоматически найдет установленные Build Tools без дополнительной настройки

### 4. Git for Windows
- Скачайте с [git-scm.com](https://git-scm.com/)
- Убедитесь, что Git Bash доступен в PATH

## 🔧 Автоматическая установка зависимостей

Запустите PowerShell от имени администратора и выполните:

```powershell
# Установка Chocolatey (если не установлен)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Установка зависимостей
choco install nodejs --version=22.15.1 -y
choco install python -y
choco install git -y
```

## 🚀 Запуск сборки

### Вариант 1: Автоматическая установка + сборка
```powershell
.\setup-and-build.ps1
```

### Вариант 2: Быстрая сборка (если зависимости уже установлены)
```powershell
.\quick-build.ps1
```

### Вариант 3: Ручная сборка
```powershell
# Установка переменных окружения
$env:APP_NAME = "VSCodium"
$env:BINARY_NAME = "codium"
$env:OS_NAME = "windows"
$env:VSCODE_ARCH = "x64"  # или "arm64"
$env:VSCODE_QUALITY = "stable"
$env:CI_BUILD = "no"
$env:SHOULD_BUILD = "yes"
$env:NODE_OPTIONS = "--max-old-space-size=8192"

# Получение исходного кода и сборка
bash -c "./get_repo.sh"
bash -c "./prepare_vscode.sh"
bash -c "./build.sh"
```

## 📊 Параметры сборки

### Архитектура (`VSCODE_ARCH`)
- `x64` - для 64-битных систем (по умолчанию)
- `arm64` - для ARM64 систем

### Качество (`VSCODE_QUALITY`)
- `stable` - стабильная версия (по умолчанию)
- `insider` - предварительная версия

### Примеры запуска с параметрами
```powershell
# Сборка для ARM64
.\quick-build.ps1 -Architecture arm64

# Сборка Insider версии
.\quick-build.ps1 -Quality insider

# Сборка ARM64 Insider
.\quick-build.ps1 -Architecture arm64 -Quality insider
```

## 📁 Результаты сборки

После успешной сборки результаты будут находиться в папке:
- `VSCode-win32-x64` - для x64 архитектуры
- `VSCode-win32-arm64` - для ARM64 архитектуры

## ⚠️ Устранение неполадок

### Ошибка "node не найден"
- Убедитесь, что Node.js установлен и добавлен в PATH
- Перезапустите PowerShell после установки Node.js

### Ошибка "bash не найден"
- Установите Git for Windows
- Убедитесь, что Git Bash добавлен в PATH

### Ошибки компиляции C++
- Установите Visual Studio Build Tools с поддержкой C++
- Убедитесь, что установлены Windows SDK
- **Примечание:** Команда `npm config set msvs_version` устарела и больше не нужна - node-gyp автоматически находит Build Tools

### Недостаточно памяти
- Увеличьте значение `NODE_OPTIONS`: `$env:NODE_OPTIONS = "--max-old-space-size=16384"`
- Закройте другие приложения для освобождения RAM

### Ошибки сети
- Проверьте подключение к интернету
- Если используете корпоративную сеть, настройте прокси для npm:
  ```bash
  npm config set proxy http://proxy-server:port
  npm config set https-proxy http://proxy-server:port
  ```

## 📝 Дополнительная информация

- Время сборки: ~30-60 минут (зависит от производительности системы)
- Требуемое место на диске: ~10-15 GB
- Рекомендуемая RAM: 8+ GB

## 🔗 Полезные ссылки

- [Официальный репозиторий VSCodium](https://github.com/VSCodium/vscodium)
- [Документация по сборке VSCode](https://github.com/microsoft/vscode/wiki/How-to-Contribute)
- [Node.js Downloads](https://nodejs.org/)
- [Visual Studio Downloads](https://visualstudio.microsoft.com/downloads/)
