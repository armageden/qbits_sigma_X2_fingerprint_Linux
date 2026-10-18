#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Enable fingerprint authentication by inserting pam_fprintd.so into
# /etc/pam.d/system-auth. That one file is included by sudo, login (greetd) and
# gtklock (lock screen), so a single insertion covers all of them.
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,6p' "$0"; exit 0; }
require_root

force=0
for a in "$@"; do case "$a" in --force) force=1 ;; esac; done

PAM_ABS=/etc/pam.d/system-auth
PAM_MODULE=/usr/lib/security/pam_fprintd.so

[ -f "$PAM_ABS" ] || die "$PAM_ABS not found"
[ -e "$PAM_MODULE" ] || die "$PAM_MODULE missing; install fprintd first"

if grep -q pam_fprintd "$PAM_ABS"; then
  log "pam_fprintd.so already present in $PAM_ABS; nothing to do"
  exit 0
fi

# Do not enable biometric auth before a reader actually exists: a half-set-up
# state just adds a failing auth step. Require a visible device unless --force.
target=${SUDO_USER:-}
dev_ok=0
if [ -n "$target" ] && command -v fprintd-list >/dev/null 2>&1; then
  # Capture output instead of `... | grep -q` (which SIGPIPEs under pipefail).
  pam_out=$(fprintd-list "$target" 2>/dev/null || true)
  case "$pam_out" in *Device*) dev_ok=1 ;; esac
fi
if [ "$dev_ok" -eq 0 ]; then
  if [ "$DRY_RUN" -eq 1 ]; then
    warn "no fingerprint reader visible to fprintd for '${target:-?}'; a real run would refuse (pass --force to override)"
  elif [ "$force" -eq 1 ]; then
    warn "no fingerprint reader visible to fprintd; proceeding because --force was given"
  else
    die "no fingerprint reader visible to fprintd for '${target:-?}'; finish the driver and enroll a finger first, or pass --force"
  fi
fi

backup_file "$PAM_ABS"

tmp=$(mktemp)
# Insert before the first pam_systemd_home/pam_unix auth line: this keeps the
# pam_faillock preauth line (account lockout) intact and does not disturb the
# [success=N ...] jump counters on the existing lines.
awk '
  BEGIN { done = 0 }
  !done && /^[[:space:]]*-?auth[[:space:]].*pam_(systemd_home|unix)/ {
    print "auth       sufficient   pam_fprintd.so"
    done = 1
  }
  { print }
' "$PAM_ABS" > "$tmp"

if ! grep -q pam_fprintd "$tmp"; then
  rm -f "$tmp"; die "could not find an insertion point in $PAM_ABS"
fi

if [ "$DRY_RUN" -eq 1 ]; then
  log "dry-run: would change $PAM_ABS as follows"
  diff -u "$PAM_ABS" "$tmp" || true
  rm -f "$tmp"
  exit 0
fi

install -m 0644 -o root -g root "$tmp" "$PAM_ABS"
rm -f "$tmp"
log "inserted 'auth sufficient pam_fprintd.so' into $PAM_ABS"
log "covered services: sudo, login (greetd), gtklock (lock screen)"
log "test with: sudo -k && sudo -v   (fingerprint first, password fallback)"
