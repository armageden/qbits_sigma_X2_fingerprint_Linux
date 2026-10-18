**Back:** [00-overview](./00-overview.md)

# fprintd

fprintd is the D-Bus daemon that talks to libfprint. It is installed but
disabled/inactive until a driver can claim the FTE3600.

## Commands
- `fprintd-list "$USER"` - list readers and enrolled prints.
- `fprintd-enroll -f right-index-finger "$USER"` - enroll a finger (eight samples).
- `fprintd-verify -f right-index-finger "$USER"` - verify a finger.
- `fprintd-delete "$USER"` - delete enrolled prints.

## Service
`fprintd.service` is a static unit started on demand (D-Bus activation); the
install scripts restart it. `scripts/40-verify.sh` reports active/enabled state.

## Diagnostics
`journalctl -u fprintd -b` shows per-operation errors from the daemon.
