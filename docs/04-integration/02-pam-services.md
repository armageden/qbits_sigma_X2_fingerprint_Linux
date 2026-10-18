**Back:** [00-overview](./00-overview.md)

# PAM services

`/etc/pam.d/system-auth` is the shared include used by every service you care
about, so one insertion enables all of them:

| PAM file | Include chain | Covers |
|---|---|---|
| `/etc/pam.d/sudo` | system-auth | sudo |
| `/etc/pam.d/login` | system-local-login -> system-auth | console/display login |
| `/etc/pam.d/greetd` | system-local-login -> system-auth | greetd login manager |
| `/etc/pam.d/gtklock` | login -> system-auth | lock screen |

## Insertion
`scripts/30-enable-pam.sh` inserts:

```
auth       sufficient   pam_fprintd.so
```

immediately after the `pam_faillock.so preauth` line and before the
`pam_systemd_home.so` / `pam_unix.so` auth lines. This keeps the faillock lockout
preauth intact and does not disturb the `[success=N ...]` jump counters on the
existing lines.

`sufficient` means a successful fingerprint short-circuits the auth stack; a
failure falls through to the password prompt, so password login always remains.

`scripts/30-enable-pam.sh` refuses to modify PAM until fprintd lists a reader for
your user; pass `--force` only if you deliberately want the line without one.

## Verify
`sudo -k && sudo -v` should prompt for a finger first, then accept the password.
