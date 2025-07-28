# ❓ Часто задаваемые вопросы (FAQ)

> Ответы на самые популярные вопросы по сборке и использованию VSCodium

## 📋 Содержание

- [Общие вопросы](#общие-вопросы)
- [Сборка и установка](#сборка-и-установка)
- [GitHub Actions](#github-actions)
- [Проблемы и ошибки](#проблемы-и-ошибки)
- [Производительность](#производительность)
- [Кастомизация](#кастомизация)

## 🤔 Общие вопросы

### В чем разница между VS Code и VSCodium?

**VS Code** - официальная версия от Microsoft с телеметрией и проприетарными компонентами.

**VSCodium** - сборка с открытым исходным кодом без:
- ❌ Телеметрии Microsoft
- ❌ Отслеживания пользователей
- ❌ Проприетарных расширений
- ✅ Полная функциональность VS Code
- ✅ Открытый исходный код
- ✅ Приватность

### Зачем собирать VSCodium самостоятельно?

1. **Контроль над процессом** - вы знаете, что именно собираете
2. **Кастомизация** - можете добавить свои патчи и изменения
3. **Последние версии** - получаете обновления сразу после выхода
4. **Обучение** - понимаете, как устроена сборка сложных проектов
5. **Доверие** - собираете из проверенного исходного кода

### Можно ли использовать расширения из VS Code Marketplace?

**Да!** VSCodium по умолчанию настроен на использование официального Marketplace VS Code. Все расширения работают без проблем.

### Совместимы ли настройки VS Code с VSCodium?

**Да!** Вы можете:
- Импортировать настройки из VS Code
- Использовать те же расширения
- Синхронизировать настройки через GitHub/Microsoft аккаунт

## 🏗️ Сборка и установка

### Сколько времени занимает сборка?

| Этап | Время |
|------|-------|
| **Компиляция** | 15-25 минут |
| **Создание пакетов** | 10-15 минут |
| **Общее время** | **25-40 минут** |

*Время зависит от мощности процессора и скорости интернета.*

### Сколько места нужно для сборки?

| Компонент | Размер |
|-----------|--------|
| **Исходный код** | ~500 МБ |
| **node_modules** | ~2-3 ГБ |
| **Сборка** | ~1-2 ГБ |
| **Общий объем** | **~4-6 ГБ** |

### Какие системные требования для сборки?

#### Минимальные
- **ОЗУ**: 4 ГБ
- **Диск**: 8 ГБ свободного места
- **Процессор**: 2 ядра

#### Рекомендуемые
- **ОЗУ**: 8 ГБ+
- **Диск**: 16 ГБ+ (SSD предпочтительно)
- **Процессор**: 4+ ядра

### Можно ли собрать на слабом компьютере?

**Да, но с ограничениями:**

```bash
# Уменьшение использования памяти
export NODE_OPTIONS="--max-old-space-size=4096"

# Последовательная сборка (медленнее, но меньше ресурсов)
export MAKEFLAGS="-j1"

# Отключение ненужных компонентов
export SHOULD_BUILD_REH="no"
export SHOULD_BUILD_REH_WEB="no"
```

### Как обновить VSCodium до новой версии?

#### Автоматически через GitHub Actions
1. Новые версии VS Code автоматически отслеживаются
2. Сборка запускается при появлении обновлений
3. Скачайте новые артефакты

#### Вручную
```bash
cd vscodium-builds
git pull origin master
./dev/build.sh -l  # Использовать последнюю версию
```

## 🤖 GitHub Actions

### Почему сборка не запускается автоматически?

**Проверьте:**
1. **Actions включены** в настройках репозитория
2. **Права доступа** - репозиторий должен быть публичным или иметь GitHub Pro
3. **Workflow файлы** находятся в `.github/workflows/`
4. **Синтаксис YAML** корректен

### Как запустить сборку только для определенной архитектуры?

```bash
# Только x64
gh workflow run "Build Windows" --field vscode_arch=x64

# Только ARM64
gh workflow run "Build Windows" --field vscode_arch=arm64
```

### Можно ли запустить несколько сборок одновременно?

**Да!** GitHub Actions поддерживает параллельные сборки:

```bash
# Запуск сборок для разных платформ
gh workflow run "Manual Build" --field platform=windows --field architecture=x64 &
gh workflow run "Manual Build" --field platform=macos --field architecture=arm64 &
gh workflow run "Manual Build" --field platform=linux --field architecture=x64 &
```

### Как настроить уведомления о завершении сборки?

#### Slack
```yaml
- name: Slack Notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

#### Discord
```yaml
- name: Discord notification
  uses: Ilshidur/action-discord@master
  with:
    args: 'Сборка VSCodium завершена!'
  env:
    DISCORD_WEBHOOK: ${{ secrets.DISCORD_WEBHOOK }}
```

#### Email
```yaml
- name: Send mail
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 465
    username: ${{ secrets.MAIL_USERNAME }}
    password: ${{ secrets.MAIL_PASSWORD }}
    subject: VSCodium Build Completed
    to: your-email@example.com
    from: GitHub Actions
```

### Как сохранить артефакты дольше 90 дней?

GitHub Actions ограничивает хранение артефактов 90 днями. Для долгосрочного хранения:

#### 1. Автоматическая загрузка в облако
```yaml
- name: Upload to S3
  uses: aws-actions/configure-aws-credentials@v1
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1

- name: Sync to S3
  run: aws s3 sync ./artifacts s3://your-bucket/vscodium-builds/
```

#### 2. Создание GitHub Releases
```yaml
- name: Create Release
  uses: actions/create-release@v1
  with:
    tag_name: ${{ env.RELEASE_VERSION }}
    release_name: VSCodium ${{ env.RELEASE_VERSION }}
    draft: false
    prerelease: false
```

## 🚨 Проблемы и ошибки

### "No space left on device"

**Решения:**
```bash
# Очистка Docker кэша
docker system prune -a

# Очистка npm кэша
npm cache clean --force

# Удаление старых node_modules
find . -name "node_modules" -type d -exec rm -rf {} +

# Очистка системного кэша (macOS)
sudo purge
```

### "Python not found" или ошибки gyp

**Решения:**
```bash
# Установка правильной версии Python
# macOS
brew install python@3.11

# Windows
winget install Python.Python.3.11

# Linux
sudo apt install python3.11

# Настройка npm
npm config set python $(which python3)
export PYTHON=$(which python3)

### Ошибка "npm config set msvs_version is not a valid npm command"

**Проблема:** Команда `npm config set msvs_version` устарела и была удалена в последних версиях npm.

**Решение:**
```bash
# ❌ НЕ НУЖНО: npm config set msvs_version 2019
# ✅ ПРАВИЛЬНО: node-gyp автоматически находит Build Tools

# Убедитесь, что установлены Visual Studio Build Tools с поддержкой C++
# Проверьте, что установлена рабочая нагрузка "Desktop development with C++"
# Перезапустите терминал и попробуйте сборку снова
```
```

### Ошибки компиляции TypeScript

**Решения:**
```bash
# Очистка и переустановка зависимостей
rm -rf node_modules package-lock.json
npm install

# Проверка версии Node.js
node --version  # Должно быть 22.15.1+

# Увеличение памяти
export NODE_OPTIONS="--max-old-space-size=8192"
```

### "Permission denied" при сборке

**macOS/Linux:**
```bash
# Права на выполнение скриптов
chmod +x dev/build.sh
chmod +x *.sh

# Права на директории
sudo chown -R $(whoami) .
```

**Windows:**
```powershell
# Запуск PowerShell от администратора
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Сборка зависает на определенном этапе

**Диагностика:**
```bash
# Запуск с подробным выводом
DEBUG=1 ./dev/build.sh

# Мониторинг процессов
top -p $(pgrep node)

# Проверка сетевых подключений
netstat -an | grep :443
```

**Решения:**
```bash
# Перезапуск с очисткой
rm -rf vscode node_modules
./get_repo.sh
./build.sh

# Использование другого зеркала npm
npm config set registry https://registry.npmmirror.com/
```

## ⚡ Производительность

### Как ускорить сборку?

#### 1. Использование SSD
- Размещайте проект на SSD диске
- Используйте tmpfs для временных файлов (Linux)

#### 2. Увеличение ресурсов
```bash
# Больше памяти для Node.js
export NODE_OPTIONS="--max-old-space-size=16384"

# Больше процессов для Make
export MAKEFLAGS="-j$(nproc)"

# Использование всех ядер CPU
export UV_THREADPOOL_SIZE=$(nproc)
```

#### 3. Кэширование
```bash
# Сохранение node_modules между сборками
export npm_config_cache="/tmp/npm-cache"

# Использование ccache для C++
export CC="ccache gcc"
export CXX="ccache g++"
```

#### 4. Пропуск ненужных этапов
```bash
# Без Remote Extension Host
export SHOULD_BUILD_REH="no"
export SHOULD_BUILD_REH_WEB="no"

# Без тестов
export SKIP_TESTS="true"

# Пропуск загрузки исходников (если уже есть)
./dev/build.sh -s
```

### Можно ли распараллелить сборку на несколько машин?

**Да!** Используйте GitHub Actions matrix strategy:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    arch: [x64, arm64]
```

### Как мониторить использование ресурсов во время сборки?

```bash
# Создание скрипта мониторинга
#!/bin/bash
while true; do
  echo "$(date): CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}'), RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
  sleep 10
done > build-monitor.log &

# Запуск сборки
./dev/build.sh

# Остановка мониторинга
kill %1
```

## 🎨 Кастомизация

### Как изменить название и иконку VSCodium?

#### 1. Редактирование product.json
```json
{
  "nameShort": "MyVSCode",
  "nameLong": "My Custom VS Code",
  "applicationName": "mycode",
  "win32MutexName": "mycode",
  "darwinBundleIdentifier": "com.mycompany.mycode"
}
```

#### 2. Замена иконок
```bash
# Замените файлы в директории icons/
cp my-icon.png icons/stable/codium.png
cp my-icon.ico icons/stable/codium.ico
```

### Как добавить собственные расширения по умолчанию?

#### 1. Создание патча
```javascript
// src/vs/platform/extensionManagement/common/extensionManagement.ts
const DEFAULT_EXTENSIONS = [
  'ms-python.python',
  'ms-vscode.vscode-typescript-next',
  'esbenp.prettier-vscode'
];
```

#### 2. Применение патча
```bash
cd vscode
git apply ../patches/default-extensions.patch
```

### Как настроить собственный Marketplace расширений?

```json
// product.json
{
  "extensionsGallery": {
    "serviceUrl": "https://your-marketplace.com/_apis/public/gallery",
    "itemUrl": "https://your-marketplace.com/items",
    "resourceUrlTemplate": "https://your-marketplace.com/_apis/public/gallery/publishers/{publisher}/vsextensions/{name}/{version}/vspackage"
  }
}
```

### Как добавить собственные настройки по умолчанию?

```javascript
// src/vs/platform/configuration/common/configurationRegistry.ts
registerConfiguration({
  id: 'myCustomSettings',
  properties: {
    'editor.fontSize': {
      type: 'number',
      default: 14
    },
    'workbench.colorTheme': {
      type: 'string',
      default: 'Dark+'
    }
  }
});
```

### Как создать собственную тему оформления?

#### 1. Создание темы
```json
// themes/my-theme.json
{
  "name": "My Custom Theme",
  "type": "dark",
  "colors": {
    "editor.background": "#1e1e1e",
    "editor.foreground": "#d4d4d4"
  },
  "tokenColors": [...]
}
```

#### 2. Регистрация темы
```javascript
// src/vs/workbench/services/themes/browser/workbenchThemeService.ts
const builtInThemes = [
  { id: 'my-custom-theme', label: 'My Custom Theme', path: './themes/my-theme.json' }
];
```

## 🔒 Безопасность

### Безопасно ли использовать самособранный VSCodium?

**Да, если:**
- ✅ Используете официальный исходный код VSCodium
- ✅ Проверяете все патчи перед применением
- ✅ Собираете в изолированной среде
- ✅ Сканируете результат антивирусом

### Как проверить целостность сборки?

```bash
# Проверка контрольных сумм
sha256sum VSCodium-*.exe
md5sum VSCodium-*.dmg

# Сравнение с официальными сборками
diff <(strings VSCodium-official) <(strings VSCodium-custom)
```

### Нужно ли подписывать код?

**Для личного использования** - нет.

**Для распространения:**
- **Windows** - желательно (SmartScreen)
- **macOS** - обязательно (Gatekeeper)
- **Linux** - не требуется

## 📈 Мониторинг и аналитика

### Как отслеживать успешность сборок?

```bash
# Создание дашборда
#!/bin/bash
echo "📊 Статистика сборок VSCodium"
echo "=============================="

TOTAL=$(gh run list --limit=100 --json conclusion | jq '.[] | select(.conclusion != null)' | wc -l)
SUCCESS=$(gh run list --limit=100 --json conclusion | jq '.[] | select(.conclusion == "success")' | wc -l)
FAILED=$(gh run list --limit=100 --json conclusion | jq '.[] | select(.conclusion == "failure")' | wc -l)

echo "Всего сборок: $TOTAL"
echo "Успешных: $SUCCESS"
echo "Неудачных: $FAILED"
echo "Процент успеха: $((SUCCESS * 100 / TOTAL))%"
```

### Как настроить автоматические уведомления об ошибках?

```yaml
# .github/workflows/notify-on-failure.yml
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: failure
    text: "❌ Сборка VSCodium провалилась!"
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

**💡 Не нашли ответ на свой вопрос?** Создайте Issue в репозитории с тегом `question`!
