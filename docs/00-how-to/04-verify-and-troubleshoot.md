**Back:** [00-overview](./00-overview.md)

# How to verify and troubleshoot

## Goal
Prove the reader works, or find out why it does not.

## Steps
1. `./scripts/00-preflight.sh` - identity gate; exits non-zero on a mismatch.
2. `./scripts/40-verify.sh` - reader, module, spidev and PAM state.
3. `fprintd-verify -f right-index-finger "$USER"` - live capture test.
4. On failure: `journalctl -u fprintd -b` and `dmesg`.

## Common fixes
See [../05-operations/03-troubleshooting.md](../05-operations/03-troubleshooting.md).

## Verification
Every check in this recipe is read-only and changes nothing.
