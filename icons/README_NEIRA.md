# Иконки Neira для VSCodium

Этот набор иконок позволяет использовать ваши собственные иконки Neira вместо стандартных иконок VSCodium.

## Структура файлов

```
icons/
├── neira/
│   ├── neira-512_page_01.svg  # Основная иконка 512x512
│   ├── neira-512_page_02.svg  # Дополнительная иконка
│   ├── neira-512_page_03.svg  # Дополнительная иконка
│   ├── neira-512_page_04.svg  # Иконка 32x32
│   └── neira-512_page_05.svg  # Дополнительная иконка
├── build_icons_neira.sh       # Скрипт сборки с поддержкой Neira
└── README_NEIRA.md           # Этот файл
```

## Использование

### На Linux/macOS

1. Сделайте скрипт исполняемым:
   ```bash
   chmod +x icons/build_icons_neira.sh
   ```

2. Запустите сборку с иконками Neira:
   ```bash
   # Стабильная версия с иконками Neira
   ./icons/build_icons_neira.sh -n
   
   # Insider версия с иконками Neira
   ./icons/build_icons_neira.sh -i -n
   
   # Показать справку
   ./icons/build_icons_neira.sh -h
   ```

### На Windows

1. Используйте Git Bash, WSL или PowerShell:
   ```bash
   # Стабильная версия с иконками Neira
   bash icons/build_icons_neira.sh -n
   
   # Insider версия с иконками Neira
   bash icons/build_icons_neira.sh -i -n
   ```

## Опции скрипта

- `-i` - Использовать insider версию (оранжевый цвет)
- `-n` - Использовать тему Neira (ваши иконки)
- `-h` - Показать справку

## Что делает скрипт

Скрипт `build_icons_neira.sh` автоматически:

1. **macOS**: Создает `.icns` файлы для различных размеров иконок
2. **Linux**: Генерирует PNG иконки для Linux
3. **Windows**: Создает `.ico` файлы и различные размеры для установщика
4. **Сервер**: Генерирует favicon и веб-иконки
5. **Медиа**: Обновляет SVG иконки для веб-интерфейса

## Маппинг иконок

Скрипт автоматически выбирает подходящую иконку Neira в зависимости от размера:

- **512px и больше**: `neira-512_page_01.svg`
- **128px**: `neira-512_page_02.svg`
- **32px**: `neira-512_page_04.svg`
- **Остальные размеры**: `neira-512_page_01.svg`

## Требования

Для работы скрипта требуются следующие утилиты:
- `rsvg-convert` - для конвертации SVG в PNG
- `convert` и `composite` - из ImageMagick
- `icns2png` и `png2icns` - для работы с macOS иконками
- `icotool` - для работы с Windows иконками
- `sed` - для редактирования файлов

## Установка зависимостей

### Ubuntu/Debian:
```bash
sudo apt-get install librsvg2-bin imagemagick icnsutils icoutils sed
```

### macOS:
```bash
brew install librsvg imagemagick icnsutils icoutils gnu-sed
```

### Windows:
Установите через WSL или используйте готовые бинарные файлы.

## Интеграция в процесс сборки

Чтобы интегрировать иконки Neira в основной процесс сборки VSCodium, вы можете:

1. Заменить оригинальный `build_icons.sh` на `build_icons_neira.sh`
2. Или добавить вызов `build_icons_neira.sh` в основной скрипт сборки

## Кастомизация

Для изменения маппинга иконок отредактируйте функцию `get_icon_path()` в скрипте `build_icons_neira.sh`.

## Поддержка

Если у вас возникли проблемы:
1. Убедитесь, что все зависимости установлены
2. Проверьте, что SVG файлы корректны
3. Запустите скрипт с опцией `-h` для получения справки 