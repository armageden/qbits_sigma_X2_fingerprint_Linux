**Back:** [00-overview](./00-overview.md)

# 0001 - Driver route selection

## Context
The Qbits Sigma X2 exposes a FocalTech FTE3600 fingerprint sensor over SPI.
Upstream libfprint has no FTE3600 support, so a third-party driver is required.
Two community options exist: a proprietary AUR blob and an OSS clean-room driver.

## Decision
Support both routes and try the proprietary one first.
`scripts/10-install-route-a-proprietary.sh` drives the proprietary path
(FocalTech's own driver, most likely to work on this chip);
`scripts/20-install-route-b-cleanroom.sh` drives the OSS path. Both are wrapped
with `--dry-run` and are reversible via `scripts/90-rollback.sh`.

## Consequence
Maximum chance of a working reader now, with a license-clean fallback and a
documented rollback. Cost: two supported install paths, and a proprietary package
that replaces the system libfprint and may break on rolling updates.
