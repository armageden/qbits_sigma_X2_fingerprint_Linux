#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Route A (primary attempt): proprietary FocalTech driver from the AUR.
#   focaltech-spi-dkms  -> DKMS module "focal_spi"
#   libfprint-ftexx00   -> proprietary libfprint blob (conflicts with upstream libfprint)
# Run as your NORMAL USER (paru refuses to run as root; it elevates itself via sudo).
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,6p' "$0"; exit 0; }

require_user
warn "Route A replaces the system 'libfprint' with a proprietary blob and conflicts with upstream."

log "1/4 back up the PAM configuration"
backup_file /etc/pam.d/system-auth

log "2/4 install focaltech-spi-dkms (DKMS builds focal_spi against linux-zen-headers)"
if pacman -Qq focaltech-spi-dkms >/dev/null 2>&1; then
  log "focaltech-spi-dkms already installed"
else
  run paru -S --needed --noconfirm focaltech-spi-dkms
fi

log "3/4 install libfprint-ftexx00 (replaces upstream libfprint)"
if pacman -Qq libfprint-ftexx00 >/dev/null 2>&1; then
  log "libfprint-ftexx00 already installed"
else
  # This package conflicts with the installed 'libfprint', so pacman MUST ask to
  # replace it: --noconfirm makes pacman refuse ("can not install conflicting
  # packages with --noconfirm"). Leave the prompt interactive and answer "y".
  warn "libfprint-ftexx00 conflicts with the installed 'libfprint'; confirm 'remove libfprint? y' when prompted"
  run paru -S --needed libfprint-ftexx00
fi

log "4/4 ensure fprintd is present and load focal_spi"
pacman -Qq fprintd >/dev/null 2>&1 || priv pacman -S --needed --noconfirm fprintd
priv modprobe focal_spi || warn "modprobe focal_spi failed; a reboot may be required"

cat >&2 <<'NEXT'

Route A install done. Next steps:
  fprintd-list "$USER"                        # must list the FTE3600 reader
  fprintd-enroll -f right-index-finger "$USER"
    -> "init sensor error!" on Alder Lake? run ./scripts/11-install-route-a-alt-module.sh
  sudo ./scripts/30-enable-pam.sh             # login / lock / sudo
  ./scripts/40-verify.sh                      # verify
Rollback: sudo ./scripts/90-rollback.sh
NEXT
