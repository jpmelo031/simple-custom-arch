# Maintenance and Recovery

This document defines the recovery prerequisites for project-managed changes. It does not replace the Arch Linux installation guide or package documentation.

## Phase 0 Scope

Phase 0 records recovery expectations only. No command in a recovery procedure is executed as part of Phase 0 verification, and the repository does not deploy or replace any system configuration during this phase.

## Before Any Configuration Change

Every system-facing change follows `Inspect -> Plan -> Backup -> Apply -> Verify -> Document`.

Before applying a change:

1. Inspect the current file, service, package, or session state.
2. List every path and command the change will affect.
3. Choose a timestamped directory under `~/.local/state/simple-custom-arch/backups/`.
4. Write the exact restore command before modifying the original path.
5. Define a verification command that distinguishes success from partial failure.
6. Record the result and the backup location without adding runtime data to Git.

The change plan must identify whether it needs root privileges, interrupts the graphical session, or can affect the next boot. A backup is useful only after its contents, ownership, and permissions have been checked.

> **Recovery procedure — do not run during Phase 0:** restore a managed path with a command shaped like `cp -a -- "$backup_path/<relative-path>" "$restore_path"`, using values recorded by the change that created the backup. Verify the restored path before restarting any component.

## TTY Recovery Prerequisites

Before a graphical configuration is deployed, confirm all of these from a non-graphical session:

- A TTY login works with the normal user account.
- Network access can be restored or inspected without Hyprland.
- The repository location is known and accessible.
- `~/.local/state/simple-custom-arch/` is accessible and contains the expected backup.
- The display manager can be inspected without requiring a working compositor.

Useful read-only checks include `systemctl --failed`, `systemctl status sddm.service`, `systemctl --user --failed`, and `nmcli general status`. Record the chosen TTY key combination and repository path in local recovery notes; do not commit machine identifiers or account names.

## Graphical Session Recovery

Stop at diagnosis when a graphical login fails. From a TTY, inspect the display manager, user services, and available Hyprland error output. Identify the smallest affected path and preserve relevant logs before restoring anything.

> **Recovery procedure — do not run during Phase 0:** restore only the affected configuration from its recorded backup. Re-run the configuration-specific verifier, then retry the graphical session. Restart a service or session only when the active change plan names that action and the checks have succeeded.

Do not replace the entire configuration tree to repair one file. Keep the failed version until the cause is understood.

## Package Recovery

Arch package operations must use complete upgrades. Never run `pacman -Sy` by itself and never mix a refreshed package database with an incomplete upgrade. If Pacman reports a lock, first determine whether another package process is active; do not delete the lock blindly.

> **Recovery procedure — do not run during Phase 0:** when the installed system still boots and the package database is healthy, use the planned complete-upgrade procedure and preserve its log. If the installed system cannot boot, start trusted Arch installation media, mount the installed filesystems according to the local recovery notes, enter the system with `arch-chroot`, and repair the package or boot state from there.

Package removal and cache cleanup require a separate reviewed plan. Recovery must not introduce an unreviewed partial upgrade.

## Restore Contract

- Restore only paths affected by the failed change.
- Preserve the failed state and its logs until the cause is documented.
- Verify restored ownership, permissions, file type, and syntax.
- Re-run the same checks that guarded the original change.
- Never restart, shut down, or continue to a dependent step after a failed check.
- Document the recovery result and keep the backup until the repaired state is stable.

## Logs and State

Future project logs, backups, lock files, and transient state belong under `~/.local/state/simple-custom-arch/`. These runtime files are local to the machine and are never committed. Each later script must create only the directories it owns and must print the relevant log or backup path when an operation fails.

## Phase 0 Verification

From the repository root, run:

```bash
./scripts/verify
```

The verifier discovers the project from its own location, so an absolute or otherwise valid path to `scripts/verify` also works from outside the repository. Successful verification prints a `[PASS]` result for every Phase 0 condition and exits with status `0`. A failure prints every detected problem to standard error and exits with status `1`; invalid command-line arguments exit with status `2`. The verifier is read-only apart from one temporary preview image that is removed automatically.
