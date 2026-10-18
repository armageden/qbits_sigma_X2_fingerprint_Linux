**Back:** [00-overview](./00-overview.md)

# How to roll back

## Goal
Return the machine to stock: upstream libfprint and no fingerprint PAM.

## Steps
1. Preview: `sudo ./scripts/90-rollback.sh --dry-run`.
2. Apply: `sudo ./scripts/90-rollback.sh`.
3. Optionally clear prints: `fprintd-delete "$USER"`.
4. Reboot to drop any module still loaded.

## Real patterns
Rollback restores the newest `/etc/pam.d/system-auth` backup and reinstalls the
upstream `libfprint` package via pacman.

## Verification
`./scripts/40-verify.sh` shows no reader and no pam_fprintd entry.

## Deep dive
[../05-operations/04-rollback.md](../05-operations/04-rollback.md).
