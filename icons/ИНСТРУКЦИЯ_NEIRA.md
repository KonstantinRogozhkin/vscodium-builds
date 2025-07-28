# 🎨 Инструкция по использованию иконок Neira для VSCodium

## 📋 Что у вас есть

У вас есть набор SVG иконок Neira в папке `icons/neira/`:
- `neira-512_page_01.svg` (757KB) - основная иконка 512x512
- `neira-512_page_02.svg` (177KB) - дополнительная иконка  
- `neira-512_page_03.svg` (36KB) - дополнительная иконка
- `neira-512_page_04.svg` (616B) - иконка 32x32
- `neira-512_page_05.svg` (8KB) - дополнительная иконка

## 🚀 Как использовать

### Вариант 1: Использование модифицированного скрипта

1. **Установите зависимости** (если еще не установлены):
   ```bash
   # Ubuntu/Debian
   sudo apt-get install librsvg2-bin imagemagick icnsutils icoutils sed
   
   # macOS
   brew install librsvg imagemagick icnsutils icoutils gnu-sed
   
   # Windows (через WSL или Git Bash)
   # Установите те же пакеты в WSL
   ```

2. **Запустите сборку с иконками Neira**:
   ```bash
   # Стабильная версия с иконками Neira
   bash icons/build_icons_neira.sh -n
   
   # Insider версия с иконками Neira  
   bash icons/build_icons_neira.sh -i -n
   
   # Показать справку
   bash icons/build_icons_neira.sh -h
   ```

### Вариант 2: Замена в основном скрипте

1. **Сделайте резервную копию** оригинального скрипта:
   ```bash
   cp icons/build_icons.sh icons/build_icons_backup.sh
   ```

2. **Замените оригинальный скрипт** на версию с поддержкой Neira:
   ```bash
   cp icons/build_icons_neira.sh icons/build_icons.sh
   ```

3. **Теперь при обычной сборке** будут использоваться иконки Neira:
   ```bash
   bash icons/build_icons.sh
   ```

## 🔧 Опции скрипта

- `-i` - Использовать insider версию (оранжевый цвет)
- `-n` - Использовать тему Neira (ваши иконки)
- `-h` - Показать справку

## 📁 Что создает скрипт

Скрипт автоматически создает иконки для всех платформ:

### macOS
- `code.icns` - основной файл иконки
- Различные размеры для разных контекстов

### Linux  
- `code.png` - основная иконка
- `code.xpm` - для RPM пакетов

### Windows
- `code.ico` - основной файл иконки
- Различные размеры для установщика
- BMP файлы для Inno Setup

### Сервер
- `favicon.ico` - для веб-интерфейса
- `code-192.png` и `code-512.png` - для PWA

## 🎯 Маппинг иконок

Скрипт автоматически выбирает подходящую иконку:

| Размер | Используемый файл |
|--------|-------------------|
| 512px+ | `neira-512_page_01.svg` |
| 128px  | `neira-512_page_02.svg` |
| 32px   | `neira-512_page_04.svg` |
| Остальные | `neira-512_page_01.svg` |

## 🛠️ Устранение проблем

### Проблема: "rsvg-convert не найден"
**Решение**: Установите librsvg2-bin
```bash
sudo apt-get install librsvg2-bin  # Ubuntu/Debian
brew install librsvg               # macOS
```

### Проблема: "convert не найден"  
**Решение**: Установите ImageMagick
```bash
sudo apt-get install imagemagick  # Ubuntu/Debian
brew install imagemagick          # macOS
```

### Проблема: "icns2png не найден"
**Решение**: Установите icnsutils
```bash
sudo apt-get install icnsutils    # Ubuntu/Debian
brew install icnsutils            # macOS
```

### Проблема: SVG файлы не конвертируются
**Решение**: Проверьте, что SVG файлы корректны
```bash
# Тест конвертации
rsvg-convert -w 64 -h 64 icons/neira/neira-512_page_04.svg -o test.png
```

## 🔄 Интеграция в процесс сборки

Чтобы автоматически использовать иконки Neira при каждой сборке:

1. **Добавьте в основной скрипт сборки**:
   ```bash
   # В начале скрипта сборки VSCodium
   export THEME="neira"
   bash icons/build_icons_neira.sh -n
   ```

2. **Или создайте алиас**:
   ```bash
   alias build-vscodium-neira='THEME=neira bash icons/build_icons_neira.sh -n && # остальные команды сборки'
   ```

## 📝 Кастомизация

### Изменить маппинг иконок
Отредактируйте функцию `get_icon_path()` в `build_icons_neira.sh`:

```bash
get_icon_path() {
  local icon_name="$1"
  local size="$2"
  
  if [[ "${THEME}" == "neira" ]]; then
    case "${size}" in
      "512")
        echo "icons/neira/ВАША_ИКОНКА.svg"  # Измените здесь
        ;;
      # ... остальные размеры
    esac
  fi
}
```

### Добавить новые размеры
Добавьте новые case в функцию `get_icon_path()`.

## 🎉 Результат

После успешного выполнения скрипта у вас будет VSCodium с вашими уникальными иконками Neira на всех платформах!

---

**Примечание**: Убедитесь, что у вас есть права на использование иконок Neira в вашем проекте. 