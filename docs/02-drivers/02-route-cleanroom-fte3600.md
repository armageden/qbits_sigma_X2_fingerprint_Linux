**Back:** [00-overview](./00-overview.md)

# Route B - clean-room FTE3600 driver (OSS)

Fallback and license-clean option: an LGPL-2.1 libfprint driver plus a GPL kernel
glue module from `SamSeven777/libfprint-fte3600`. Driven by
`scripts/20-install-route-b-cleanroom.sh`.

## Build dependencies (Arch)
base-devel, pkgconf, meson, ninja, python, glib2, glib2-devel, libgusb, libgudev,
systemd, plus `linux-zen-headers` for the running kernel.

> `glib2-devel` is required because `glib-mkenums` lives there on Garuda/Arch.
> Without it `meson setup` fails with: "tool variable 'glib_mkenums' contains
> erroneous value".

## Components installed
- Kernel glue module `fte3600` (DKMS, version 0.2) - ACPI reset/IRQ pairing, no SPI transfers.
- udev rules `70-fte3600-acpi-spidev.rules` and modprobe conf `fte3600-acpi-spidev.conf`.
- `spidev` with `bufsiz=65536` (the driver requires at least 65536).
- libfprint built with `-Ddrivers=fte3600`.
- A systemd drop-in `10-fte3600-acpi-spidev.conf` granting fprintd device access.

## Firmware
Not bundled; install it with `scripts/21-extract-firmware.sh`. See
[../03-firmware/00-overview.md](../03-firmware/00-overview.md).

## Caveat
Upstream hardware confirmation is limited to FT9361 on One-Netbook A1; suspend
and resume are unverified. Keep password access.
