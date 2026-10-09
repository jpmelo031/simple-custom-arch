# Maintenance and Recovery

This guide owns the manual maintenance and file-level recovery procedure for the target notebook. It implements the [Phase 1 design specification](superpowers/specs/2026-10-08-phase-1-base-system-design.md) and [Phase 1 implementation plan](superpowers/plans/2026-10-08-phase-1-base-system.md).

Every system-facing change follows `Inspect -> Plan -> Backup -> Apply -> Verify -> Document`. Schedule normal maintenance once per week when there is time to investigate an unexpected result. Never reboot or shut down automatically.

## Weekly Maintenance Procedure

Run the sections in order. Stop after any failed or ambiguous step, preserve the log, and keep the machine running. Do not continue to a dependent section merely because an earlier command changed part of the system.

### 1. Preflight

1. Read current [Arch Linux news](https://archlinux.org/news/) and handle any applicable manual-intervention notice before refreshing package databases.
2. Confirm full connectivity with `nmcli general status` and enough free space with `df -h /`.
3. Confirm both the regular and LTS kernels are installed and the Limine fallback entry is available.
4. Confirm the repository is clean and its repository-only checks pass with `./scripts/verify --root "$PWD"`.
5. Run `checkupdates` for a safe preview. Its exit status may indicate that updates are available; it must not alter the live sync database.
6. Inspect `/var/lib/pacman/db.lck` if it exists. Use `ps` or `fuser` to identify the owning package process. Never delete the lock while Pacman or Yay is running.
7. Create a UTC timestamped directory under `~/.local/state/simple-custom-arch/backups/`, and point `~/.local/state/simple-custom-arch/phase1-current` to it.
8. Capture explicit official and foreign packages, orphans, failed system and user units, free space, the running kernel, and package-cache size in that directory.
9. Back up `/etc/pacman.conf`, `/etc/mkinitcpio.conf`, `/etc/mkinitcpio.d/`, and the active Limine configuration while preserving ownership and modes.

Runtime output can contain local identifiers. Keep the complete logs and backups outside Git and record only sanitized results in `docs/baseline/`.

### 2. Complete Official Upgrade

Run one complete official transaction in a TTY and save its output in the current state directory:

```bash
sudo pacman -Syu
```

Never run `pacman -Sy` by itself. After package databases are refreshed, an interrupted transaction leaves the system at a critical boundary: diagnose the error and finish the complete upgrade before any unrelated package action. Do not restore an older Pacman configuration in the middle of that boundary.

Review provider choices, replacements, removals, and `.pacnew` notices before accepting the transaction. Reject an unplanned removal or provider change and revise the active plan before continuing.

### 3. Reviewed Foreign Packages

Only after the official transaction succeeds, update the reviewed foreign packages separately:

```bash
yay -Sua
```

The reviewed set is `visual-studio-code-bin`, `yay`, and `zen-browser-bin`. Stop if Yay proposes an unreviewed package, replaces a desired package, or expands a removal. A Yay rebuild may install Go temporarily; report it as an orphan for a later reviewed cleanup.

### 4. Review `.pacnew` Files

Inspect Pacman's recorded output, then review configuration differences:

```bash
sudo DIFFPROG=nvim pacdiff
```

Merge changes deliberately. Do not replace an active configuration wholesale, and do not delete a `.pacsave` until the restored service and syntax checks pass. If a merge affects boot, networking, authentication, or package management, validate that area before proceeding.

### 5. Validate the Updated System

Run the complete project verifier:

```bash
./scripts/verify
```

Also inspect the current kernel and the package transaction log. The verifier must confirm the desired explicit package set, approved removals, orphan state, failed-unit exception, essential services, full network connectivity, PipeWire audio, Bluetooth, Intel graphics providers, Java, launchers, and graphical-session data.

When a kernel or boot configuration changed, inspect both regular and LTS artifacts and the Limine entries before any manual reboot. Launch Steam and Prism Launcher one at a time when the active phase calls for their graphical smoke test; sign-in and downloads are outside this procedure.

### 6. Retain the Package Cache

Clean the cache only after every validation passes:

```bash
sudo paccache -rk2
```

This retains two cached versions of installed packages. Preserve the command output in the current state directory, then run `./scripts/verify` again. Skip cache cleanup when any earlier check failed because retained packages may be needed during diagnosis.

### 7. Recovery and Failure Stops

On failure, stop the sequence, keep the notebook powered on, and preserve the state directory. Identify the smallest affected component before restoring anything.

- Restore only a configuration file changed by the failed operation, using its timestamped backup and recorded owner and mode.
- Re-run the syntax and service checks that guarded the file before restarting its component.
- Use cached package rollback only when Arch guidance for the specific failure supports it. Arbitrary partial downgrades are not a general recovery method.
- Use the regular or LTS kernel entry when one kernel regresses. Keep trusted Arch installation media available for `arch-chroot` recovery when neither entry boots.
- Do not disable or mask a failing service merely to make verification green.
- Do not continue to foreign packages, `.pacnew` merges, cache cleanup, or a reboot after an incomplete official transaction.

The root filesystem uses ext4. ext4 does not provide a filesystem snapshot for this procedure, so recovery relies on file backups, two retained package versions, a working fallback kernel, TTY access, and trusted installation media.

## TTY Recovery Prerequisites

Before deploying graphical configuration in a later phase, confirm from a non-graphical session that a normal TTY login works, NetworkManager can be inspected, the repository and current state directory are accessible, and SDDM can be diagnosed without a working compositor.

Useful read-only checks include `systemctl --failed`, `systemctl status sddm.service`, `systemctl --user --failed`, and `nmcli general status`. Keep the chosen TTY key combination and any machine-specific path in local recovery notes rather than Git.

## Restore Contract

- Restore only paths affected by the failed change.
- Preserve the failed state and its logs until the cause is understood.
- Verify restored ownership, permissions, file type, and syntax.
- Re-run the checks that guarded the original change.
- Restart a component only when the active plan names that action.
- Keep the backup until the repaired state has remained stable.
- Commit only sanitized conclusions, never raw logs or machine identifiers.

## Logs and State

Project logs, backups, and transient state belong under `~/.local/state/simple-custom-arch/`. Each operation owns a timestamped subdirectory and must surface that location when it fails. These runtime files are local to the notebook and are never committed.
