**Back:** [00-overview](./00-overview.md)

# Route A - proprietary FTEXX00 blob (AUR)

Primary attempt: it uses FocalTech's own driver, so it is the most likely to work
on this specific chip. Driven by `scripts/10-install-route-a-proprietary.sh`.

## Packages
- `focaltech-spi-dkms` (GPL-2.0) - DKMS module `focal_spi` built from
  `vobademi/FTEXX00-Ubuntu`; depends on `dkms` and `linux-headers`.
- `libfprint-ftexx00` (license: unknown) - extracts a prebuilt Ubuntu `.deb`,
  installs `libfprint-2.so.2.0.0` into `/usr/lib`, provides `libfprint` and
  **conflicts with** it. Ships a udev rule and a systemd override containing
  `DeviceAllow=/dev/focal_moh_spi rw`.

## What it changes
- Replaces the system `libfprint` package (pacman tracks it as a provider).
- Installs `/etc/systemd/system/fprintd.service.d/override.conf`.
- Loads the `focal_spi` module, which creates `/dev/focal_moh_spi`.

## Installing
`scripts/10-install-route-a-proprietary.sh` installs `focaltech-spi-dkms` first,
then `libfprint-ftexx00`. Because the latter conflicts with the installed
`libfprint`, pacman asks to remove it - answer `y`. The script deliberately does
not pass `--noconfirm` for that step, because pacman refuses conflicting installs
under `--noconfirm` ("can not install conflicting packages with --noconfirm").

## Alder Lake (12th gen) hosts
If enrollment fails with `init sensor error!` and `journalctl -u fprintd -b` shows
`configure spi mode failed(0)` or `got undesired device id: 0x0000`, the default
module targets Tiger Lake, not this CPU. Rebuild it from the upstream
`alt/focal_spi.c` with `scripts/11-install-route-a-alt-module.sh`, then reload the
module. See [../99-design-decisions/0002-alder-lake-alt-spi-module.md](../99-design-decisions/0002-alder-lake-alt-spi-module.md).

## Risk
The upstream source repo was taken down (DMCA) and the blob is proprietary.
Rolling updates can re-flag the replaced libfprint. Use `scripts/90-rollback.sh`
to return to stock.
