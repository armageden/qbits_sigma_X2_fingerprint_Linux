**Back:** [00-overview](./00-overview.md)

# 0002 - Alder Lake needs the alt SPI module

## Context
The default `focaltech-spi-dkms` source (`focal_spi.c`) drives the FTE3600 with
SPI settings intended for Tiger Lake (11th gen). On this Alder Lake (12th gen)
host the sensor probes and fprintd lists the reader, but enrollment fails:
`journalctl -u fprintd -b` shows `configure spi mode failed(0)` and
`got undesired device id: 0x0000`, surfaced to the user as `init sensor error!`.

## Decision
Build `focaltech-spi-dkms` from the upstream `alt/focal_spi.c`, which sets
`SPI_MODE_0` and `bits_per_word=8`, bounds the clock, and calls `spi_setup()`
explicitly. `scripts/11-install-route-a-alt-module.sh` patches the PKGBUILD to
copy `alt/focal_spi.c` over the default and reinstalls the module.

## Consequence
Enrollment works on Alder Lake. Cost: the package is locally patched, so a future
AUR update must re-apply the patch; the script is idempotent and re-runnable.
