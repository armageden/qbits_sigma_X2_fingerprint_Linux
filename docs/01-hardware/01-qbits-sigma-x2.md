**Back:** [00-overview](./00-overview.md)

# Qbits Sigma X2 (S15-4D8G)

## Identity (verified on this machine)
- Vendor: Qbits Technologies
- DMI model: `S15-4D8G`; product version `Default string`
- BIOS: `GLX258-A V0.0.10`
- Platform: Intel Alder Lake-P (12th gen)

Read from `/sys/class/dmi/id/*`; `scripts/00-preflight.sh` prints these values.

## Operating system
- Garuda Linux (Arch-based, rolling); `ID=garuda`, `ID_LIKE=arch`
- Running kernel: `7.2.9-zen1-1-zen`; an LTS `6.18.55-1-lts` is also installed
- Package manager: `pacman`; AUR helper `paru`
- Login: `greetd`; lock screen: `gtklock`

## Why this matters
The kernel choice pins the header package DKMS builds against
(`linux-zen-headers`), and the login/lock stack determines which PAM services
must be enabled. See [03-spi-acpi-topology](./03-spi-acpi-topology.md) and
[../04-integration/02-pam-services.md](../04-integration/02-pam-services.md).
