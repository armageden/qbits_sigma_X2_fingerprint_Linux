#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Read-only reconnaissance for the Qbits Sigma X2 FocalTech FTE3600 sensor.
#
# Verifies that this machine really exposes an FTE3600 SPI fingerprint sensor and
# reports the tooling/packages the install scripts rely on. Needs no root and
# changes nothing. Exits non-zero when the sensor identity does not match.
set -uo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,8p' "$0"; exit 0; }

fail=0
section() { printf '\n== %s ==\n' "$1"; }
have()    { command -v "$1" >/dev/null 2>&1; }

section "System"
printf 'vendor/model : %s %s\n' \
  "$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)" \
  "$(cat /sys/class/dmi/id/product_name 2>/dev/null)"
printf 'kernel       : %s\n' "$(uname -r)"
printf 'distribution : %s\n' "$(. /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-unknown}")"

section "Sensor (expect: FocalTech FTE3600 on SPI)"
ACPI=/sys/bus/acpi/devices/FTE3600:00
if [ -d "$ACPI" ]; then
  printf 'ACPI device  : %s (status %s)\n' "$ACPI" "$(cat "$ACPI/status" 2>/dev/null)"
else
  err "no ACPI device FTE3600:00 - sensor identity mismatch"; fail=1
fi

SPI=""
for d in /sys/bus/spi/devices/*; do
  [ -r "$d/firmware_node/hid" ] || continue
  if [ "$(cat "$d/firmware_node/hid" 2>/dev/null)" = FTE3600 ]; then SPI=$d; fi
done
if [ -n "$SPI" ]; then
  printf 'SPI device   : %s\n' "$SPI"
  printf 'modalias     : %s\n' "$(cat "$SPI/modalias" 2>/dev/null)"
  if [ -e "$SPI/driver" ]; then
    printf 'bound driver : %s\n' "$(basename "$(readlink -f "$SPI/driver")")"
  else
    printf 'bound driver : unclaimed (no kernel driver bound yet)\n'
  fi
else
  err "no SPI device with ACPI HID FTE3600 - sensor identity mismatch"; fail=1
fi

section "Tooling"
for t in paru dkms meson ninja gcc git fprintd-enroll systemctl; do
  if have "$t"; then printf '%-14s: %s\n' "$t" "$(command -v "$t")";
  else printf '%-14s: MISSING\n' "$t"; fi
done
if have glib-mkenums; then
  printf 'glib-mkenums  : %s\n' "$(command -v glib-mkenums)"
else
  warn "glib-mkenums missing - the clean-room build needs it; Arch ships it in glib2-devel"
fi

section "Packages"
for p in fprintd libfprint dkms linux-zen-headers glib2-devel; do
  printf '%-18s: %s\n' "$p" "$(pacman -Q "$p" 2>/dev/null || printf 'not installed')"
done

section "spidev buffer"
if [ -r /sys/module/spidev/parameters/bufsiz ]; then
  b=$(cat /sys/module/spidev/parameters/bufsiz)
  printf 'bufsiz       : %s (need >= 65536)\n' "$b"
  if [ "$b" -lt 65536 ] 2>/dev/null; then
    warn "bufsiz below 65536; the clean-room route saves 'options spidev bufsiz=65536'"
  fi
else
  printf 'spidev not loaded (route B runs: modprobe spidev bufsiz=65536)\n'
fi

section "Authentication"
printf 'fprintd      : %s / %s\n' \
  "$(systemctl is-active fprintd 2>/dev/null)" \
  "$(systemctl is-enabled fprintd 2>/dev/null)"
if grep -rq pam_fprintd /etc/pam.d/ 2>/dev/null; then
  printf 'PAM          : pam_fprintd present in %s\n' "$(grep -rl pam_fprintd /etc/pam.d/ 2>/dev/null | tr '\n' ' ')"
else
  printf 'PAM          : pam_fprintd not configured\n'
fi
if have sudo; then
  if sudo -n true >/dev/null 2>&1; then printf 'sudo         : passwordless available\n';
  else printf 'sudo         : requires a password (privileged steps are the operator'"'"'s to run)\n'; fi
fi

section "Result"
if [ "$fail" -eq 0 ]; then
  log "preflight OK - FTE3600 present and unclaimed; see docs/00-how-to/00-overview.md"
else
  die "preflight FAILED - this machine does not expose an FTE3600 SPI sensor as expected"
fi
