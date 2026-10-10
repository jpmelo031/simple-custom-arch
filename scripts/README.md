# Project Scripts

This directory contains focused Bash scripts that coordinate standard Arch Linux and desktop tools. A script is added only when its owning phase can define and test its complete behavior.

## Implemented

- `verify` — run the read-only checks for the active repository and, by default, the current notebook.
- `install-desktop` — add the project-owned desktop files without replacing existing configuration directories.
- `apply-theme` — back up and apply the desktop-wide dark, icon, and cursor preferences.

Use either mode from any working directory:

```bash
./scripts/verify
./scripts/verify --root PATH
./scripts/install-desktop --dry-run
./scripts/install-desktop --apply
./scripts/apply-theme --dry-run
./scripts/apply-theme --apply
```

The no-argument mode validates required paths, manifests, package roles, sanitized baseline data, the Majula preview, and Git whitespace. It then captures a temporary read-only system snapshot and checks desired packages, reported orphans, desktop commands, documented failed units, essential services, network, audio, Bluetooth, and graphical-session data. It does not change files, update packages, restart services, or perform a power action.

The `--root PATH` mode performs repository checks only. It never queries the running computer, which makes it suitable for isolated fixtures and review before system changes. Temporary preview and system-snapshot files are removed when verification exits.

`install-desktop` links individual application files and user units, appends the Majula Lua module import when it is absent, and renders the project wallpaper. It creates a timestamped backup before changing an existing Hyprland file, stops on unrelated destinations, and is safe to run again. Use `--dry-run` before `--apply`.

`apply-theme` previews or applies the GNOME interface preferences consumed by GTK applications and portals. Apply mode records every changed value under the XDG state backup directory and restores earlier values if an operation fails.

`lib/phase1-verify.sh` captures and validates the package and live-system contracts used by `verify`.

## Planned Responsibilities

- `install` — coordinate future full-system bootstrap and restore behavior beyond the current additive desktop deployment.
- `update-check` — perform the read-only startup check for official and foreign updates.
- `update-system` — show the update summary, perform a complete upgrade after confirmation, verify the result, and gate power actions.

Future executables will be introduced by their owning phase with tests and documentation.
