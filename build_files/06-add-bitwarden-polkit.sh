#!/bin/bash

set -ouex pipefail

wget -O /usr/share/polkit-1/actions/com.bitwarden.Bitwarden.policy https://raw.githubusercontent.com/bitwarden/clients/main/apps/desktop/resources/com.bitwarden.desktop.policy && \
  chown root:root /usr/share/polkit-1/actions/com.bitwarden.Bitwarden.policy
