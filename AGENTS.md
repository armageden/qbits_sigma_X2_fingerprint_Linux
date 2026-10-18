# AGENTS.md

Central router for any AI agent working in this repository. Read this first.

## Project snapshot
- **What:** make the FocalTech **FTE3600** SPI fingerprint sensor work on a **Qbits Sigma X2** (DMI `S15-4D8G`) laptop running **Garuda Linux** (Arch-based).
- **Stack:** Bash scripts; package manager `pacman` with AUR helper `paru`; build system `meson`/`ninja`; kernel modules via `dkms`.
- **Sensor:** ACPI `FTE3600` -> `spi-FTE3600:00` (modalias `acpi:FTE3600:FTE3600:`); upstream libfprint does not support it; two community routes exist (see `docs/02-drivers/`).
- **Hard constraint:** `sudo` requires a password, so the agent cannot run privileged steps. Generate and `--dry-run` scripts; the operator runs them.

## Commands (verified)
- Recon: `./scripts/00-preflight.sh`
- Install route A (proprietary): `./scripts/10-install-route-a-proprietary.sh`
- Install route B (clean-room): `./scripts/20-install-route-b-cleanroom.sh`
- Firmware (route B): `./scripts/21-extract-firmware.sh`
- Enable authentication: `sudo ./scripts/30-enable-pam.sh`
- Verify: `./scripts/40-verify.sh`
- Rollback: `sudo ./scripts/90-rollback.sh`
- Docs check: `make docs-check` (runs `scripts/docs-check.sh`)

## Knowledge base index
| Folder | Covers | Read when |
|---|---|---|
| `docs/00-how-to/` | task-first recipes | **executing a task? start here** |
| `docs/01-hardware/` | laptop, sensor, SPI/ACPI topology | identifying the sensor |
| `docs/02-drivers/` | routes A and B, kernel modules | choosing or installing a driver |
| `docs/03-firmware/` | firmware catalog and install | capture fails (route B) |
| `docs/04-integration/` | fprintd, PAM, systemd/udev | wiring up authentication |
| `docs/05-operations/` | scripts, verification, troubleshooting, rollback | running, debugging, reverting |
| `docs/99-design-decisions/` | ADR-lite log | understanding why decisions were made |

## Working rules
0. **Git is strictly read-only.** Never run `git commit`, `git push`, `git add`, `git stage`, `git stash`, `git checkout`, `git reset`, or create branches/tags. Only `git status`, `git diff`, `git log`, `git show`. `scripts/install-hooks.sh` only sets `core.hooksPath`; it never stages or commits.
1. **Zero hallucination.** Read the source before documenting any path, flag, symbol, or behaviour. Never guess.
2. **Prove it.** After changing code or scripts, run `./scripts/00-preflight.sh` and `make docs-check`.
3. **Docs-sync (mandatory).** After ANY change to code, config, or scripts, run the pass in `docs/00-how-to/06-sync-docs.md` and end your final response with exactly: `Docs checked/updated: <list of files, or "none required (reason)">`.
4. **In place.** Prefer editing existing files over adding new ones. Never edit anything under `.commandcode/`.
