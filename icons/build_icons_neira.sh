#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

# DEBUG
# set -o xtrace

QUALITY="stable"
COLOR="blue1"
THEME="neira"  # Новая переменная для выбора темы

while getopts ":i:n" opt; do
  case "$opt" in
    i)
      export QUALITY="insider"
      export COLOR="orange1"
      ;;
    n)
      export THEME="neira"
      ;;
    *)
      ;;
  esac
done

check_programs() { # {{{
  for arg in "$@"; do
    if ! command -v "${arg}" &> /dev/null; then
      echo "${arg} could not be found"
      exit 0
    fi
  done
} # }}}

check_programs "icns2png" "composite" "convert" "png2icns" "icotool" "rsvg-convert" "sed"

. ./utils.sh

SRC_PREFIX=""
VSCODE_PREFIX=""

# Функция для получения пути к иконке в зависимости от темы
get_icon_path() {
  local icon_name="$1"
  local size="$2"
  
  if [[ "${THEME}" == "neira" ]]; then
    case "${size}" in
      "512")
        echo "icons/neira/neira-512_page_01.svg"
        ;;
      "32")
        echo "icons/neira/neira-512_page_04.svg"
        ;;
      "128")
        echo "icons/neira/neira-512_page_02.svg"
        ;;
      *)
        echo "icons/neira/neira-512_page_01.svg"
        ;;
    esac
  else
    # Используем стандартные иконки VSCodium
    echo "icons/${QUALITY}/${icon_name}"
  fi
}

build_darwin_main() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns" ]]; then
    if [[ "${THEME}" == "neira" ]]; then
      # Используем готовую иконку Neira для macOS
      cp "icons/neira/neira-512.icns" "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns"
      echo "Использована готовая иконка Neira для macOS"
    else
      # Стандартная генерация для других тем
      local icon_path
      icon_path=$(get_icon_path "codium_cnl.svg" "512")
      
      rsvg-convert -w 800 -h 800 "${icon_path}" -o "code_logo.png"
      composite "code_logo.png" -gravity center "icons/template_macos.png" "code_1024.png"
      convert "code_1024.png" -resize 512x512 code_512.png
      convert "code_1024.png" -resize 256x256 code_256.png
      convert "code_1024.png" -resize 128x128 code_128.png

      png2icns "${SRC_PREFIX}src/${QUALITY}/resources/darwin/code.icns" code_512.png code_256.png code_128.png

      rm code_1024.png code_512.png code_256.png code_128.png code_logo.png
    fi
  fi
} # }}}

build_darwin_types() { # {{{
  local icon_path
  icon_path=$(get_icon_path "codium_cnl_w80_b8.svg" "128")
  
  rsvg-convert -w 128 -h 128 "${icon_path}" -o "code_logo.png"

  for file in "${VSCODE_PREFIX}"vscode/resources/darwin/*; do
    if [[ -f "${file}" ]]; then
      name=$(basename "${file}" '.icns')

      if [[ "${name}" != 'code' ]] && [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/darwin/${name}.icns" ]]; then
        icns2png -x -s 512x512 "${file}" -o .

        composite -blend 100% -geometry +323+365 "icons/corner_512.png" "${name}_512x512x32.png" "${name}.png"
        composite -geometry +359+374 "code_logo.png" "${name}.png" "${name}.png"

        convert "${name}.png" -resize 256x256 "${name}_256.png"

        png2icns "${SRC_PREFIX}src/${QUALITY}/resources/darwin/${name}.icns" "${name}.png" "${name}_256.png"

        rm "${name}_512x512x32.png" "${name}.png" "${name}_256.png"
      fi
    fi
  done

  rm "code_logo.png"
} # }}}

build_linux_main() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" ]]; then
    if [[ "${THEME}" == "neira" ]]; then
      # Используем иконку Neira для Linux
      local icon_path
      icon_path=$(get_icon_path "codium_cnl.svg" "512")
      rsvg-convert -w 512 -h 512 "${icon_path}" -o "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png"
    else
      # Используем стандартную иконку
      wget "https://raw.githubusercontent.com/VSCodium/icons/main/icons/linux/circle1/${COLOR}/paulo22s.png" -O "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png"
    fi
  fi

  mkdir -p "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm"

  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm/code.xpm" ]]; then
    convert "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/linux/rpm/code.xpm"
  fi
} # }}}

build_media() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg" ]]; then
    local icon_path
    icon_path=$(get_icon_path "codium_clt.svg" "512")
    cp "${icon_path}" "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg"
    gsed -i 's|width="100" height="100"|width="1024" height="1024"|' "${SRC_PREFIX}src/${QUALITY}/src/vs/workbench/browser/media/code-icon.svg"
  fi
} # }}}

build_server() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/server/favicon.ico" ]]; then
    if [[ "${THEME}" == "neira" ]]; then
      # Создаем favicon.ico из иконки Neira
      local icon_path
      icon_path=$(get_icon_path "codium_cnl.svg" "32")
      rsvg-convert -w 32 -h 32 "${icon_path}" -o "favicon_temp.png"
      convert "favicon_temp.png" "${SRC_PREFIX}src/${QUALITY}/resources/server/favicon.ico"
      rm "favicon_temp.png"
    else
      wget "https://raw.githubusercontent.com/VSCodium/icons/main/icons/win32/nobg/${COLOR}/paulo22s.ico" -O "${SRC_PREFIX}src/${QUALITY}/resources/server/favicon.ico"
    fi
  fi

  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/server/code-192.png" ]]; then
    convert -size "192x192" "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/server/code-192.png"
  fi

  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/server/code-512.png" ]]; then
    convert -size "512x512" "${SRC_PREFIX}src/${QUALITY}/resources/linux/code.png" "${SRC_PREFIX}src/${QUALITY}/resources/server/code-512.png"
  fi
} # }}}

build_windows_main() { # {{{
  if [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico" ]]; then
    if [[ "${THEME}" == "neira" ]]; then
      # Создаем ICO файл из иконки Neira
      local icon_path
      icon_path=$(get_icon_path "codium_cnl.svg" "512")
      rsvg-convert -w 256 -h 256 "${icon_path}" -o "code_256_temp.png"
      rsvg-convert -w 128 -h 128 "${icon_path}" -o "code_128_temp.png"
      rsvg-convert -w 64 -h 64 "${icon_path}" -o "code_64_temp.png"
      rsvg-convert -w 32 -h 32 "${icon_path}" -o "code_32_temp.png"
      rsvg-convert -w 16 -h 16 "${icon_path}" -o "code_16_temp.png"
      
      convert code_256_temp.png code_128_temp.png code_64_temp.png code_32_temp.png code_16_temp.png "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico"
      
      rm code_256_temp.png code_128_temp.png code_64_temp.png code_32_temp.png code_16_temp.png
    else
      wget "https://raw.githubusercontent.com/VSCodium/icons/main/icons/win32/nobg/${COLOR}/paulo22s.ico" -O "${SRC_PREFIX}src/${QUALITY}/resources/win32/code.ico"
    fi
  fi
} # }}}

build_windows_type() { # {{{
  local FILE_PATH IMG_SIZE IMG_BG_COLOR LOGO_SIZE GRAVITY

  FILE_PATH="$1"
  IMG_SIZE="$2"
  IMG_BG_COLOR="$3"
  LOGO_SIZE="$4"
  GRAVITY="$5"

  if [[ ! -f "${FILE_PATH}" ]]; then
    if [[ "${FILE_PATH##*.}" == "png" ]]; then
      convert -size "${IMG_SIZE}" "${IMG_BG_COLOR}" PNG32:"${FILE_PATH}"
    else
      convert -size "${IMG_SIZE}" "${IMG_BG_COLOR}" "${FILE_PATH}"
    fi

    local icon_path
    icon_path=$(get_icon_path "codium_cnl.svg" "64")
    rsvg-convert -w "${LOGO_SIZE}" -h "${LOGO_SIZE}" "${icon_path}" -o "code_logo.png"

    composite -gravity "${GRAVITY}" "code_logo.png" "${FILE_PATH}" "${FILE_PATH}"
  fi
} # }}}

build_windows_types() { # {{{
  mkdir -p "${SRC_PREFIX}src/${QUALITY}/resources/win32"

  local icon_path
  icon_path=$(get_icon_path "codium_cnl.svg" "64")
  rsvg-convert -b "#F5F6F7" -w 64 -h 64 "${icon_path}" -o "code_logo.png"

  for file in "${VSCODE_PREFIX}"vscode/resources/win32/*.ico; do
    if [[ -f "${file}" ]]; then
      name=$(basename "${file}" '.ico')

      if [[ "${name}" != 'code' ]] && [[ ! -f "${SRC_PREFIX}src/${QUALITY}/resources/win32/${name}.ico" ]]; then
        icotool -x -w 256 "${file}"

        composite -geometry +150+185 "code_logo.png" "${name}_9_256x256x32.png" "${name}.png"

        convert "${name}.png" -define icon:auto-resize=256,128,96,64,48,32,24,20,16 "${SRC_PREFIX}src/${QUALITY}/resources/win32/${name}.ico"

        rm "${name}_9_256x256x32.png" "${name}.png"
      fi
    fi
  done

  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_70x70.png" "70x70" "canvas:transparent" "45" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/code_150x150.png" "150x150" "canvas:transparent" "64" "+44+25"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-100.bmp" "164x314" "xc:white" "126" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-125.bmp" "192x386" "xc:white" "147" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-150.bmp" "246x459" "xc:white" "190" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-175.bmp" "273x556" "xc:white" "211" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-200.bmp" "328x604" "xc:white" "255" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-225.bmp" "355x700" "xc:white" "273" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-big-250.bmp" "410x797" "xc:white" "317" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-100.bmp" "55x55" "xc:white" "44" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-125.bmp" "64x68" "xc:white" "52" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-150.bmp" "83x80" "xc:white" "63" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-175.bmp" "92x97" "xc:white" "76" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-200.bmp" "110x106" "xc:white" "86" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-225.bmp" "119x123" "xc:white" "103" "center"
  build_windows_type "${SRC_PREFIX}src/${QUALITY}/resources/win32/inno-small-250.bmp" "138x140" "xc:white" "116" "center"
  build_windows_type "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-banner.bmp" "493x58" "xc:white" "50" "+438+6"
  build_windows_type "${SRC_PREFIX}build/windows/msi/resources/${QUALITY}/wix-dialog.bmp" "493x312" "xc:white" "120" "+22+152"

  rm code_logo.png
} # }}}

# Функция для показа справки
show_help() {
  echo "Использование: $0 [опции]"
  echo ""
  echo "Опции:"
  echo "  -i    Использовать insider версию (оранжевый цвет)"
  echo "  -n    Использовать тему Neira (ваши иконки)"
  echo "  -h    Показать эту справку"
  echo ""
  echo "Примеры:"
  echo "  $0              # Стабильная версия с стандартными иконками"
  echo "  $0 -i           # Insider версия с стандартными иконками"
  echo "  $0 -n           # Стабильная версия с иконками Neira"
  echo "  $0 -i -n        # Insider версия с иконками Neira"
}

# Обработка опции -h
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "Сборка иконок для VSCodium с темой: ${THEME}"
  echo "Качество: ${QUALITY}"
  echo "Цвет: ${COLOR}"
  echo ""
  
  build_darwin_main
  build_linux_main
  build_windows_main

  build_darwin_types
  build_windows_types

  build_media
  build_server
  
  echo "Сборка иконок завершена!"
fi 