#!/bin/bash

set -ouex pipefail

ARCH="$(arch)"
case "$ARCH" in
  x86_64)
    EZA_ARCH="x86_64-unknown-linux-gnu"
    CHEZMOI_ARCH="linux_amd64"
    ;;
  aarch64)
    EZA_ARCH="aarch64-unknown-linux-gnu"
    CHEZMOI_ARCH="linux_arm64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

# Install eza

## For now, this is required, as long as eza won't be available in fedora 42
## Maybe switch to a COPR in the future

LATEST_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | jq -r .tag_name)
RELEASE_URL="https://github.com/eza-community/eza/releases/download/${LATEST_VERSION}"
TARBALL="eza_${EZA_ARCH}.tar.gz"

curl -sSL "${RELEASE_URL}/${TARBALL}" -o "/tmp/${TARBALL}"
curl -sSL "${RELEASE_URL}/sha256sums.txt" -o /tmp/eza-sha256sums.txt

(cd /tmp && sha256sum --check --ignore-missing eza-sha256sums.txt)

tar -xzf "/tmp/${TARBALL}" -C /tmp
mv /tmp/eza /usr/bin/eza
eza --version

# Install grimblast (pinned to a known commit)

# TODO: install this more elegantly
wget https://raw.githubusercontent.com/hyprwm/contrib/43c012d21d9314c585b97ac4f34752f6de93dc8f/grimblast/grimblast -O /usr/bin/grimblast

# Install chezmoi

CHEZMOI_VERSION="v2.70.4"
CHEZMOI_TARBALL="chezmoi_${CHEZMOI_VERSION#v}_${CHEZMOI_ARCH}.tar.gz"
CHEZMOI_URL="https://github.com/twpayne/chezmoi/releases/download/${CHEZMOI_VERSION}/${CHEZMOI_TARBALL}"

curl -sSL "${CHEZMOI_URL}" -o "/tmp/${CHEZMOI_TARBALL}"
tar -xzf "/tmp/${CHEZMOI_TARBALL}" -C /usr/local/bin chezmoi
