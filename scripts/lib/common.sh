#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Shared helpers for the FTE3600 enablement scripts.
#
# Source this file, never execute it:
#     SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
#     . "$SCRIPT_DIR/lib/common.sh"
#
# This file deliberately sets NO shell options, so it cannot change how the
# sourcing script behaves. Each script sets its own `set` flags.

DRY_RUN=0

if [ -t 2 ]; then
  _c_reset=$'\033[0m'; _c_red=$'\033[31m'; _c_grn=$'\033[32m'; _c_ylw=$'\033[33m'
else
  _c_reset=''; _c_red=''; _c_grn=''; _c_ylw=''
fi

log()  { printf '%s[fte3600]%s %s\n'  "$_c_grn" "$_c_reset" "$*" >&2; }
warn() { printf '%s[fte3600] warning:%s %s\n' "$_c_ylw" "$_c_reset" "$*" >&2; }
err()  { printf '%s[fte3600] error:%s %s\n'   "$_c_red" "$_c_reset" "$*" >&2; }
die()  { err "$*"; exit 1; }

# Parse the common --dry-run/-n flag. Returns 2 when --help/-h is seen so the
# caller can print its own usage.
parse_dry_run() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      --dry-run|-n) DRY_RUN=1 ;;
      --help|-h)    return 2 ;;
    esac
  done
  return 0
}

is_root() { [ "$(id -u)" -eq 0 ]; }

# Root requirement is waived under --dry-run so any user can preview the plan.
require_root() { if ! is_root && [ "$DRY_RUN" -eq 0 ]; then die "this step needs root; re-run with sudo (or add --dry-run to preview)"; fi; }
# AUR helpers (paru/yay) refuse to run as root and elevate themselves.
require_user() { if is_root && [ "$DRY_RUN" -eq 0 ]; then die "run this as your normal user, not root (paru refuses to run as root)"; fi; }

# run CMD... : execute directly, honouring --dry-run.
run() {
  if [ "$DRY_RUN" -eq 1 ]; then printf '  [dry-run] %s\n' "$*" >&2; return 0; fi
  "$@"
}

# priv CMD... : execute as root (via sudo unless already root), honouring --dry-run.
priv() {
  if [ "$DRY_RUN" -eq 1 ]; then
    if is_root; then printf '  [dry-run] %s\n' "$*" >&2; else printf '  [dry-run] sudo %s\n' "$*" >&2; fi
    return 0
  fi
  if is_root; then "$@"; else sudo "$@"; fi
}

# backup_file PATH : copy PATH to PATH.bak.<timestamp> (via sudo when not root).
backup_file() {
  local f=$1 stamp
  if [ ! -e "$f" ]; then warn "nothing to back up: $f"; return 0; fi
  stamp=$(date +%Y%m%d-%H%M%S)
  priv cp -a "$f" "$f.bak.$stamp"
  log "backed up $f -> $f.bak.$stamp"
}

confirm() {
  local prompt=${1:-"Continue?"} reply
  if [ "$DRY_RUN" -eq 1 ]; then log "dry-run: auto-confirming '$prompt'"; return 0; fi
  read -r -p "$prompt [y/N] " reply </dev/tty || reply=n
  case "$reply" in y|Y|yes|YES) return 0 ;; *) die "aborted by user" ;; esac
}
