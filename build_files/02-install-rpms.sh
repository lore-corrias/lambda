#!/bin/bash

set -ouex pipefail

# Install packages

## Add COPR for Hyprland packages
dnf5 -y copr enable lionheartp/Hyprland "fedora-${FEDORA_VERSION}-$(arch)"

## Add COPR for iLoader
dnf5 -y copr enable anudeepd/iloader "fedora-${FEDORA_VERSION}-$(arch)"

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
# The persistent DNF cache can otherwise hide newly published COPR packages.
grep -v '^\s*\/\/' /ctx/packages/default.jsonc | jq -r '.[]' | xargs dnf5 --refresh install -y

# RPM Fusion's akmod scriptlet cannot build modules as root during image builds.
# The installed akmods service builds the module on the booted host instead.
if ! dnf5 install -y VirtualBox akmod-VirtualBox; then
  rpm -q VirtualBox akmod-VirtualBox >/dev/null
fi

dnf5 clean all
