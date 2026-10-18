**Back:** [00-overview](./00-overview.md)

# FocalTech FTE3600 SPI sensor

The fingerprint reader on this laptop is a **FocalTech FTE3600** attached over
**SPI**, not USB. That is why it never appears in `lsusb` and why upstream
libfprint does not see it.

## How it is exposed
- ACPI device with HID `FTE3600`: `/sys/bus/acpi/devices/FTE3600:00`
- Enumerated SPI device: `/sys/bus/spi/devices/spi-FTE3600:00`
- modalias: `acpi:FTE3600:FTE3600:`
- Kernel driver: **none bound** (the device is unclaimed).

## Driver profiles
The clean-room driver implements FT9338, FT9348, FT9361, FT9536, FT9365, FT9368,
FW9369 and FT9769. The ACPI name is only `FTE3600`, so the exact variant is
resolved by firmware validation, not by the ACPI name.

## Support status
Upstream libfprint 1.94.x supports only ELAN7001/ELAN70A1 over SPI, so the FTE3600
needs a third-party driver. Two exist - see
[../02-drivers/00-overview.md](../02-drivers/00-overview.md).
