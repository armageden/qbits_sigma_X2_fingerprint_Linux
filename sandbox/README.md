# sandbox

Fetched upstream sources and non-root build validation. Contents are gitignored.

- `sandbox/build-route-b.sh` - clone the clean-room driver and attempt a non-root `meson` build.
- `sandbox/src/` - the cloned driver (fetched on demand).
- `sandbox/aur/` - PKGBUILDs fetched with `paru -G` for inspection.
- `sandbox/build/` - meson build trees.

Nothing here is committed; delete it freely and re-run a script to refetch.
