**Back:** [00-overview](./00-overview.md)

# How to install the proprietary driver (Route A)

## Goal
Make fprintd see the FTE3600 using FocalTech's own driver. Try this first.

## Steps
1. Confirm the sensor: `./scripts/00-preflight.sh` (expect FTE3600, unclaimed).
2. Preview: `./scripts/10-install-route-a-proprietary.sh --dry-run`.
3. Install, as your normal user (paru elevates itself):
   `./scripts/10-install-route-a-proprietary.sh`. When pacman asks to remove the
   conflicting `libfprint` package, answer `y` (the script does not use
   `--noconfirm` for this step, since pacman refuses conflicting installs then).
4. Load the module if it is not already: `sudo modprobe focal_spi`.
5. Check: `fprintd-list "$USER"` should list the FTE3600 reader.
6. Enroll: `fprintd-enroll -f right-index-finger "$USER"`.
   On Alder Lake (this laptop) an `init sensor error!` here means the module
   targets Tiger Lake: run `./scripts/11-install-route-a-alt-module.sh` and retry.
7. Continue with [03-enable-fingerprint-auth](./03-enable-fingerprint-auth.md).

## Real patterns
The script is idempotent: it skips packages already installed and backs up
`/etc/pam.d/system-auth` before any change. `--dry-run` prints every command it
would run.

## Verification
`fprintd-list "$USER"` lists a device and `./scripts/40-verify.sh` reports a
loaded `focal_spi` module.

## Deep dive
[../02-drivers/01-route-proprietary-ftexx00.md](../02-drivers/01-route-proprietary-ftexx00.md).
