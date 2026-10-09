# System Baseline

This directory records sanitized observations of the current notebook. Baseline files describe what exists; package manifests under `packages/` describe the desired state.

## Capture

- Date: 2026-10-09
- Target: Samsung 300E5M/300E5L notebook
- Scope: hardware summary, explicit package names, failed units, essential session state, and additive desktop services
- Method: read-only local inspection

## Files

- `hardware.md` contains the approved hardware and session fields.
- `services.md` contains failed-unit summaries and the display-manager and network-service states.
- `official-explicit.txt` contains explicitly installed packages found in configured official repositories.
- `foreign-explicit.txt` contains explicitly installed foreign packages. Foreign does not necessarily mean AUR.

The package snapshots contain one sorted, unique package name per line without versions. An empty foreign snapshot means the query returned no explicit foreign packages; it does not mean the query was skipped.

## Collection Commands

```bash
lscpu
lspci -nnk
free -h
lsblk -dn -o NAME,SIZE,TYPE,ROTA,TRAN
hyprctl monitors
uname -r
pacman -Qqen
pacman -Qqem
systemctl --failed --no-legend --plain
systemctl --user --failed --no-legend --plain
systemctl is-enabled sddm.service
systemctl is-active NetworkManager.service
```

Raw command output is inspected but never copied into the repository.

## Sanitization

Exclude credentials, user names, home-directory paths, hostnames, IP and MAC addresses, hardware serial numbers, disk and partition identifiers, filesystem UUIDs, raw logs, environment variables, and personal application data.

Update this baseline only as a documented part of the system change that produced the observed state. Never include raw diagnostic output.
