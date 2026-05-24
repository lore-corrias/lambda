#!/bin/bash

set -ouex pipefail

SILENT_SDDM_REPO="https://github.com/uiriansan/SilentSDDM"
THEME_DIR="/usr/share/sddm/themes/silent"

mkdir -p "${THEME_DIR}"

git clone -b main --depth=1 "${SILENT_SDDM_REPO}" /tmp/SilentSDDM

cp -rf /tmp/SilentSDDM/. "${THEME_DIR}/"

mkdir -p /usr/share/fonts/silent-sddm
cp -r "${THEME_DIR}/fonts/"* /usr/share/fonts/silent-sddm/ 2>/dev/null || true
fc-cache -f

rm -rf /tmp/SilentSDDM
