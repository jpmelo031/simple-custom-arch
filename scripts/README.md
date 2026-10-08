# Project Scripts

This directory contains focused Bash scripts that coordinate standard Arch Linux and desktop tools. A script is added only when its owning phase can define and test its complete behavior.

## Implemented

- `verify` — run the read-only checks for the active repository foundation. It validates required paths, sanitized baseline data, package snapshot ordering, the Majula palette and preview, and Git whitespace when available. Run it as `./scripts/verify` from the repository or use `--root PATH` for an isolated test fixture.

## Planned Responsibilities

- `install` — inspect destinations, show a dry run, create timestamped backups, deploy managed paths, verify results, and restore on failure.
- `update-check` — perform the read-only startup check for official and foreign updates.
- `update-system` — show the update summary, perform a complete upgrade after confirmation, verify the result, and gate power actions.
- `lib/` — hold small shared functions only after at least two scripts need them.

Future executables will be introduced by their owning phase with tests and documentation.
