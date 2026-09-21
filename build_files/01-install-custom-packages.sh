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

TARBALL="eza_${EZA_ARCH}.tar.gz"
RELEASE_METADATA=$(
  curl --fail --silent --show-error --location \
    https://api.github.com/repos/eza-community/eza/releases/latest
)
RELEASE_URL=$(jq -er --arg tarball "$TARBALL" \
  '.assets[] | select(.name == $tarball) | .browser_download_url' <<<"$RELEASE_METADATA")
EXPECTED_SHA256=$(jq -er --arg tarball "$TARBALL" \
  '.assets[] | select(.name == $tarball) | .digest | sub("^sha256:"; "")' <<<"$RELEASE_METADATA")

curl --fail --silent --show-error --location "$RELEASE_URL" -o "/tmp/${TARBALL}"
printf '%s  %s\n' "$EXPECTED_SHA256" "/tmp/${TARBALL}" | sha256sum --check -

tar -xzf "/tmp/${TARBALL}" -C /tmp
mv /tmp/eza /usr/bin/eza
eza --version

# Install grimblast (pinned to a known commit)

# TODO: install this more elegantly
wget https://raw.githubusercontent.com/hyprwm/contrib/43c012d21d9314c585b97ac4f34752f6de93dc8f/grimblast/grimblast -O /usr/bin/grimblast
