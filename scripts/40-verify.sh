#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Verify the fingerprint reader state. Read-only; no root required.
set -uo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,5p' "$0"; exit 0; }

rc=0
section() { printf '\n== %s ==\n' "$1"; }

section "fprintd service"
printf 'active/enabled: %s / %s\n' \
  "$(systemctl is-active fprintd 2>/dev/null)" \
  "$(systemctl is-enabled fprintd 2>/dev/null)"

section "Readers and enrolled prints"
if command -v fprintd-list >/dev/null 2>&1; then
  if out=$(fprintd-list "$USER" 2>&1); then
    printf '%s\n' "$out"
    case "$out" in
      *Device*) ;;
      *) warn "no reader listed - a driver is not claiming the FTE3600"; rc=1 ;;
    esac
    case "$out" in
      *"no fingers enrolled"*) warn "no finger enrolled yet: fprintd-enroll -f right-index-finger $USER" ;;
    esac
  else
    err "fprintd-list failed"; printf '%s\n' "$out"; rc=1
  fi
else
  err "fprintd-list not installed"; rc=1
fi

section "Kernel driver module"
# NOTE: avoid `... | grep -q`; under `set -o pipefail` grep -q exits early, the
# producer gets SIGPIPE, and the pipeline wrongly reports failure.
mods=$(lsmod 2>/dev/null | grep -E '^(focal_spi|fte3600) ')
if [ -n "$mods" ]; then
  printf '%s\n' "$mods"
else
  warn "neither focal_spi (route A) nor fte3600 (route B) is loaded"
fi

section "spidev buffer"
if [ -r /sys/module/spidev/parameters/bufsiz ]; then
  printf 'bufsiz: %s (route B needs >= 65536)\n' "$(cat /sys/module/spidev/parameters/bufsiz)"
else
  printf 'spidev not loaded (route A does not need it)\n'
fi

section "PAM"
pam_hits=$(grep -rl pam_fprintd /etc/pam.d/ 2>/dev/null | grep -v '\.bak')
if [ -n "$pam_hits" ]; then
  printf '%s\n' "$pam_hits"
else
  warn "pam_fprintd not configured (run scripts/30-enable-pam.sh)"
fi

section "Manual checks"
printf '%s\n' \
  '  fprintd-verify -f right-index-finger "$USER"' \
  '  sudo -k && sudo -v            # expect fingerprint, then password fallback' \
  '  journalctl -u fprintd -b       # on failure'

exit "$rc"
