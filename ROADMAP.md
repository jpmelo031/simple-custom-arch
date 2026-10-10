# Project Roadmap

This roadmap turns the approved design into ordered, verifiable phases. Only one phase is active at a time. A phase becomes complete after every acceptance criterion passes; later-phase work does not begin early.

## Phase Sequence

### Phase 0 — Project Foundation — Complete

**Status:** Complete

**Goal:** Establish a safe, reviewable repository foundation before changing the running system.

**Scope:**

- Create the project contract, roadmap, and directory structure.
- Record a sanitized notebook baseline.
- Preserve the approved Majula palette and visual preview.
- Document recovery prerequisites.
- Add read-only Phase 0 verification.

**Rule:** No system configuration may change before its current state and recovery path are documented.

**Acceptance:**

- The repository structure exists.
- Hardware and package baselines contain no sensitive data.
- The preview renders correctly at 1366x768.
- The user-approved palette remains unchanged.
- The Phase 0 verifier passes without modifying the system.

### Phase 1 — Base System and Packages — Complete

**Status:** Complete

The user-approved reduced package scope is installed and verified. It deliberately excludes Steam, Java, a second kernel, boot configuration work, package cleanup, and optional diagnostics from the earlier draft.

**Goal:** Define and validate the direct dependencies required by the deployed desktop.

**Scope:**

- Review official and foreign desktop dependencies.
- Define official and foreign manifests with a documented role for each direct dependency.
- Validate the commands, fonts, audio controls, and desktop services used by the configuration.
- Establish the safe manual update procedure.
- Report redundant and orphaned packages without removing them.
- Preserve the existing regular kernel and boot configuration.

**Rule:** Prefer official packages, never perform partial upgrades, and install only packages with a documented purpose.

**Acceptance:**

- Every dependency in the manifests has a known role.
- Official and foreign manifests reproduce the direct theme dependency set.
- Network, audio, and Intel graphics work.
- Failed services are fixed or explicitly documented.
- No package is removed without approval.
- The approved desktop commands are available without an additional kernel or gaming stack.

**Execution references:**

- [Phase 1 design specification](docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md)
- [Phase 1 implementation plan](docs/superpowers/plans/2026-10-08-phase-1-base-system.md)
- [Additive desktop design specification](docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md)
- [Additive desktop implementation plan](docs/superpowers/plans/2026-10-09-additive-desktop-configuration.md)

### Phase 2 — Hyprland Core — Complete

**Status:** Complete

**Goal:** Create a stable, compact Hyprland session for the target display and hardware.

**Scope:**

- Preserve the generated Hyprland configuration and load one focused project module.
- Configure display, input, workspaces, and window behavior.
- Define and document every keybinding.
- Optimize the layout for 1366x768.

**Rule:** Every referenced command must be installed and every keybinding must have one clear purpose.

**Acceptance:**

- `hyprctl configerrors` reports no errors.
- Terminal, launcher, file manager, and workspace bindings work.
- Volume, brightness, and media keys work.
- Reloading or restarting Hyprland preserves a usable session.

### Phase 3 — Desktop Essentials — Complete

**Status:** Complete

**Goal:** Add one reliable component for each essential desktop responsibility.

**Scope:**

- Configure Waybar, Rofi, Dunst, and Kitty.
- Add wallpaper, clipboard, screenshots, lock, and idle behavior.
- Start the Polkit agent correctly.
- Define session autostart in one place.

**Rule:** Use one component per responsibility and avoid duplicate background processes.

**Acceptance:**

- A fresh graphical login starts every required component once.
- Lock, idle, clipboard, screenshot, network, and privilege prompts work.
- User services have no unexplained failures.
- Project-added persistent desktop components remain within the 250 MiB idle memory budget.

### Phase 4 — Majula Visual System — Complete

**Status:** Complete

**Goal:** Apply the approved Majula visual language consistently across the desktop.

**Scope:**

- Finalize semantic color tokens.
- Apply them to Hyprland, Waybar, Rofi, Kitty, Dunst, and the lock screen.
- Prepare matching VS Code settings.
- Add fonts, icons, and wallpaper.

**Rule:** Readability and performance take priority over decoration; applications must use the approved semantic palette.

**Acceptance:**

- Terminal, editor, and desktop match the approved preview.
- Text remains readable in dark conditions.
- The layout fits 1366x768 without crowding.
- Visual effects meet the documented memory, blur, animation, and responsiveness limits.

### Phase 5 — Safe Update Experience — Not started

**Status:** Not started

**Goal:** Provide a user-controlled, verified full-upgrade flow with safe power actions.

**Scope:**

- Check official and AUR updates after the graphical session starts.
- Remain silent when no updates are pending.
- Display the themed Rofi menu when updates exist.
- Use Kitty for package summaries, progress, logs, and results.
- Run post-update checks before any power action.

**Rule:** Updates require user action, use a complete upgrade, and may restart or shut down only after every step succeeds.

**Acceptance:**

- `Close` performs no changes.
- A simulated failure leaves the machine running and preserves the log.
- Official and AUR packages are covered.
- A power action is reachable only from the verified success state.
- Repeated startup checks do not create duplicate dialogs.

### Phase 6 — Development Environment — Not started

**Status:** Not started

**Goal:** Make the shell, Git, editor, and project workflow reproducible without personal credentials.

**Scope:**

- Configure Bash, Git, and VS Code.
- Define a documented VS Code extension list.
- Integrate the `Projects` directory.
- Document GitHub authentication without storing credentials.

**Rule:** Development configuration must remain reproducible without committing personal credentials or session data.

**Acceptance:**

- Git identity and GitHub access work.
- VS Code opens projects correctly under Wayland.
- Terminal and editor use the Majula palette.
- Every extension has a documented purpose.

### Phase 7 — Bootstrap and Recovery — Not started

**Status:** Not started

**Goal:** Automate installation, deployment, verification, backup, and restoration safely.

**Scope:**

- Create installation, deployment, verification, and restore scripts.
- Back up existing configuration before replacement.
- Provide dry-run behavior.
- Document recovery from a broken graphical session.

**Rule:** Automation must be idempotent, reversible, and explicit about privileged operations.

**Acceptance:**

- Running the installer twice produces no unintended changes.
- Shell scripts pass `shellcheck`.
- Backups restore the previous configuration.
- Verification detects missing packages, broken links, and failed services.
- The system can recover from a TTY without Hyprland.

### Future Milestone — Portability — Not started

**Status:** Not started

**Goal:** Reuse the shared configuration on another machine without weakening the notebook setup.

**Scope:**

- Separate notebook-specific settings from shared configuration.
- Add optional hardware profiles.
- Test another machine or virtual machine.

**Rule:** Portability work must not complicate or delay the stable notebook configuration.

**Acceptance:**

- Shared configuration works without Samsung-specific assumptions.
- Hardware overrides are isolated and documented.
- A second environment completes the bootstrap successfully.
