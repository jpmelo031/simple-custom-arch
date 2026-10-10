# Maintenance and File Recovery

This guide owns the manual maintenance procedure for the current notebook. The approved package and desktop scope is defined by the [additive desktop design specification](superpowers/specs/2026-10-09-additive-desktop-configuration-design.md) and its [implementation plan](superpowers/plans/2026-10-09-additive-desktop-configuration.md).

Every system-facing change follows `Inspect -> Plan -> Backup -> Apply -> Verify -> Document`. Schedule normal maintenance when there is time to investigate an unexpected result. Never reboot or shut down automatically.

## Weekly Maintenance Procedure

Run these sections in order. Stop after any failed or ambiguous step, preserve the output, and keep the machine running.

### 1. Preflight

1. Read current [Arch Linux news](https://archlinux.org/news/) and handle applicable manual-intervention notices before refreshing package databases.
2. Confirm connectivity with `nmcli general status` and free space with `df -h /`.
3. Confirm the repository is clean and run `./scripts/verify --root "$PWD"`.
4. Inspect `/var/lib/pacman/db.lck` if it exists. Use `ps` or `fuser` to identify the owning package process. Never delete the lock while Pacman or Yay is running.
5. Create a UTC timestamped directory under `~/.local/state/simple-custom-arch/backups/`.
6. Capture explicit official and foreign package names, orphans, failed system and user units, free space, and the running kernel in that directory.

Runtime output can contain local identifiers. Keep complete logs and backups outside Git and record only sanitized results in `docs/baseline/`.

### 2. Complete Official Upgrade

Run one complete official transaction and save its output in the current state directory:

```bash
sudo pacman -Syu
```

Never run `pacman -Sy` by itself. Review provider choices, replacements, removals, and `.pacnew` notices before accepting the transaction. Stop if Pacman proposes an unplanned removal, another kernel, or a boot-configuration change.

### 3. Reviewed Foreign Packages

Only after the official transaction succeeds, update the reviewed foreign packages:

```bash
yay -Sua
```

The reviewed foreign applications used by the desktop are `visual-studio-code-bin` and `zen-browser-bin`. Yay is a local maintenance tool rather than a theme dependency. Stop if Yay proposes an unreviewed package or an unplanned removal. Report temporary build dependencies as orphans without removing them automatically.

### 4. Review `.pacnew` Files

List pending files with `sudo find /etc -type f -name '*.pacnew' -print`. Compare each file with its active counterpart and merge changes deliberately. Back up the active file before changing it, validate the affected component, and retain the `.pacnew` file until the merge is verified.

### 5. Validate the Updated System

Run the complete project verifier:

```bash
./scripts/verify
```

Also confirm `hyprctl configerrors` is empty and these user units are active:

```bash
systemctl --user is-active \
  simple-custom-arch-session.target \
  simple-custom-arch-waybar.service \
  simple-custom-arch-hyprpaper.service \
  simple-custom-arch-hypridle.service \
  simple-custom-arch-cliphist.service \
  dunst.service
```

Inspect the official and foreign transaction output before considering maintenance complete. A package update never authorizes an automatic restart or power action.

### 6. Preserve Recovery Data

Keep the current logs, the latest Hyprland backup, and cached packages after validation. Cache deletion and package cleanup are outside the approved scope. Record only the sanitized package and service state in the repository.

### 7. Recovery and Failure Stops

On failure, stop the sequence, keep the notebook powered on, and preserve the state directory.

- Restore only a configuration file changed by the failed operation, using its timestamped backup.
- Re-run the syntax and service checks that guarded the file before restarting its component.
- Do not disable or mask a failing service merely to make verification pass.
- Do not continue to foreign packages, `.pacnew` merges, cleanup, or a restart after an incomplete official transaction.
- Leave package rollback and boot repair outside this desktop-maintenance procedure.

The additive desktop deployer stores recoverable files below `~/.local/state/simple-custom-arch/backups/`. It does not replace the generated Hyprland configuration or whole configuration directories.

## Restore Contract

- Restore only paths affected by the failed change.
- Preserve the failed state and its logs until the cause is understood.
- Verify restored permissions, file type, and syntax.
- Re-run the checks that guarded the original change.
- Restart a component only when the active plan names that action.
- Keep the backup until the repaired state has remained stable.
- Commit only sanitized conclusions, never raw logs or machine identifiers.

## Logs and State

Project logs, backups, and transient state belong under `~/.local/state/simple-custom-arch/`. Runtime files are local to the notebook and are never committed.
