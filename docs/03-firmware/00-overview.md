# 03 - Firmware

Route B loads a small firmware payload into the sensor before capture works.
Payloads are validated by exact size and SHA-256; no vendor code is executed.

Covered source paths: `scripts/21-extract-firmware.sh`.

Read this when: capture fails, or you need to install or identify firmware.

## Contents
- [01-firmware-extraction](./01-firmware-extraction.md) - catalog, detection and install.
