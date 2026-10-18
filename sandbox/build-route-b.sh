#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Non-root validation: clone the clean-room driver and try to build it locally
# WITHOUT touching the system. Proves buildability before any privileged step.
set -uo pipefail

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SRC="$REPO/sandbox/src/libfprint-fte3600"
BUILD="$REPO/sandbox/build/fte3600"
UPSTREAM=https://github.com/SamSeven777/libfprint-fte3600.git

if [ ! -d "$SRC/.git" ]; then
  echo "cloning $UPSTREAM into $SRC"
  git clone --depth 1 "$UPSTREAM" "$SRC" || exit 1
fi

missing=""
for t in meson ninja cc glib-mkenums; do
  command -v "$t" >/dev/null 2>&1 || missing="$missing $t"
done
if [ -n "$missing" ]; then
  echo "missing build tools:$missing"
  echo "install with: sudo pacman -S --needed base-devel pkgconf meson ninja glib2-devel libgusb libgudev systemd"
  exit 1
fi

meson setup "$BUILD" "$SRC" --buildtype=release \
  -Ddrivers=fte3600 -Dgtk-examples=false -Ddoc=false -Dintrospection=false -Dinstalled-tests=false \
  && meson compile -C "$BUILD" \
  && echo "non-root build OK: $BUILD (nothing was installed)"
