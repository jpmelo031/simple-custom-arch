# Simple Custom Arch Design

**Date:** 2026-10-08
**Status:** Approved design, pending implementation plan

## Purpose

Simple Custom Arch is a personal Arch Linux configuration for a minimal, functional, fast, and reliable Hyprland desktop. The first release targets the current Samsung 300E5M/300E5L notebook. Future portability matters, but it must not complicate the first stable setup.

The project will document and reproduce the system instead of collecting unrelated dotfiles. Every package, service, script, and visual effect must have a clear purpose.

## Priorities

Decisions follow this order:

1. Stability
2. Functionality
3. Performance
4. Visual consistency
5. Portability

Visual polish and automation must not reduce stability. Portability work must not delay a dependable configuration for the current notebook.

## Initial Target

- Device: Samsung 300E5M/300E5L
- Display: 1366x768 at 60 Hz
- Processor: Intel Core i5-7200U
- Graphics: Intel HD Graphics 620
- Memory: 16 GiB
- Storage: 223.6 GiB SSD
- Session: Hyprland on Wayland, launched through SDDM and UWSM
- Primary user applications: Kitty, Rofi, Dolphin, Dunst, VS Code, and Zen Browser

Machine-specific settings will be isolated so the future portability milestone can introduce other hardware profiles without restructuring the shared configuration.

## Repository Language

All versioned content will be written in English, including documentation, comments, commit messages, script output, and user-facing text created by this project.

## Repository Structure

```text
simple-custom-arch/
├── README.md
├── AGENTS.md
├── ROADMAP.md
├── docs/
│   ├── theme.md
│   ├── maintenance.md
│   ├── assets/
│   │   └── theme-preview.svg
│   └── superpowers/
│       └── specs/
├── packages/
│   ├── README.md
│   ├── official.txt
│   └── aur.txt
├── config/
│   ├── hypr/
│   ├── kitty/
│   ├── rofi/
│   ├── dunst/
│   ├── waybar/
│   ├── vscode/
│   └── shell/
├── scripts/
│   ├── lib/
│   ├── install
│   ├── update-check
│   ├── update-system
│   └── verify
└── systemd/
    └── user/
        └── arch-update-check.service
```

The repository will not introduce a custom framework or a full graphical application. Focused Bash scripts will coordinate standard Arch and desktop tools.

## Project Contract

`AGENTS.md` will be the mandatory contract for humans and coding agents working in the repository.

### Repository Rules

- Never commit credentials, cookies, private keys, tokens, hostnames, disk identifiers, or personal browser data.
- Prefer official Arch packages.
- Document the purpose and source of every AUR package in `packages/README.md`.
- Add no background service without documenting its purpose and resource cost.
- Use the approved Majula semantic palette for project-owned interfaces.
- Keep changes local until the user explicitly authorizes a push.
- Use one logical change per Conventional Commit, written in English.

### System Safety Rules

- Never perform partial upgrades or run `pacman -Sy` by itself.
- Never pipe a remote script directly into a shell.
- Never replace an existing configuration before creating a recoverable backup.
- Never delete user data, caches, configurations, or packages without explicit approval.
- Make scripts idempotent and safe to run again.
- Stop on errors and preserve logs and backups.
- Never restart or shut down after an incomplete update.
- Show privileged actions before requesting authentication.

### Work Sequence

Every change follows:

```text
Inspect -> Plan -> Backup -> Apply -> Verify -> Document
```

Only one roadmap phase may be active at a time. A phase advances after its acceptance criteria pass. Work from subsequent phases must not be implemented early.

## Configuration Deployment

The repository is the source of truth for user configuration. A deployment manifest maintained by `scripts/install` maps repository paths to their XDG destinations.

The installer follows this sequence for each managed path:

```text
Inspect destination
-> show planned change
-> create timestamped backup if the destination exists and differs
-> create or update symlink
-> validate the affected component
-> restore the backup on failure
```

### Deployment Rules

- Support `--dry-run` without writing to the filesystem.
- Leave a correct symlink unchanged.
- Report broken links instead of silently replacing them.
- Store backups outside the repository under `~/.local/state/simple-custom-arch/backups/<timestamp>/`.
- Discover the repository root dynamically; do not hard-code `/home/ujuuj`.
- Deploy system files under `/etc` through a separate privileged operation that copies files after backup. System files must not link into the user's home directory.
- Keep machine-specific values in a dedicated Hyprland include rather than shared configuration.

## Majula Visual System

The visual direction is inspired by Majula: dark stone, deep sea tones, aged ivory, and restrained sunset light. The palette is original and uses Dark Souls II only as an atmospheric reference.

### Semantic Palette

| Token | Value | Primary Use |
|---|---:|---|
| `background` | `#0E1114` | Desktop, terminal, and editor backgrounds |
| `surface` | `#171C20` | Waybar, panels, and inactive windows |
| `elevated` | `#20272C` | Rofi, notifications, and focused panels |
| `border` | `#465056` | Dividers and inactive borders |
| `text` | `#DDD6C6` | Primary text |
| `muted` | `#A39B8C` | Secondary text and comments |
| `accent` | `#D1A35C` | Selection and active workspace |
| `ember` | `#E0783E` | Focus, progress, and important actions |
| `info` | `#7899A2` | Links and informational states |
| `success` | `#87996D` | Successful operations |
| `danger` | `#C06452` | Errors and destructive actions |

Primary and secondary text meet readable contrast levels on the selected dark backgrounds. Gold and ember are accents rather than large background colors.

### Theme Preview

`docs/theme.md` will explain the palette and embed `docs/assets/theme-preview.svg`. The SVG will use a 1366x768 artboard and show:

- A 28-pixel Waybar.
- A Kitty terminal with normal commands and update progress.
- A VS Code window with sidebar, editor, and integrated terminal.
- A Rofi update dialog with the three approved actions.
- A Dunst notification.
- Palette swatches labeled with token, value, and usage.

The preview must render in the built-in VS Code Markdown preview without extensions or external assets. The user approves the preview before the palette is applied to real applications.

### Visual Constraints

- Preserve legibility in a dark room.
- Fit all essential controls at 1366x768 without crowding.
- Outer screen gaps and tiled window gaps are 4 pixels at the target resolution.
- Inactive window borders are 1 pixel; the focused border may use 2 pixels when it is drawn without reducing the window's usable content area.
- Application title bars are no taller than 24 pixels. Hide redundant native title bars when the application still provides clear window state and controls.
- Keep the approved system-wide font sizes unchanged when compacting window geometry.
- Keep blur, opacity, and animation conservative for Intel HD 620 graphics.
- Use one shared semantic palette across applications.
- Keep warnings and errors distinguishable without relying on color alone.

### Performance Budget

- Project-added persistent desktop components, excluding Hyprland, portals, audio, and network services, must use no more than 250 MiB combined resident memory after five idle minutes.
- Hyprland blur is limited to one pass with a maximum size of four pixels.
- Routine workspace and window animations must finish within 300 milliseconds.
- Normal workspace switching at the native 60 Hz display mode must show no visible stutter.

## Safe Update Experience

The update experience uses Rofi for the initial choice and Kitty for the package summary, progress, and final report. It starts once per graphical session through a systemd user service associated with `graphical-session.target`.

### Check Flow

```text
Graphical session starts
-> wait up to 60 seconds for network availability
-> acquire a single-instance lock
-> check official updates with checkupdates
-> check AUR updates with yay
-> exit silently when no updates exist
-> show the Majula-themed Rofi menu when updates exist
```

The menu contains exactly:

- `Close`
- `Update & Restart`
- `Update & Shut Down`

Closing the dialog performs no package operation.

### Update Flow

After an update action is selected:

```text
Open themed Kitty window
-> show official and AUR package summary
-> show unread Arch Linux news entries published since the last successful check
-> request final confirmation
-> request privileged authentication
-> run a complete official and AUR upgrade with yay -Syu
-> check the result
-> report .pacnew files, orphans, and failed services
-> run the selected power action only after complete success
```

The implementation must use a supported full-upgrade path. It must never refresh package databases without completing the upgrade.

### Update State and Logs

Runtime state and logs live under:

```text
~/.local/state/simple-custom-arch/update/
```

The updater keeps one log per attempted update, the timestamp of the latest startup check, and the timestamp of the newest acknowledged Arch Linux news entry. Logs must not contain credentials.

### Failure Behavior

- A missing network connection ends the check without showing duplicate dialogs.
- A lock prevents concurrent checker or updater instances.
- Authentication cancellation returns control without a power action.
- A Pacman or AUR failure keeps the Kitty window open with a clear error and log path.
- Any failed verification blocks restart and shutdown.
- Missing Rofi or Kitty produces a journal message and a nonzero exit instead of a silent failure.
- The update scripts expose simulation points so `scripts/verify` can test success and failure paths without performing a real upgrade or power action.

## Roadmap

### Phase 0 — Project Foundation

**Scope**

- Create the project contract, roadmap, and directory structure.
- Record a sanitized baseline of the notebook.
- Create the initial Majula palette and visual preview.
- Document recovery prerequisites.

**Rule:** No system configuration may change before its current state and recovery path are documented.

**Acceptance**

- The repository structure exists.
- Hardware and package baselines contain no sensitive data.
- The preview renders correctly at 1366x768.
- The user approves the initial palette.

### Phase 1 — Base System and Packages

**Scope**

- Review official and AUR packages.
- Define explicit official and AUR package manifests with a documented role for each package.
- Validate firmware, graphics, audio, network, fonts, and maintenance tools.
- Establish the safe manual update procedure.
- Identify redundant and orphaned packages.

**Rule:** Prefer official packages, never perform partial upgrades, and install only packages with a documented purpose.

**Acceptance**

- Every explicit package has a known role.
- Official and AUR manifests reproduce the intended package set.
- Network, audio, and Intel graphics work.
- Failed services are fixed or explicitly documented.
- No package is removed without approval.

### Phase 2 — Hyprland Core

**Scope**

- Split the generated Hyprland configuration into focused files.
- Configure display, input, workspaces, and window behavior.
- Define and document every keybinding.
- Optimize layout for 1366x768.

**Rule:** Every referenced command must be installed and every keybinding must have one clear purpose.

**Acceptance**

- `hyprctl configerrors` reports no errors.
- Terminal, launcher, file manager, and workspace bindings work.
- Volume, brightness, and media keys work.
- Reloading or restarting Hyprland preserves a usable session.

### Phase 3 — Desktop Essentials

**Scope**

- Configure Waybar, Rofi, Dunst, and Kitty.
- Add wallpaper, clipboard, screenshots, lock, and idle behavior.
- Start the Polkit agent correctly.
- Define session autostart in one place.

**Rule:** Use one component per responsibility and avoid duplicate background processes.

**Acceptance**

- A fresh graphical login starts every required component once.
- Lock, idle, clipboard, screenshot, network, and privilege prompts work.
- User services have no unexplained failures.
- Project-added persistent desktop components remain within the 250 MiB idle memory budget.

### Phase 4 — Majula Visual System

**Scope**

- Finalize semantic color tokens.
- Apply them to Hyprland, Waybar, Rofi, Kitty, Dunst, and the lock screen.
- Prepare matching VS Code settings.
- Add fonts, icons, and wallpaper.

**Rule:** Readability and performance take priority over decoration; applications must use the approved semantic palette.

**Acceptance**

- Terminal, editor, and desktop match the approved preview.
- Text remains readable in dark conditions.
- The layout fits 1366x768 without crowding.
- Visual effects meet the documented memory, blur, animation, and responsiveness limits.

### Phase 5 — Safe Update Experience

**Scope**

- Check official and AUR updates after the graphical session starts.
- Remain silent when no updates are pending.
- Display the themed Rofi menu when updates exist.
- Use Kitty for progress and logs.
- Run post-update checks.

**Rule:** Updates require user action, use a complete upgrade, and may restart or shut down only after every step succeeds.

**Acceptance**

- `Close` performs no changes.
- A simulated failure leaves the machine running and preserves the log.
- Official and AUR packages are covered.
- A power action is reachable only from the verified success state.
- Repeated startup checks do not create duplicate dialogs.

### Phase 6 — Development Environment

**Scope**

- Configure Bash, Git, and VS Code.
- Define `config/vscode/extensions.txt` with only extensions that have a documented purpose.
- Integrate the `Projects` directory.
- Document GitHub authentication without storing credentials.

**Rule:** Development configuration must remain reproducible without committing personal credentials or session data.

**Acceptance**

- Git identity and GitHub access work.
- VS Code opens projects correctly under Wayland.
- Terminal and editor use the Majula palette.
- Every extension has a documented purpose.

### Phase 7 — Bootstrap and Recovery

**Scope**

- Create installation, deployment, verification, and restore scripts.
- Back up existing configuration before replacement.
- Provide dry-run behavior.
- Document recovery from a broken graphical session.

**Rule:** Automation must be idempotent, reversible, and explicit about privileged operations.

**Acceptance**

- Running the installer twice produces no unintended changes.
- Shell scripts pass `shellcheck`.
- Backups restore the previous configuration.
- Verification detects missing packages, broken links, and failed services.
- The system can recover from a TTY without Hyprland.

### Future Milestone — Portability

**Scope**

- Separate notebook-specific settings from shared configuration.
- Add optional hardware profiles.
- Test another machine or virtual machine.

**Rule:** Portability work must not complicate or delay the stable notebook configuration.

**Acceptance**

- Shared configuration works without Samsung-specific assumptions.
- Hardware overrides are isolated and documented.
- A second environment completes the bootstrap successfully.

## Verification Strategy

`scripts/verify` will run the checks that apply to the current phase and report each result separately. It must not modify the system.

The complete verification set includes:

- Markdown and repository structure checks.
- Secret and machine-identifier scanning before commits.
- `shellcheck` for every shell script.
- Dry-run verification for deployment operations.
- Symlink target and backup checks.
- Package manifest comparison.
- Hyprland configuration validation through `hyprctl configerrors`.
- Referenced-command checks for keybindings and autostart entries.
- User service state checks.
- Simulated updater success, cancellation, authentication failure, package failure, and blocked power-action paths.
- Visual inspection at 1366x768 against the approved theme preview.

## Documentation Rules

- `README.md` describes the project, current phase, and entry points.
- `ROADMAP.md` contains the phase summaries and acceptance criteria from this design.
- `AGENTS.md` contains the mandatory contract and links to the current phase documentation.
- `docs/theme.md` owns visual tokens and usage guidance.
- `docs/maintenance.md` owns update, rollback, and recovery procedures.
- `packages/README.md` explains package selection and AUR exceptions.
- Documentation changes ship with the configuration or script they describe.

## References

- [Arch Linux system maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [Pacman](https://wiki.archlinux.org/title/Pacman)
- [Hyprland configuration](https://wiki.hypr.land/configuring/)
- [Dark Souls II: Scholar of the First Sin](https://www.bandainamcoent.com/games/dark-souls-ii)
