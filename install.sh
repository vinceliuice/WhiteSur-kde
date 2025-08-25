#! /usr/bin/env bash

ROOT_UID=0

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  AURORAE_DIR="/usr/share/aurorae/themes"
  SCHEMES_DIR="/usr/share/color-schemes"
  PLASMA_DIR="/usr/share/plasma/desktoptheme"
  LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"
  KVANTUM_DIR="/usr/share/Kvantum"
  WALLPAPER_DIR="/usr/share/wallpapers"
else
  AURORAE_DIR="$HOME/.local/share/aurorae/themes"
  SCHEMES_DIR="$HOME/.local/share/color-schemes"
  PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
  LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
  KVANTUM_DIR="$HOME/.config/Kvantum"
  WALLPAPER_DIR="$HOME/.local/share/wallpapers"
fi

SRC_DIR=$(cd $(dirname $0) && pwd)

THEME_NAME=WhiteSur
LATTE_DIR="$HOME/.config/latte"

COLOR_VARIANTS=('' '-dark')
PCOLOR_VARIANTS=('' '-alt' '-dark')
WINDOW_VARIANTS=('' '-opaque' '-sharp')
SCALE_VARIANTS=('' '_x1.25' '_x1.5' '_x1.75' '_x2.0')

usage() {
  cat << EOF
Usage: $0 [OPTION]...

OPTIONS:
  -n, --name NAME         Specify theme name (Default: $THEME_NAME)
  -c, --color VARIANT     Specify color variant(s) [light|alt|dark] (Default: All variants)s)
  -w, --window VARIANT    Specify window variant(s) [default|opaque|sharp] (Default: round blur version)
  -h, --help              Show help
EOF
}

[[ ! -d "${AURORAE_DIR}" ]] && mkdir -p "${AURORAE_DIR}"
[[ ! -d "${SCHEMES_DIR}" ]] && mkdir -p "${SCHEMES_DIR}"
[[ ! -d "${PLASMA_DIR}" ]] && mkdir -p "${PLASMA_DIR}"
[[ ! -d "${LOOKFEEL_DIR}" ]] && mkdir -p "${LOOKFEEL_DIR}"
[[ ! -d "${KVANTUM_DIR}" ]] && mkdir -p "${KVANTUM_DIR}"
[[ ! -d "${WALLPAPER_DIR}" ]] && mkdir -p "${WALLPAPER_DIR}"

# cp -rf "${SRC_DIR}"/configs/Xresources "$HOME"/.Xresources

install() {
  local name="${1}"
  local color="${2}"

  [[ "${color}" == '-dark' ]] && local ELSE_COLOR='Dark'
  [[ "${color}" == '-light' ]] && local ELSE_COLOR='Light'

  [[ -d "${KVANTUM_DIR}/${name}" ]] && rm -rf "${KVANTUM_DIR}/${name}"
  [[ -d "${WALLPAPER_DIR}/${name}" ]] && rm -rf "${WALLPAPER_DIR}/${name}"*
  [[ -f "${LATTE_DIR}/${name}.layout.latte" ]] && rm -rf "${LATTE_DIR}/${name}*.layout.latte"

  cp -r "${SRC_DIR}/Kvantum/${name}"                                                   "${KVANTUM_DIR}"

  if [[ "${opaque}" == "true" ]]; then
    cp -r "${SRC_DIR}/Kvantum/${name}-opaque"                                          "${KVANTUM_DIR}"
  fi

  cp -r "${SRC_DIR}/wallpaper/${name}"*                                                "${WALLPAPER_DIR}"
  [[ -d "${LATTE_DIR}" ]] && cp -r "${SRC_DIR}/latte-dock/"*                           "${LATTE_DIR}"
}

install_plasma() {
  local name="${1}"
  local pcolor="${2}"

  [[ "${pcolor}" == '-dark' ]] && local ELSE_COLOR='Dark'
  [[ "${pcolor}" == '-light' ]] && local ELSE_COLOR='Light'
  [[ "${pcolor}" == '-alt' ]] && local ELSE_COLOR='Alt'

  [[ -d "${PLASMA_DIR}/${name}${pcolor}" ]] && rm -rf "${PLASMA_DIR}/${name}${pcolor}"
  [[ -f "${SCHEMES_DIR}/${name}${ELSE_COLOR}.colors" ]] && rm -rf "${SCHEMES_DIR}/${name}${ELSE_COLOR}.colors"
  [[ -d "${LOOKFEEL_DIR}/com.github.vinceliuice.${name}${pcolor}" ]] && rm -rf "${LOOKFEEL_DIR}/com.github.vinceliuice.${name}${pcolor}"

  cp -r "${SRC_DIR}/color-schemes/"*                                                   "${SCHEMES_DIR}"
  cp -r "${SRC_DIR}/plasma/desktoptheme/${name}${pcolor}"                              "${PLASMA_DIR}"
  cp -r "${SRC_DIR}/plasma/desktoptheme/"{icons,weather}                               "${PLASMA_DIR}/${name}${pcolor}"
  cp -r "${SRC_DIR}/plasma/look-and-feel/com.github.vinceliuice.${name}${pcolor}"      "${LOOKFEEL_DIR}"
}

install_aurorae() {
  local name="${1}"
  local color="${2}"
  local window="${3}"
  local scale="${4}"

  local AURORAE_THEME="${AURORAE_DIR}/${name}${color}${window}${scale}"

  [[ -d "${AURORAE_THEME}" ]] && rm -rf "${AURORAE_THEME}"

  cp -r "${SRC_DIR}/aurorae/main${window}/${name}${color}${window}${scale}"          "${AURORAE_THEME}"
  cp -r "${SRC_DIR}/aurorae/common/assets${color}/"*.svg                             "${AURORAE_THEME}"

  cp -r "${SRC_DIR}/aurorae/"{metadata.desktop,metadata.json}                        "${AURORAE_THEME}"
  cp -r "${SRC_DIR}/aurorae/main${window}/${name}${color}${window}rc"                "${AURORAE_THEME}/${name}${color}${window}${scale}rc"

  sed -i "s/WhiteSur/${name}${color}${window}${scale}/g" "${AURORAE_THEME}/metadata.desktop" "${AURORAE_THEME}/metadata.json"
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -n|--name)
      name="${1}"
      shift
      ;;
    -c|--color)
      shift
      for pcolor in "$@"; do
        case "$pcolor" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            pcolors+=("${PCOLOR_VARIANTS[0]}")
            shift
            ;;
          alt)
            colors+=("${COLOR_VARIANTS[0]}")
            pcolors+=("${PCOLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            pcolors+=("${PCOLOR_VARIANTS[2]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo -e "ERROR: Unrecognized color variant '$1'."
            echo -e "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -w|--window)
      shift
      for window in "$@"; do
        case "$window" in
          default)
            windows+=("${WINDOW_VARIANTS[0]}")
            shift
            ;;
          opaque)
            windows+=("${WINDOW_VARIANTS[1]}")
            opaque='true'
            echo -e "Install opaque theme version."
            shift
            ;;
          sharp)
            windows+=("${WINDOW_VARIANTS[2]}")
            sharp='true'
            echo -e "Install sharp theme version."
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo -e "ERROR: Unrecognized color variant '$1'."
            echo -e "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "ERROR: Unrecognized installation option '$1'."
      echo -e "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

echo -e "Installing '${THEME_NAME} kde themes'..."

for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
  install "${name:-${THEME_NAME}}" "${color}"
done

for pcolor in "${pcolors[@]:-${PCOLOR_VARIANTS[@]}}"; do
  install_plasma "${name:-${THEME_NAME}}" "${pcolor}"
done

for color in "${colors[@]:-${COLOR_VARIANTS[@]}}"; do
  for window in "${windows[@]:-${WINDOW_VARIANTS[0]}}"; do
    for scale in "${scales[@]:-${SCALE_VARIANTS[@]}}"; do
      install_aurorae "${name:-${THEME_NAME}}" "${color}" "${window}" "${scale}"
    done
  done
done

echo -e "Install finished..."
