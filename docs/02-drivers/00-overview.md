# 02 - Drivers

Two community routes make the FTE3600 work. Both replace or augment the system
libfprint so fprintd can claim the sensor.

Covered source paths: `scripts/10-install-route-a-proprietary.sh`, `scripts/20-install-route-b-cleanroom.sh`, `scripts/21-extract-firmware.sh`.

Read this when: you are choosing or installing a driver, or need to know what a
kernel module does.

## Contents
- [01-route-proprietary-ftexx00](./01-route-proprietary-ftexx00.md) - AUR proprietary blob (primary attempt).
- [02-route-cleanroom-fte3600](./02-route-cleanroom-fte3600.md) - OSS clean-room driver (fallback).
- [03-kernel-modules-dkms](./03-kernel-modules-dkms.md) - focal_spi vs fte3600, DKMS and spidev.
