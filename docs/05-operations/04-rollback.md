**Back:** [00-overview](./00-overview.md)

# Rollback

`scripts/90-rollback.sh` (root) restores the stock state:

1. Restores `/etc/pam.d/system-auth` from the newest timestamped backup.
2. Runs the driver's own `setup-fte3600.sh uninstall` if route B sources exist.
3. Removes `libfprint-ftexx00` and `focaltech-spi-dkms` (route A) if present.
4. Reinstalls the upstream `libfprint` package and runs `ldconfig`.
5. Restarts `fprintd.service`.

Enrolled prints are not deleted automatically: run `fprintd-delete "$USER"`. A
reboot drops any module still loaded. The script is safe to re-run; it only
touches artifacts it can find.
