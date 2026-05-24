#!/bin/bash

set -ouex pipefail

enable_user_service() {
  systemd_unit="/usr/lib/systemd/user/$1"
  if [ -z "$1" ] || [ ! -f "$systemd_unit" ]; then
    echo "Error: user service $1 not found." >&2
    return 1
  fi

  ln -sf "$systemd_unit" "/etc/systemd/user/default.target.wants/$1"
}

# Enable default services

## Rpm-ostree automatic updates
systemctl unmask rpm-ostreed-automatic.timer
systemctl enable rpm-ostreed-automatic.timer

## Enable Mullvad service
systemctl enable mullvad-daemon

## Enable SDDM display manager
systemctl enable sddm.service

for service in install-dotfiles.service setup-flatpak.service flatpak-user-update.service flatpak-user-update.timer hyprpolkitagent.service xdg-desktop-portal-hyprland.service; do
  enable_user_service "$service"
done
