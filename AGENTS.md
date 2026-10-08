# Repository Contract

This file is mandatory for every human or coding agent working in this repository. The design specification is the authority for project behavior; this contract defines how changes are made safely.

## Priorities

Make decisions in this order:

1. Stability
2. Functionality
3. Performance
4. Visual consistency
5. Portability

Do not trade a higher priority for a lower one. The current notebook is the first target; portability work must not complicate its stable configuration.

## Language

Write all versioned documentation, comments, commit messages, script output, and project-owned interface text in English.

## Safety

- Never perform partial upgrades or run `pacman -Sy` by itself.
- Never pipe a remote script directly into a shell.
- Never install, remove, or replace packages without the active phase plan and user authorization.
- Never delete user data, caches, packages, or configuration without explicit approval.
- Never replace an existing configuration before creating a recoverable, timestamped backup.
- Never restart or shut down after a failed or incomplete operation.
- Show privileged operations before requesting authentication.
- Stop on errors, keep the system usable, and preserve logs and backups.

## Privacy

Never commit credentials, cookies, API tokens, private keys, hostnames, user names, home-directory paths, disk identifiers, filesystem UUIDs, partition UUIDs, device serial numbers, MAC addresses, IP addresses, personal browser data, or raw diagnostic output that may contain them.

Record only the sanitized machine facts required by the project. Inspect generated files before every commit.

## Packages and Services

- Prefer official Arch Linux packages.
- Treat foreign packages as unreviewed until their purpose and source are documented in `packages/README.md`.
- Do not assume every foreign package comes from the AUR.
- Add no background service without documenting its responsibility, startup reason, and resource cost.
- Keep one component per responsibility and avoid duplicate background processes.

## Work Sequence

Every system-facing change follows:

```text
Inspect -> Plan -> Backup -> Apply -> Verify -> Document
```

Do not skip a step. Phase 0 is repository-only work and must not alter the running system configuration.

## Phase Discipline

- Keep one roadmap phase active at a time.
- Implement no later-phase work early.
- Advance a phase only after every acceptance criterion passes.
- Keep machine-specific values separate from shared configuration.
- Use the current phase plan as the implementation checklist.

## Scripts

- Use Bash strict error handling for project scripts.
- Make operations idempotent and safe to run again.
- Provide `--dry-run` for operations that will eventually change the system.
- Discover the repository root dynamically; never hard-code a home directory.
- Preserve logs and backups outside the repository under XDG state directories.
- Report missing commands and invalid state explicitly.
- Keep verification read-only.

## Git

- Use one logical Conventional Commit per change, written in English.
- Run the applicable verification before committing.
- Keep changes local until the user gives explicit upload authorization.
- Never rewrite shared history or force-push without explicit approval.

## Documentation Ownership

- `README.md` describes the project, current phase, and primary entry points.
- `ROADMAP.md` owns phase status, scope, rules, and acceptance criteria.
- `docs/theme.md` owns visual tokens and usage guidance.
- `docs/maintenance.md` owns update, rollback, and recovery guidance.
- `docs/baseline/` owns sanitized observations of the current machine.
- `packages/README.md` owns package-selection policy and foreign-package exceptions.
- The current design spec and implementation plan live under `docs/superpowers/`.

## Current Phase

Active phase: **Phase 0 — Project Foundation**.

- [Design specification](docs/superpowers/specs/2026-10-08-simple-custom-arch-design.md)
- [Phase 0 implementation plan](docs/superpowers/plans/2026-10-08-phase-0-project-foundation.md)
