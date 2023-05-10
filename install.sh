#! /usr/bin/env bash

ROOT_UID=0
THEME_VARIANTS=('default' 'red')

usage() {
  [ -z "$1" ] || echo "
 $1"
  echo "

Usage: $0 [Options...]

Options:
  -t, --theme [default|red]
 Set theme accent color. Default is BigSur-like \"blue\" theme

  -h, --help
 Show this help
" 1>&2; exit 1;
}

set -- $(getopt --alternative --longoptions "theme:,help" --options "h,t:" -- "$@")
while [ $# -gt 0 ]; do
  case "$1" in
    -t|--theme)
      [ -z "${themes}" ] || usage "+++ theme was already defined as '${themes}'"
      eval opt_value="$2"
      for value in ${THEME_VARIANTS[*]}; do
        if [[ "${value}" == "${opt_value}" ]]; then
          opt_ok=${opt_value} && break
        fi
      done
      [ -z "${opt_ok}" ] && usage "+++ invalid theme '${opt_value}'"
      themes+=("${opt_ok}")
      shift
      ;;
    -h|--help)
      usage
      ;;
  esac
  shift
done

if [ -z "${themes[*]}" ]; then
  themes='default'
fi
echo "Theme variant    : ${themes[*]}"

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

SRC_DIR=$(cd "$(dirname "$0")" && pwd)

THEME_NAME=WhiteSur
LATTE_DIR="$HOME/.config/latte"

[[ ! -d ${AURORAE_DIR} ]] && mkdir -p "${AURORAE_DIR}"
[[ ! -d ${SCHEMES_DIR} ]] && mkdir -p "${SCHEMES_DIR}"
[[ ! -d ${PLASMA_DIR} ]] && mkdir -p "${PLASMA_DIR}"
[[ ! -d ${LOOKFEEL_DIR} ]] && mkdir -p "${LOOKFEEL_DIR}"
[[ ! -d ${KVANTUM_DIR} ]] && mkdir -p "${KVANTUM_DIR}"
[[ ! -d ${WALLPAPER_DIR} ]] && mkdir -p "${WALLPAPER_DIR}"

cp -rf "${SRC_DIR}"/configs/Xresources "$HOME"/.Xresources

install() {
  local name=${1}

  [[ -d ${AURORAE_DIR}/${name} ]] && rm -rf "${AURORAE_DIR:?}"/"${name:?}"*
  [[ -d ${PLASMA_DIR}/${name} ]] && rm -rf "${PLASMA_DIR:?}"/"${name:?}"*
  [[ -f ${SCHEMES_DIR}/${name}.colors ]] && rm -rf "${SCHEMES_DIR:?}"/"${name:?}"*.colors
  [[ -d ${LOOKFEEL_DIR}/com.github.vinceliuice.${name} ]] && rm -rf "${LOOKFEEL_DIR:?}"/com.github.vinceliuice."${name:?}"*
  [[ -d ${KVANTUM_DIR}/${name} ]] && rm -rf "${KVANTUM_DIR:?}"/"${name:?}"*
  [[ -d ${WALLPAPER_DIR}/${name} ]] && rm -rf "${WALLPAPER_DIR:?}"/"${name:?}"
  [[ -f ${LATTE_DIR}/${name}.layout.latte ]] && rm -rf "${LATTE_DIR}"/"${name}".layout.latte

  cp -r "${SRC_DIR}"/aurorae/*                                                         "${AURORAE_DIR}"
  cp -r "${SRC_DIR}"/Kvantum/*                                                         "${KVANTUM_DIR}"
  for theme in ${themes[*]}; do
    if [[ "${theme}" != 'default' ]]; then
      cp "${SRC_DIR}"/Kvantum/WhiteSur-solid/WhiteSur-solid-${theme}.svg               "${KVANTUM_DIR}"/WhiteSur-solid/WhiteSur-solid.svg
      cp "${SRC_DIR}"/Kvantum/WhiteSur-solid/WhiteSur-solidDark-${theme}.svg           "${KVANTUM_DIR}"/WhiteSur-solid/WhiteSur-solidDark.svg
    fi
  done
  cp -r "${SRC_DIR}"/color-schemes/*                                                   "${SCHEMES_DIR}"
  cp -r "${SRC_DIR}"/plasma/desktoptheme/"${name:?}"*                                  "${PLASMA_DIR}"
  cp -r "${SRC_DIR}"/plasma/desktoptheme/icons                                         "${PLASMA_DIR}"/"${name:?}"
  cp -r "${SRC_DIR}"/plasma/desktoptheme/icons                                         "${PLASMA_DIR}"/"${name:?}"-alt
  cp -r "${SRC_DIR}"/plasma/desktoptheme/icons                                         "${PLASMA_DIR}"/"${name:?}"-dark
  cp -r "${SRC_DIR}"/plasma/look-and-feel/*                                            "${LOOKFEEL_DIR}"
  cp -r "${SRC_DIR}"/wallpaper/"${name:?}"                                             "${WALLPAPER_DIR}"
  [[ -d ${LATTE_DIR} ]] && cp -r "${SRC_DIR}"/latte-dock/*                             "${LATTE_DIR}"
}

echo "Installing '${THEME_NAME} kde themes'..."

install "${name:-${THEME_NAME}}"

echo "Install finished..."
