# План исправления устаревшей команды npm config set msvs_version

**Дата создания:** 26 июля 2025  
**Проблема:** Команда `npm config set msvs_version` устарела и была удалена в последних версиях npm

## 📋 Чеклист задач

- [x] Обновить WINDOWS-BUILD-GUIDE.md - удалить упоминания устаревшей команды
- [x] Обновить docs/BUILD-GUIDE-RU.md - добавить информацию о автоматическом определении Visual Studio Build Tools
- [x] Обновить docs/FAQ-RU.md - добавить FAQ о проблемах с msvs_version
- [x] Обновить docs/CHEATSHEET-RU.md - убрать устаревшие команды
- [x] Проверить все скрипты сборки на наличие устаревших команд
- [x] Добавить информацию о том, что node-gyp автоматически находит Build Tools
- [x] Создать отчет о завершении исправления

## 🔧 Что нужно изменить

### WINDOWS-BUILD-GUIDE.md
- **Путь:** `WINDOWS-BUILD-GUIDE.md`
- **Изменения:** Удалить упоминания команды `npm config set msvs_version`, добавить информацию о автоматическом определении

### docs/BUILD-GUIDE-RU.md  
- **Путь:** `docs/BUILD-GUIDE-RU.md`
- **Изменения:** Добавить раздел о том, что node-gyp автоматически находит Visual Studio Build Tools

### docs/FAQ-RU.md
- **Путь:** `docs/FAQ-RU.md`
- **Изменения:** Добавить FAQ о том, что делать если появляется ошибка с msvs_version

### docs/CHEATSHEET-RU.md
- **Путь:** `docs/CHEATSHEET-RU.md`
- **Изменения:** Убрать устаревшие команды настройки msvs_version

## 📝 Примечания

- node-gyp теперь автоматически находит установленные версии Visual Studio Build Tools
- Команда `npm config set msvs_version` больше не нужна
- Пользователи должны просто убедиться, что установлены Build Tools с поддержкой C++ 