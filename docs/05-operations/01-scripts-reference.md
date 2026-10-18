**Back:** [00-overview](./00-overview.md)

# Scripts reference

All scripts accept `--dry-run`/`-n` (print the plan without acting) and `--help`.
Shared helpers live in `scripts/lib/common.sh`.

| Script | Runs as | Purpose |
|---|---|---|
| `scripts/00-preflight.sh` | user | read-only recon; verifies the FTE3600 identity |
| `scripts/10-install-route-a-proprietary.sh` | user | install Route A (paru: `focaltech-spi-dkms` + `libfprint-ftexx00`; prompts to replace libfprint) |
| `scripts/11-install-route-a-alt-module.sh` | user | rebuild `focaltech-spi-dkms` from `alt/focal_spi.c` (Alder Lake SPI fix) |
| `scripts/20-install-route-b-cleanroom.sh` | user | install Route B (glue module + patched libfprint) |
| `scripts/21-extract-firmware.sh` | mixed | list, detect or install firmware payloads |
| `scripts/30-enable-pam.sh` | root | insert pam_fprintd.so into system-auth (needs a visible reader; `--force` overrides) |
| `scripts/40-verify.sh` | user | report reader, module, spidev and PAM state |
| `scripts/90-rollback.sh` | root | restore PAM + upstream libfprint, remove artifacts |
| `scripts/docs-check.sh` | user | mechanical documentation validator |
| `scripts/install-hooks.sh` | user | opt-in: set `core.hooksPath` to `.githooks` |

Helper library `scripts/lib/common.sh` provides `log`, `warn`, `err`, `die`,
`parse_dry_run`, `require_root`, `require_user`, `run`, `priv`, `backup_file` and
`confirm`.

The validator's skip list is `scripts/docs-check.ignore`.

## Typical flow
`scripts/00-preflight.sh` -> `scripts/10-install-route-a-proprietary.sh` (or
`scripts/20-install-route-b-cleanroom.sh`) -> `scripts/21-extract-firmware.sh`
(route B only) -> enroll -> `scripts/30-enable-pam.sh` -> `scripts/40-verify.sh`.
