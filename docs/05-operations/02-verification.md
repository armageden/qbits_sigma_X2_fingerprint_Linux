**Back:** [00-overview](./00-overview.md)

# Verification

Run `scripts/00-preflight.sh` (identity gate) then `scripts/40-verify.sh` (state).

## Success criteria
1. `scripts/00-preflight.sh` exits 0 and prints `bound driver : unclaimed`.
2. `fprintd-list "$USER"` lists a device (the FTE3600 reader).
3. `fprintd-enroll -f right-index-finger "$USER"` completes eight samples.
4. `fprintd-verify -f right-index-finger "$USER"` reports Match.
5. After `scripts/30-enable-pam.sh`, `sudo -k && sudo -v` prompts a finger first.
6. greetd login and gtklock unlock accept the finger; password still works.

## Docs system
`make docs-check` (which runs `scripts/docs-check.sh`) must exit 0 for a
consistent knowledge base.
