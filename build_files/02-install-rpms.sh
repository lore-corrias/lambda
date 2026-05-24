#!/bin/bash

set -ouex pipefail

# Install packages

## Add COPR for Hyprland packages
dnf5 -y copr enable lionheartp/Hyprland "fedora-${FEDORA_VERSION}-$(arch)"

# Install rpmfusion repositories
dnf5 install -y \
	"https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm" \
	"https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm"

# Create directories for packages installed under /opt
# to bypass a cpio bug when creating a directory under a symlink
# (which is /opt -> /var/opt)
mkdir -p /var/opt/vagrant && 
  mkdir -p /var/opt/Mullvad\ VPN

## Install packages from the default list
grep -v '^\s*\/\/' /ctx/packages/default.jsonc | jq -r '.[]' | xargs dnf5 install -y \
  && dnf5 clean all
