# Исправление ошибки "отсутствуют Spectre-mitigated libraries" в Visual Studio Build Tools

## Описание проблемы

При сборке VSCodium на Windows может возникнуть ошибка, связанная с отсутствием Spectre-mitigated libraries в Visual Studio Build Tools. Эта ошибка обычно появляется в виде:

```
error: Visual Studio Build Tools - отсутствуют Spectre-mitigated libraries
```

или

```
error: Spectre-mitigated libraries not found
```

## Причина проблемы

Spectre-mitigated libraries - это специальные библиотеки Microsoft Visual C++, которые защищают от уязвимостей Spectre. Эти библиотеки не устанавливаются по умолчанию при установке Visual Studio Build Tools и должны быть добавлены отдельно.

## Решения

### Решение 1: Автоматическая установка через PowerShell скрипт

1. Запустите PowerShell от имени администратора
2. Перейдите в папку проекта VSCodium
3. Выполните команду:

```powershell
powershell -ExecutionPolicy ByPass -File .\scripts\install-vs-buildtools.ps1
```

Этот скрипт автоматически:
- Скачает и установит Visual Studio Build Tools 2022
- Добавит все необходимые компоненты включая Spectre-mitigated libraries
- Настроит переменные окружения
- Проверит корректность установки

### Решение 2: Ручная установка через Visual Studio Installer

1. Скачайте Visual Studio Build Tools 2022:
   - Перейдите на https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
   - Скачайте "Build Tools for Visual Studio 2022"

2. Запустите установщик от имени администратора

3. В установщике выберите следующие компоненты:
   - **C++ build tools** (основной компонент)
   - **Windows 10/11 SDK** (версии 19041, 20348, 22621)
   - **Spectre-mitigated libraries** для всех архитектур:
     - x86/x64 Spectre-mitigated libraries
     - ARM64 Spectre-mitigated libraries
     - ARM64EC Spectre-mitigated libraries

4. Нажмите "Install" и дождитесь завершения установки

### Решение 3: Установка через winget

```powershell
winget install Microsoft.VisualStudio.2022.BuildTools
```

После установки через winget может потребоваться дополнительная установка Spectre-mitigated libraries через Visual Studio Installer.

### Решение 4: Модификация существующей установки

Если Visual Studio Build Tools уже установлен:

1. Откройте "Visual Studio Installer"
2. Найдите установленный "Build Tools for Visual Studio 2022"
3. Нажмите "Modify"
4. Добавьте недостающие компоненты:
   - Microsoft.VisualStudio.Component.VC.Tools.x86.x64.Spectre
   - Microsoft.VisualStudio.Component.VC.Tools.ARM64.Spectre
   - Microsoft.VisualStudio.Component.VC.Tools.ARM64EC.Spectre
5. Нажмите "Modify" для применения изменений

## Проверка установки

После установки проверьте наличие Spectre-mitigated libraries:

```powershell
# Проверка наличия библиотек
$spectrePaths = @(
    "C:\BuildTools\VC\Tools\MSVC\*\lib\x64\spectre",
    "C:\BuildTools\VC\Tools\MSVC\*\lib\x86\spectre",
    "C:\BuildTools\VC\Tools\MSVC\*\lib\arm64\spectre"
)

foreach ($path in $spectrePaths) {
    if (Test-Path $path) {
        Write-Host "✓ Найдены: $path" -ForegroundColor Green
    } else {
        Write-Host "✗ Не найдены: $path" -ForegroundColor Red
    }
}
```

## Альтернативные пути установки

Если стандартная установка в `C:\BuildTools` не подходит, Visual Studio может быть установлен в:

- `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools`
- `C:\Program Files\Microsoft Visual Studio\2022\BuildTools`

В этом случае обновите пути в скриптах соответственно.

## Переменные окружения

После установки убедитесь, что следующие переменные окружения настроены:

```powershell
# Добавьте в PATH пути к Visual Studio Build Tools
$env:PATH += ";C:\BuildTools\VC\Tools\MSVC\*\bin\Hostx64\x64"
$env:PATH += ";C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin"
$env:PATH += ";C:\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja"
```

## Устранение неполадок

### Ошибка "Access Denied"
- Запустите PowerShell от имени администратора
- Убедитесь, что антивирус не блокирует установку

### Ошибка "Download failed"
- Проверьте подключение к интернету
- Попробуйте использовать VPN
- Скачайте установщик вручную с официального сайта

### Ошибка "Installation failed"
- Удалите существующую установку Visual Studio Build Tools
- Очистите временные файлы: `%TEMP%` и `%TMP%`
- Перезагрузите компьютер
- Попробуйте установку заново

### Ошибка "Spectre libraries still not found"
- Убедитесь, что установлены именно Spectre-mitigated libraries, а не обычные
- Проверьте версию MSVC (должна быть 14.29 или новее)
- Перезапустите PowerShell после установки

## Дополнительные ресурсы

- [Документация Microsoft по Spectre-mitigated libraries](https://docs.microsoft.com/en-us/cpp/build/reference/qspectre)
- [Visual Studio Build Tools документация](https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools)
- [VSCodium build documentation](https://github.com/VSCodium/vscodium/blob/master/docs/build.md)

## Поддержка

Если проблема не решается, создайте issue в репозитории VSCodium с подробным описанием:
- Версия Windows
- Версия Visual Studio Build Tools
- Полный текст ошибки
- Логи установки 