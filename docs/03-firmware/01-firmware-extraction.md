**Back:** [00-overview](./00-overview.md)

# Firmware extraction and install

`scripts/21-extract-firmware.sh` wraps the driver's own installer. Verified
catalog (filename under `/usr/lib/firmware/fte3600`):

| Chip | File(s) | Size | Notes |
|---|---|---|---|
| ft9338 | ft9338.bin | 14184 | |
| ft9348 | ft9348.bin | 10312 | |
| ft9361 | ft9361.bin | 10396 | reference hardware |
| ft9536 | ft9536.bin | 11934 | |
| ft9368 | ft9368-app.bin, ft9368-pramboot.bin | 27120, 6096 | installs both |
| ft9365, ft9369, ft9769 | none | - | host configuration only |

## Modes
- `--list` prints the catalog.
- `--detect --input FILE` validates a local Windows DLL/CAB and reports the chip.
- `--chip NAME --download` fetches the pinned Microsoft-catalog CAB and installs.
- `--chip NAME --input FILE` extracts from a local DLL/CAB and installs.

## Payload source
The installer accepts the FocalTech Windows driver (`ftWbioUmdfDriverV2.dll`),
either from a local copy or from the pinned Microsoft Update catalog CAB. Each
candidate offset must pass BOTH size and SHA-256, so a wrong chip fails safely
instead of flashing incorrect data.

## Verify
```
sudo ./scripts/21-extract-firmware.sh --detect --input /path/to/ftWbioUmdfDriverV2.dll
ls -l /usr/lib/firmware/fte3600/
```
