**Back:** [00-overview](./00-overview.md)

# How to enable fingerprint authentication

## Goal
Use the fingerprint for sudo, login and the lock screen.

## Steps
1. Ensure a reader is visible and a finger is enrolled:
   `fprintd-list "$USER"` then `fprintd-enroll -f right-index-finger "$USER"`.
   The PAM script refuses to run until fprintd lists a reader for your user;
   override with `--force` only if you deliberately want the line without one.
2. Preview the PAM change: `sudo ./scripts/30-enable-pam.sh --dry-run`.
3. Apply: `sudo ./scripts/30-enable-pam.sh`.
4. Test without risking your session: `sudo -k && sudo -v` (fingerprint first,
   password fallback).
5. Confirm state: `./scripts/40-verify.sh`.

## Real patterns
The change is a single line, `auth sufficient pam_fprintd.so`, inserted into
`/etc/pam.d/system-auth` before the `pam_systemd_home`/`pam_unix` lines. The
script backs the file up first and is idempotent.

## Verification
Log in via greetd and unlock gtklock with a finger; the password still works.

## Deep dive
[../04-integration/02-pam-services.md](../04-integration/02-pam-services.md).
