#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Route B (OSS fallback): clean-room libfprint driver for the FTE3600 sensor.
#   * clones SamSeven777/libfprint-fte3600 into sandbox/src
#   * installs build dependencies
#   * installs the FTE3600 ACPI reset/IRQ glue module via DKMS (module "fte3600")
#   * builds + installs libfprint with -Ddrivers=fte3600
#   * wires systemd device access for fprintd
# Firmware is installed separately (scripts/21-extract-firmware.sh).
# Run as your NORMAL USER; privileged steps use sudo.
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,10p' "$0"; exit 0; }

REPO=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SRC="$REPO/sandbox/src/libfprint-fte3600"
UPSTREAM=https://github.com/SamSeven777/libfprint-fte3600.git

require_user

log "1/5 fetch driver sources (shallow) into sandbox/src"
if [ -d "$SRC/.git" ]; then
  log "driver sources already present: $SRC"
else
  run git clone --depth 1 "$UPSTREAM" "$SRC"
fi
[ -f "$SRC/scripts/setup-fte3600.sh" ] || die "driver layout unexpected: $SRC/scripts/setup-fte3600.sh missing"

log "2/5 install build dependencies (glib2-devel provides glib-mkenums)"
priv pacman -S --needed --noconfirm base-devel pkgconf meson ninja python \
  glib2 glib2-devel libgusb libgudev systemd
if ! pacman -Qq linux-zen-headers >/dev/null 2>&1; then
  priv pacman -S --needed --noconfirm linux-zen-headers
fi

log "3/5 install the ACPI reset/IRQ glue module (saves spidev bufsiz=65536)"
priv "$SRC/scripts/setup-fte3600.sh" install-kernel

log "4/5 build and install libfprint with -Ddrivers=fte3600"
run meson setup "$SRC/build-fte3600" "$SRC" --prefix=/usr --buildtype=release \
  -Ddrivers=fte3600 -Dgtk-examples=false -Ddoc=false -Dintrospection=false -Dinstalled-tests=false
run meson compile -C "$SRC/build-fte3600"
priv meson install -C "$SRC/build-fte3600"
priv ldconfig

log "5/5 install fprintd device access and restart the daemon"
priv "$SRC/scripts/setup-fte3600.sh" install-systemd
priv systemctl restart fprintd.service

cat >&2 <<'NEXT'

Route B install done. Firmware is still required before capture works:
  sudo ./scripts/21-extract-firmware.sh --detect --input /path/to/ftWbioUmdfDriverV2.dll
  fprintd-list "$USER"
  fprintd-enroll -f right-index-finger "$USER"
  sudo ./scripts/30-enable-pam.sh
  ./scripts/40-verify.sh
Rollback: sudo ./scripts/90-rollback.sh
NEXT
