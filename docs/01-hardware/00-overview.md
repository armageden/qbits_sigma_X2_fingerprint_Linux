# 01 - Hardware

The physical machine and the sensor path: what the Qbits Sigma X2 exposes on the
SPI bus and how Linux discovers the FocalTech FTE3600.

Covered source paths: `scripts/00-preflight.sh`.

Read this when: you need to confirm which sensor you have, why it does not appear
in `lsusb`, or how the ACPI/SPI topology is laid out.

## Contents
- [01-qbits-sigma-x2](./01-qbits-sigma-x2.md) - the laptop, DMI identity and OS facts.
- [02-fte3600-sensor](./02-fte3600-sensor.md) - the FocalTech FTE3600 SPI sensor and its profiles.
- [03-spi-acpi-topology](./03-spi-acpi-topology.md) - ACPI device, SPI master, and the unclaimed device.
