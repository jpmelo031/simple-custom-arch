# Project Scripts

This directory is reserved for focused Bash scripts that coordinate standard Arch Linux and desktop tools. Phase 0 creates no placeholder executables.

## Planned Responsibilities

- `install` — inspect destinations, show a dry run, create timestamped backups, deploy managed paths, verify results, and restore on failure.
- `update-check` — perform the read-only startup check for official and foreign updates.
- `update-system` — show the update summary, perform a complete upgrade after confirmation, verify the result, and gate power actions.
- `verify` — run the checks that apply to the active roadmap phase without modifying the system.
- `lib/` — hold small shared functions only after at least two scripts need them.

Each executable will be introduced by its owning phase with tests and documentation.
