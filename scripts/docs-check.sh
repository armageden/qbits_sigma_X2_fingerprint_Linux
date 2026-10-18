#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Mechanical documentation validator. Zero dependencies beyond bash, coreutils
# and grep. Exit 0 when the knowledge base is consistent, 1 on any failure.
#
# Checks:
#   1. Path existence  - repo-relative paths in backticks exist on disk.
#   2. Overview        - every docs/NN-* has 00-overview.md linking each file.
#   3. Backlink        - every docs/ sub-file has the top backlink.
#   4. Link integrity  - no broken relative markdown links.
#   5. Reverse coverage- every scripts/*.sh is referenced by a doc.
set -uo pipefail

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$REPO" || exit 1

errors=0
fail() { printf 'ERROR: %s\n' "$*"; errors=$((errors + 1)); }

ROOT_FILES=(AGENTS.md README.md Makefile .gitignore)
TOP_PREFIXES=(docs/ scripts/ sandbox/ .githooks/)
IGNORE_FILE="scripts/docs-check.ignore"

mapfile -t MD_FILES < <(find docs -name '*.md' -type f 2>/dev/null | sort)
[ -f AGENTS.md ] && MD_FILES+=(AGENTS.md)

ignore=()
if [ -f "$IGNORE_FILE" ]; then
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    ignore+=("$line")
  done < "$IGNORE_FILE"
fi
ignored() {
  local t=$1 p
  for p in "${ignore[@]}"; do
    if [ -n "$p" ] && printf '%s\n' "$t" | grep -E "$p" >/dev/null; then return 0; fi
  done
  return 1
}

# --- 1. path existence -------------------------------------------------------
check_paths() {
  local file token candidate p
  for file in "${MD_FILES[@]}"; do
    [ -f "$file" ] || continue
    while IFS= read -r token; do
      [ -n "$token" ] || continue
      token=${token#./}
      case "$token" in
        *' '*|*'<'*|*'>'*|*'://'*|*'='*|*'*'*|*'!'*|*':'*|*','*|*'|'*|*'('*|*')'*|*'?'*|*'"'*|*"'"*|*'$'*|'/'*|'~'*) continue ;;
      esac
      candidate=0
      for p in "${TOP_PREFIXES[@]}"; do case "$token" in "$p"*) candidate=1 ;; esac; done
      for p in "${ROOT_FILES[@]}"; do [ "$token" = "$p" ] && candidate=1; done
      [ "$candidate" -eq 1 ] || continue
      ignored "$token" && continue
      [ -e "$token" ] || fail "$file: path '$token' does not exist"
    done < <(grep -oE '`[^`]+`' "$file" 2>/dev/null | sed 's/^`//; s/`$//')
  done
}

# --- 2. overview integrity ---------------------------------------------------
check_overviews() {
  local dir ov f base
  for dir in docs/*/; do
    [ -d "$dir" ] || continue
    ov="$dir/00-overview.md"
    if [ ! -f "$ov" ]; then fail "$dir has no 00-overview.md"; continue; fi
    for f in "$dir"*.md; do
      [ -f "$f" ] || continue
      base=$(basename "$f")
      [ "$base" = "00-overview.md" ] && continue
      grep -qE "\]\(\.?/?$base(#[^)]*)?\)" "$ov" || fail "$ov does not link $base"
    done
  done
}

# --- 3. backlink integrity ---------------------------------------------------
check_backlinks() {
  local f
  while IFS= read -r f; do
    [ "$(basename "$f")" = "00-overview.md" ] && continue
    head -n 3 "$f" | grep -qF '**Back:** [00-overview](./00-overview.md)' \
      || fail "$f is missing the top '**Back:** [00-overview](./00-overview.md)' line"
  done < <(find docs -name '*.md' -type f 2>/dev/null | sort)
}

# --- 4. relative link integrity ---------------------------------------------
check_links() {
  local file link target dir
  for file in "${MD_FILES[@]}"; do
    [ -f "$file" ] || continue
    while IFS= read -r link; do
      [ -n "$link" ] || continue
      case "$link" in http://*|https://*|mailto:*|'#'*) continue ;; esac
      target=${link%%#*}
      [ -n "$target" ] || continue
      dir=$(dirname "$file")
      [ -e "$dir/$target" ] || fail "$file: broken link -> $link"
    done < <(grep -oE '\]\([^)]+\)' "$file" 2>/dev/null | sed 's/^](//; s/)$//')
  done
}

# --- 5. reverse coverage -----------------------------------------------------
check_coverage() {
  local s base
  for s in scripts/*.sh; do
    [ -f "$s" ] || continue
    base=$(basename "$s")
    grep -rqF "scripts/$base" docs AGENTS.md 2>/dev/null \
      || fail "scripts/$base is not referenced by any doc (reverse coverage)"
  done
}

check_paths
check_overviews
check_backlinks
check_links
check_coverage

if [ "$errors" -gt 0 ]; then
  printf '\ndocs-check: %d error(s)\n' "$errors"
  exit 1
fi
printf 'docs-check: OK (%d markdown file(s) checked)\n' "${#MD_FILES[@]}"
