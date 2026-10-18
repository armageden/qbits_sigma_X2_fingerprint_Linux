**Back:** [00-overview](./00-overview.md)

# How to install the clean-room driver (Route B)

## Goal
Make the FTE3600 work with the OSS libfprint driver and its ACPI glue module.

## Steps
1. Confirm the sensor: `./scripts/00-preflight.sh`.
2. Preview: `./scripts/20-install-route-b-cleanroom.sh --dry-run`.
3. Install: `./scripts/20-install-route-b-cleanroom.sh`. This clones the driver
   into `sandbox/src`, installs `glib2-devel`, builds and installs the glue
   module and patched libfprint, and wires systemd device access.
4. Install firmware. With a local Windows driver:
   `sudo ./scripts/21-extract-firmware.sh --detect --input /path/to/ftWbioUmdfDriverV2.dll`.
   Or let it download the pinned Microsoft catalog CAB:
   `sudo ./scripts/21-extract-firmware.sh --chip ft9361 --download`.
5. Verify the module and reader: `./scripts/40-verify.sh`.
6. Enroll: `fprintd-enroll -f right-index-finger "$USER"`.
7. Continue with [03-enable-fingerprint-auth](./03-enable-fingerprint-auth.md).

## Real patterns
Build dependencies match
[../02-drivers/02-route-cleanroom-fte3600.md](../02-drivers/02-route-cleanroom-fte3600.md).
The firmware installer validates size AND SHA-256 and refuses a mismatched chip.

## Verification
`./scripts/40-verify.sh` shows the `fte3600` module and a listed reader.

## Deep dive
[../03-firmware/01-firmware-extraction.md](../03-firmware/01-firmware-extraction.md).
