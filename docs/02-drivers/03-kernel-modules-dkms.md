**Back:** [00-overview](./00-overview.md)

# Kernel modules, DKMS and spidev

| Route | Module | Companion node | Built by |
|---|---|---|---|
| A | `focal_spi` | `/dev/focal_moh_spi` | `focaltech-spi-dkms` (DKMS) |
| B | `fte3600` | spidev + IRQ-only UIO `fte3600-irq` | `kernel/fte3600` (DKMS v0.2) |

## DKMS
Both modules are DKMS-managed, so they rebuild against `linux-zen-headers` after
kernel upgrades. Inspect with `dkms status`; rebuild with `dkms build` then
`dkms install`.

## spidev buffer
Route B requires `spidev` with a 64 KiB buffer. The driver's `setup-fte3600.sh`
runs `modprobe spidev bufsiz=65536` and saves `options spidev bufsiz=65536` in
`fte3600-acpi-spidev.conf`. Check the live value with
`cat /sys/module/spidev/parameters/bufsiz` (needs at least 65536).

## Load state
`scripts/40-verify.sh` prints which module, if any, is loaded. fprintd only sees
a reader when `focal_spi` (route A) or the `fte3600` glue (route B) is loaded and
firmware is present.
