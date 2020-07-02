#!/bin/bash

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

uninstall() {
  local name=${1}

  local AURORAE_THEME="${AURORAE_DIR}/${name}"
  local PLASMA_THEME="${PLASMA_DIR}/${name}"
  local SCHEMES_THEME="${SCHEMES_DIR}/${name}.colors"
  local KVANTUM_THEME="${KVANTUM_DIR}/${name}"
  local LOOKFEEL_THEME="${LOOKFEEL_DIR}/com.github.vinceliuice.${name}"
  local WALLPAPER_THEME="${WALLPAPER_DIR}/${name}"
  local LATTE_LAYOUT="${LATTE_DIR}/${name}.layout.latte"

  [[ -d ${AURORAE_THEME} ]] && rm -rfv ${AURORAE_THEME}
  [[ -d ${PLASMA_THEME} ]] && rm -rfv ${PLASMA_THEME}
  [[ -d ${PLASMA_THEME}-alt ]] && rm -rfv ${PLASMA_THEME}-alt
  [[ -f ${SCHEMES_THEME} ]] && rm -rfv ${SCHEMES_THEME}
  [[ -d ${LOOKFEEL_THEME} ]] && rm -rfv ${LOOKFEEL_THEME}
  [[ -d ${KVANTUM_THEME} ]] && rm -rfv ${KVANTUM_THEME}
  [[ -d ${WALLPAPER_THEME} ]] && rm -rfv ${WALLPAPER_THEME}
  [[ -f ${LATTE_LAYOUT} ]] && rm -rfv ${LATTE_LAYOUT}
}

echo "Uninstalling '${THEME_NAME} kde themes'..."

uninstall "${name:-${THEME_NAME}}"

echo "Uninstall finished..."
