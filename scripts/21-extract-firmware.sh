#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Firmware installer wrapper around the driver's own install-firmware.sh.
# It validates every payload by size AND SHA-256; it never executes vendor code.
#
#   --list                       print the firmware catalog and exit
#   --detect --input FILE        identify the chip by validating a local DLL/CAB
#   --chip NAME --download       fetch the pinned Microsoft-catalog CAB and install
#   --chip NAME --input FILE     extract from a local DLL/CAB and install
# NAME is one of: ft9338 ft9348 ft9361 ft9536 ft9368
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,11p' "$0"; exit 0; }

REPO=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DRIVER="$REPO/sandbox/src/libfprint-fte3600/scripts/install-firmware.sh"
CHIPS=(ft9338 ft9348 ft9361 ft9536 ft9368)

mode=""; chip=""; input=""; destdir=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --list)       mode=list ;;
    --detect)     mode=detect ;;
    --download)   mode=download ;;
    --chip)       shift; chip=${1:-} ;;
    --input)      shift; input=${1:-} ;;
    --destdir)    shift; destdir=${1:-} ;;
    *) die "unknown argument: $1" ;;
  esac
  shift || true
done

[ -f "$DRIVER" ] || die "driver not fetched; run ./scripts/20-install-route-b-cleanroom.sh first"

dest_arg=()
if [ -n "$destdir" ]; then dest_arg=(--destdir "$destdir"); fi

case "$mode" in
  list)
    run "$DRIVER" --list
    ;;
  chip|download)
    [ -n "$chip" ] || die "--chip is required for installation"
    if [ -n "$input" ]; then
      priv "$DRIVER" --chip "$chip" --input "$input" "${dest_arg[@]}"
    elif [ "$mode" = download ] || [ -z "$input" ]; then
      priv "$DRIVER" --chip "$chip" --download "${dest_arg[@]}"
    fi
    ;;
  detect)
    [ -n "$input" ] || die "--detect requires --input FILE (a local DLL or CAB)"
    found=""
    for c in "${CHIPS[@]}"; do
      if "$DRIVER" --chip "$c" --input "$input" --verify-only >/dev/null 2>&1; then found=$c; break; fi
    done
    [ -n "$found" ] || die "no catalogued chip matched $input"
    log "detected chip: $found"
    priv "$DRIVER" --chip "$found" --input "$input" "${dest_arg[@]}"
    ;;
  *)
    die "usage: 21-extract-firmware.sh --list | --detect --input FILE | --chip NAME (--download|--input FILE)"
    ;;
esac
