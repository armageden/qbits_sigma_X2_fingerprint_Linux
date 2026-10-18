**Back:** [00-overview](./00-overview.md)

# How to sync the docs after a code change (runbook)

Run this after ANY task that changes code, config or scripts - before you write
your final response. It is the docs-sync pass required by `AGENTS.md`.

## Checklist
1. Inspect the working tree: `git status`, `git diff`, `git diff --cached`.
2. Map every changed path to a subject folder using the table below.
3. Update the affected docs: new, changed or removed symbols, paths, configs and flags.
4. Reverse-coverage check: any new top-level `scripts/*.sh` must be referenced in
   at least one doc (usually `docs/05-operations/01-scripts-reference.md`).
5. ADR-lite: for a significant decision, append a paragraph (Context + Decision +
   Consequence) to `docs/99-design-decisions/`.
6. Validate: run `make docs-check` (i.e. `scripts/docs-check.sh`) and fix all errors.

## Source -> docs mapping
| Changed source | Update |
|---|---|
| `scripts/00-preflight.sh` | `docs/01-hardware/`, `docs/05-operations/01-scripts-reference.md` |
| `scripts/10-install-route-a-proprietary.sh` | `docs/02-drivers/01-route-proprietary-ftexx00.md` |
| `scripts/11-install-route-a-alt-module.sh` | `docs/02-drivers/01-route-proprietary-ftexx00.md`, `docs/99-design-decisions/0002-alder-lake-alt-spi-module.md` |
| `scripts/20-install-route-b-cleanroom.sh` | `docs/02-drivers/02-route-cleanroom-fte3600.md` |
| `scripts/21-extract-firmware.sh` | `docs/03-firmware/01-firmware-extraction.md` |
| `scripts/30-enable-pam.sh` | `docs/04-integration/02-pam-services.md` |
| `scripts/40-verify.sh` | `docs/05-operations/02-verification.md` |
| `scripts/90-rollback.sh` | `docs/05-operations/04-rollback.md` |
| `scripts/docs-check.sh`, `scripts/docs-check.ignore` | this file and `AGENTS.md` |
| `scripts/install-hooks.sh`, `.githooks/pre-commit` | `docs/05-operations/01-scripts-reference.md` |
| `Makefile`, `AGENTS.md`, `README.md` | `AGENTS.md` |

## Finish with
`Docs checked/updated: <list of files, or "none required (reason)">`
