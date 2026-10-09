# Project Scripts

This directory contains focused Bash scripts that coordinate standard Arch Linux and desktop tools. A script is added only when its owning phase can define and test its complete behavior.

## Implemented

- `verify` — run the read-only checks for the active repository and, by default, the current notebook.

Use either mode from any working directory:

```bash
./scripts/verify
./scripts/verify --root PATH
```

The no-argument mode validates required paths, manifests, package roles, sanitized baseline data, the Majula preview, and Git whitespace. It then captures a temporary read-only system snapshot and checks desired packages, approved removals, orphans, commands, failed units, essential services, network, audio, Bluetooth, Intel graphics, Java, launchers, and graphical-session data. It does not start Steam or Prism Launcher, change files, update packages, restart services, or perform a power action.

The `--root PATH` mode performs repository checks only. It never queries the running computer, which makes it suitable for isolated fixtures and review before system changes. Temporary preview and system-snapshot files are removed when verification exits.

## Planned Responsibilities

- `install` — inspect destinations, show a dry run, create timestamped backups, deploy managed paths, verify results, and restore on failure.
- `update-check` — perform the read-only startup check for official and foreign updates.
- `update-system` — show the update summary, perform a complete upgrade after confirmation, verify the result, and gate power actions.
- `lib/phase1-verify.sh` — capture and validate the Phase 1 repository and live-system contracts for `verify`.

Future executables will be introduced by their owning phase with tests and documentation.
