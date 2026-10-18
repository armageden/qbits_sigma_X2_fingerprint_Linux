# 04 - Integration

How the driver becomes usable authentication: fprintd exposes the reader over
D-Bus, and pam_fprintd.so hooks it into login, lock screen and sudo.

Covered source paths: `scripts/30-enable-pam.sh`, `scripts/40-verify.sh`.

Read this when: you have a working reader and want it wired into the system.

## Contents
- [01-fprintd](./01-fprintd.md) - the daemon, listing and enrolling prints.
- [02-pam-services](./02-pam-services.md) - system-auth and which services it covers.
- [03-systemd-udev](./03-systemd-udev.md) - service units, device access and udev rules.
