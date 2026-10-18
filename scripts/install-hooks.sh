#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Opt-in: point git at the repo's advisory hooks. Sets core.hooksPath only; it
# never stages, commits, or changes history.
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"
parse_dry_run "$@" || { sed -n '3,5p' "$0"; exit 0; }

REPO=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
run git -C "$REPO" config core.hooksPath .githooks
log "core.hooksPath set to .githooks (advisory docs check runs on commit)"
log "disable with: git -C $REPO config --unset core.hooksPath"
