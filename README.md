# Qbits Sigma X2 fingerprint on Linux (FocalTech FTE3600)

Make the FTE3600 SPI fingerprint sensor work on this Garuda/Arch laptop, with a
documented, agent-maintainable setup.

**Read next:** `AGENTS.md` (project snapshot and rules) and
`docs/00-how-to/00-overview.md` (start here for tasks).

## Why this exists
The sensor is not on USB; it is a FocalTech FTE3600 on SPI that upstream
libfprint does not support. Two community driver routes exist and this repo
packages, verifies and documents both.

## Quick start
```
./scripts/00-preflight.sh                              # confirm the sensor (read-only)
./scripts/10-install-route-a-proprietary.sh --dry-run  # preview route A
```

- Route A = proprietary AUR blob (try first): `docs/02-drivers/01-route-proprietary-ftexx00.md`.
- Route B = OSS clean-room driver: `docs/02-drivers/02-route-cleanroom-fte3600.md`.

Because `sudo` needs a password, this repo generates and dry-run-validates
scripts; you run the privileged steps yourself.

## Layout
- `scripts/` - preflight, install (A/B), firmware, PAM, verify, rollback, docs-check.
- `docs/` - knowledge base: `00-how-to/` recipes plus numbered reference folders.
- `sandbox/` - fetched upstream sources and non-root build validation (gitignored).
- `AGENTS.md` - rules for AI agents, including the mandatory docs-sync loop.

## Status of this machine (as discovered)
- Sensor present and unclaimed; fprintd inactive; PAM not configured; `sudo`
  requires a password. See `./scripts/00-preflight.sh` output for the live state.
