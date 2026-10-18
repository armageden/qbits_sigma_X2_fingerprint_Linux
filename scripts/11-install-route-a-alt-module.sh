#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Route A fix for Alder Lake (12th gen) hosts: rebuild focaltech-spi-dkms from the
# upstream alt/focal_spi.c, which configures SPI_MODE_0 explicitly.
#
# Symptom without it:
#   fprintd-enroll -> "failed to claim device: ... init sensor error!"
#   journalctl -u fprintd -b -> "configure spi mode failed(0)" and
#                                "got undesired device id: 0x0000"
# The default module targets Tiger Lake (11th gen) SPI settings.
# Run as your NORMAL USER (makepkg refuses root; -i elevates via sudo).
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { echo "usage: $(basename "$0") [--dry-run]"; exit 0; }
require_user

REPO=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
AURDIR="$REPO/sandbox/aur"
PKGDIR="$AURDIR/focaltech-spi-dkms"
PKGBUILD="$PKGDIR/PKGBUILD"

log "1/4 fetch focaltech-spi-dkms sources (paru -G)"
if [ -f "$PKGBUILD" ]; then
  log "already fetched: $PKGDIR"
else
  mkdir -p "$AURDIR"
  ( cd "$AURDIR" && run paru -G --noconfirm focaltech-spi-dkms )
fi

log "2/4 patch PKGBUILD prepare() to copy alt/focal_spi.c over the default"
if grep -q 'alt/focal_spi.c' "$PKGBUILD"; then
  log "already patched"
elif [ "$DRY_RUN" -eq 1 ]; then
  printf '  [dry-run] insert  cp -f "alt/focal_spi.c" .  after the srcdir cd in %s\n' "$PKGBUILD" >&2
else
  python3 - "$PKGBUILD" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
needle = 'cd "$srcdir/FTEXX00-Ubuntu"'
if needle not in text:
    sys.exit("prepare() anchor not found in " + path)
open(path, "w", encoding="utf-8").write(
    text.replace(needle, needle + '\n  cp -f "alt/focal_spi.c" .', 1))
print("patched " + path)
PY
fi

log "3/4 build and reinstall the DKMS package"
( cd "$PKGDIR" && run makepkg -s -i -f --noconfirm )

log "4/4 reload the SPI module (focal_spi)"
priv modprobe -r focal_spi || true
priv modprobe focal_spi

cat >&2 <<'NEXT'

Alt-module install done. Next:
  fprintd-list "$USER"                              # reader should still appear
  fprintd-enroll -f right-index-finger "$USER"      # must no longer say "init sensor error!"
  ./scripts/40-verify.sh
NEXT
