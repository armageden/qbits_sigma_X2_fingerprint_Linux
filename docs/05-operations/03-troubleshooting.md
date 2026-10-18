**Back:** [00-overview](./00-overview.md)

# Troubleshooting

| Symptom | Likely cause | Action |
|---|---|---|
| no reader in `fprintd-list` | driver not bound / firmware missing | check `scripts/40-verify.sh`; load `focal_spi` or `fte3600`; install firmware |
| `meson setup` fails on `glib_mkenums` | `glib2-devel` missing | `sudo pacman -S glib2-devel` |
| spidev bufsiz below 65536 | stale spidev | reboot; route B saves bufsiz=65536 |
| `modprobe focal_spi` fails | DKMS not built / Secure Boot | `dkms status`; sign the module or disable Secure Boot |
| route A: `can not install conflicting packages with --noconfirm` | pacman must confirm replacing libfprint | re-run the installer without `--noconfirm` and answer `y` (current script does this) |
| route A enroll: `init sensor error!` | default module targets Tiger Lake | run `scripts/11-install-route-a-alt-module.sh`, reload `focal_spi`, retry |
| `30-enable-pam.sh` refuses: no reader | driver not working yet | fix the driver + enroll first; `--force` overrides deliberately |
| enroll loops, poor match | tiny sensor, no calibration | keep password; re-enroll; clean, dry finger |

## Logs
`journalctl -u fprintd -b` for daemon errors; `dmesg` for SPI/GPIO/UIO errors.
