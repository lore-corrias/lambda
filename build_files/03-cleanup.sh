#!/bin/bash

set -ouex pipefail

## Remove COSMIC from base image

cosmic_packages=$(rpm -qa 'cosmic-*' 2>/dev/null || true)

if [ -n "$cosmic_packages" ]; then
  echo "Removing COSMIC packages: $cosmic_packages"
  dnf5 remove -y $cosmic_packages
fi

dnf5 remove -y SwayNotificationCenter

rm -rf /usr/share/cosmic
