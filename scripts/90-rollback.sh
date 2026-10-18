#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Best-effort rollback: restore PAM, reinstall upstream libfprint, and remove
# both route A (focaltech-spi-dkms / libfprint-ftexx00) and route B artifacts.
set -uo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,7p' "$0"; exit 0; }
require_root

REPO=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SRC="$REPO/sandbox/src/libfprint-fte3600"
PAM_ABS=/etc/pam.d/system-auth

log "1/5 restore the PAM configuration from the newest backup"
latest=$(ls -1t "$PAM_ABS".bak.* 2>/dev/null | head -n1 || true)
if [ -n "$latest" ]; then
  priv cp -a "$latest" "$PAM_ABS"
  log "restored $PAM_ABS from $latest"
else
  warn "no $PAM_ABS.bak.* backup found; leaving PAM untouched"
fi

log "2/5 remove route B integration (if present)"
if [ -x "$SRC/scripts/setup-fte3600.sh" ]; then
  priv "$SRC/scripts/setup-fte3600.sh" uninstall || warn "setup-fte3600.sh uninstall reported problems"
else
  log "route B sources not present; skipping"
fi

log "3/5 remove route A packages (if present)"
if pacman -Qq libfprint-ftexx00 >/dev/null 2>&1; then priv pacman -Rdd --noconfirm libfprint-ftexx00; fi
if pacman -Qq focaltech-spi-dkms >/dev/null 2>&1; then
  priv dkms remove focaltech-spi-dkms/1.0.3 --all 2>/dev/null || true
  priv pacman -Rns --noconfirm focaltech-spi-dkms || true
fi

log "4/5 reinstall upstream libfprint"
priv pacman -S --needed --noconfirm libfprint || warn "could not reinstall upstream libfprint"
priv ldconfig || true

log "5/5 restart fprintd"
priv systemctl restart fprintd.service || warn "fprintd restart failed"

if [ -n "${SUDO_USER:-}" ]; then
  warn "enrolled prints are NOT deleted automatically; run: fprintd-delete $SUDO_USER"
fi
log "rollback complete; reboot recommended to drop any loaded driver module"
