# Additive Desktop Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the minimal packages, Majula application configuration, numeric-keypad controls, and graphical-session services needed for a complete desktop without replacing existing configuration or changing boot recovery.

**Architecture:** Versioned files provide each new application configuration and user service. An idempotent Bash deployer adds individual links, appends one Lua module import to the existing Hyprland configuration, renders the wallpaper, and stops on conflicting destinations. Package installation remains a separate full official transaction followed by the reviewed VS Code foreign package.

**Tech Stack:** Bash 5, Hyprland Lua configuration, systemd user units, Waybar JSONC/CSS, Rofi Rasi, Kitty, Dunst, Hyprlock, Hypridle, Hyprpaper, VS Code JSON, Pacman, Yay

**Spec:** `docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md`

**Implementation status:** Complete on 2026-10-09

## Global Constraints

- Preserve the existing `~/.config/hypr/hyprland.lua`; append one idempotent `require("majula")` statement only.
- Add individual files and links; never replace an existing configuration directory.
- Back up an existing file before changing it and stop on unexpected destination conflicts.
- Install only the nine official packages and one reviewed foreign package named by the spec.
- Perform a complete official upgrade; never run `pacman -Sy` alone.
- Do not install Steam, Prism Launcher, Java, 32-bit graphics providers, `linux-lts`, or another kernel.
- Do not change Limine, mkinitcpio, UKIs, `/boot`, or firmware configuration.
- Do not remove any package, file, cache, or personal configuration.
- Do not restart, suspend, shut down, or reboot automatically.
- Keep all versioned content and project-owned interface text in English.

## Review Focus

- **Unexpected destination:** deployment must stop and name an unrelated file, directory, or broken link instead of replacing it; Task 3 tests every destination state.
- **Repeated deployment:** a second apply must leave one Hyprland import, correct links, and no new backup; Task 3 tests idempotency.
- **Num Lock state:** numeric-keypad actions must use physical XKB keycodes rather than keypad symbols; Task 2 checks all eighteen workspace binds and nine control positions.
- **Session duplication:** project services must use unique names and one target, while live verification must reject multiple component processes; Tasks 2 and 5 cover static and live state.
- **Package expansion:** the transaction request must contain only the approved packages, and no removal or boot path may enter the command; Tasks 1 and 4 verify the exact set.

---

### Task 1: Align the Desired Package Model With the Approved Scope

**Files:**
- Modify: `packages/official.txt`
- Modify: `packages/README.md`
- Modify: `tests/phase1-manifests.sh`
- Modify: `scripts/lib/phase1-verify.sh`
- Modify: `tests/phase1-verify.sh`

**Interfaces:**
- Consumes: the package scope and exclusions from the additive desktop design
- Produces: the desired explicit package model and repository/live checks used by installation and final verification

- [x] **Step 1: Change the manifest tests to require the additive desktop set**

Keep the existing desired installed base, add `cliphist`, `hypridle`, `hyprlock`, `hyprpaper`, `waybar`, and `wl-clipboard`, and remove `github-cli`, `jre21-openjdk`, `lib32-mesa`, `lib32-vulkan-intel`, `libva-utils`, `linux-lts`, `mesa-utils`, `pacman-contrib`, `prismlauncher`, `steam`, and `vulkan-tools` from the desired official list. Require the unchanged reviewed foreign set and assert that every excluded name is absent.

- [x] **Step 2: Run the manifest and verifier tests and confirm they fail for the old model**

Run:

```bash
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
```

Expected: FAIL because the current manifest contains excluded packages and lacks the new desktop packages.

- [x] **Step 3: Update the manifest, role documentation, and Phase 1 verifier**

Document the new desktop packages by responsibility. Remove gaming, Java, fallback-kernel, and Phase 1 cleanup requirements. Live verification must require the new commands, retain network/audio/session checks, report orphans without requiring removal, and stop requiring diagnostic tools, Java, Steam, Prism Launcher, or approved package absence.

- [x] **Step 4: Run the repository package checks**

Run:

```bash
bash -n scripts/lib/phase1-verify.sh tests/phase1-manifests.sh tests/phase1-verify.sh
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./scripts/verify --root "$PWD"
```

Expected: all repository and fixture checks pass without querying the running system.

- [x] **Step 5: Commit the package model**

```bash
git add packages scripts/lib/phase1-verify.sh tests/phase1-manifests.sh tests/phase1-verify.sh
git commit -m "docs: narrow desktop package scope"
```

### Task 2: Add Majula Desktop Configuration and Contract Tests

**Files:**
- Create: `config/hypr/majula.lua`
- Create: `config/hypr/hypridle.conf`
- Create: `config/hypr/hyprlock.conf`
- Create: `config/hypr/hyprpaper.conf`
- Create: `config/hypr/assets/majula-wallpaper.svg`
- Create: `config/waybar/config.jsonc`
- Create: `config/waybar/style.css`
- Create: `config/rofi/config.rasi`
- Create: `config/rofi/majula.rasi`
- Create: `config/kitty/kitty.conf`
- Create: `config/dunst/dunstrc`
- Create: `config/vscode/settings.json`
- Create: `scripts/session/clipboard-menu`
- Create: `scripts/session/session-menu`
- Create: `scripts/session/screenshot`
- Create: `systemd/user/simple-custom-arch-session.target`
- Create: `systemd/user/simple-custom-arch-waybar.service`
- Create: `systemd/user/simple-custom-arch-hyprpaper.service`
- Create: `systemd/user/simple-custom-arch-hypridle.service`
- Create: `systemd/user/simple-custom-arch-cliphist.service`
- Create: `tests/desktop-config.sh`

**Interfaces:**
- Consumes: exact Majula tokens from `docs/theme.md` and physical keypad mappings from the additive desktop design
- Produces: configuration sources and user units consumed by the deployer in Task 3

- [x] **Step 1: Write the desktop configuration contract test**

Require every listed file, all eleven palette values where relevant, Waybar height `28`, no battery module, no automatic suspend or power action, valid JSON for VS Code, executable session scripts, unique systemd unit names, and exact physical keypad codes `79` through `90` for the approved positions.

- [x] **Step 2: Run the new test and confirm missing sources fail**

Run: `./tests/desktop-config.sh`

Expected: FAIL naming the first missing configuration source.

- [x] **Step 3: Add application configuration and scripts**

Use the semantic mapping in `docs/theme.md`. Session scripts must use `set -euo pipefail`, discover their own repository location when required, avoid hard-coded home paths, and use only installed commands.

- [x] **Step 4: Add the graphical-session target and component units**

Each service must use `PartOf=simple-custom-arch-session.target`, start one responsibility, restart only on failure, and stop with the target. The target must bind to `graphical-session.target` without adding a system service.

- [x] **Step 5: Validate configuration sources**

Run:

```bash
bash -n scripts/session/* tests/desktop-config.sh
python -m json.tool config/vscode/settings.json >/dev/null
systemd-analyze --user verify systemd/user/*.service systemd/user/*.target
./tests/desktop-config.sh
```

Expected: syntax checks and the desktop contract pass.

- [x] **Step 6: Commit the desktop sources**

```bash
git add config scripts/session systemd/user tests/desktop-config.sh
git commit -m "feat: add additive Majula desktop configuration"
```

### Task 3: Add and Test the Additive User Deployer

**Files:**
- Create: `scripts/install-desktop`
- Create: `tests/install-desktop.sh`
- Modify: `scripts/README.md`

**Interfaces:**
- Consumes: the configuration sources and user units from Task 2
- Produces: `scripts/install-desktop --dry-run|--apply`, a timestamped backup, individual destination links, rendered wallpaper, and one Hyprland module import

- [x] **Step 1: Write fixture tests for deployment behavior**

Use an isolated temporary home and state directory. Prove dry-run writes nothing, apply creates only expected paths, the existing Hyprland content is preserved, `require("majula")` appears once, a repeated apply is unchanged, and conflicting or broken destinations fail without replacement.

- [x] **Step 2: Run the deployer test and confirm the missing command fails**

Run: `./tests/install-desktop.sh`

Expected: FAIL because `scripts/install-desktop` does not exist.

- [x] **Step 3: Implement the deployer**

The script accepts exactly `--dry-run` or `--apply`, discovers the repository root, supports test overrides through explicit `SCA_HOME` and `SCA_STATE_HOME` variables, renders the SVG wallpaper with `rsvg-convert`, creates timestamped backups only when needed, and prints every action in English.

- [x] **Step 4: Make deployment tests pass**

Run:

```bash
bash -n scripts/install-desktop tests/install-desktop.sh
./tests/install-desktop.sh
./tests/phase0-verify.sh
./scripts/verify --root "$PWD"
git diff --check
```

Expected: all fixture and repository checks pass.

- [x] **Step 5: Commit the deployer**

```bash
git add scripts/install-desktop scripts/README.md tests/install-desktop.sh
git commit -m "feat: add additive desktop deployer"
```

### Task 4: Install the Minimal Package Set and Deploy the User Configuration

**Files:**
- Runtime only: `~/.local/state/simple-custom-arch/backups/<timestamp>/`
- Runtime only: the individual XDG destinations managed by `scripts/install-desktop`

**Interfaces:**
- Consumes: the reviewed package model and deployer from Tasks 1 through 3
- Produces: installed commands, deployed configuration, enabled user units, and a local recovery directory for Task 5

- [x] **Step 1: Run repository preflight and dry-run**

Run all repository tests and `./scripts/install-desktop --dry-run`. Stop if Git is dirty outside the planned files or the deployer reports a conflict.

- [x] **Step 2: Review Arch news and the exact transaction**

Check current official Arch Linux news. Preview the requested official package set and verify it contains exactly `brightnessctl cliphist hypridle hyprlock hyprpaper playerctl waybar wl-clipboard xdg-user-dirs`, plus only dependencies and complete-upgrade replacements proposed by Pacman.

- [x] **Step 3: Authenticate once and run the complete package sequence**

Use one `sudo -v`, start a temporary noninteractive credential keepalive, run:

```bash
sudo pacman -Syu --needed \
  brightnessctl cliphist hypridle hyprlock hyprpaper playerctl \
  waybar wl-clipboard xdg-user-dirs
yay -S --needed visual-studio-code-bin
```

Terminate the keepalive through a trap. Stop on any failure. Do not add `--noconfirm`.

- [x] **Step 4: Apply configuration and enable the user target**

Run `./scripts/install-desktop --apply`, reload the user manager, enable `simple-custom-arch-session.target`, and start it in the current graphical session. Reload Hyprland only after `hyprctl configerrors` can parse the appended module.

- [x] **Step 5: Record the package and deployment boundary**

Preserve Pacman, Yay, deployment, and user-service output in the current state directory. Keep runtime logs out of Git.

### Task 5: Verify the Live Desktop and Update Project Status

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `ROADMAP.md`
- Modify: `docs/baseline/README.md`
- Modify: `docs/baseline/official-explicit.txt`
- Modify: `docs/baseline/foreign-explicit.txt`
- Modify: `docs/baseline/services.md`
- Modify: `scripts/README.md`
- Modify: `tests/phase1-docs.sh`

**Interfaces:**
- Consumes: the installed and deployed state from Task 4
- Produces: fresh live evidence, sanitized baseline facts, and documentation matching the user-approved desktop state

- [x] **Step 1: Run syntax and compositor validation**

Check `hyprctl configerrors`, Rofi Rasi validation, VS Code JSON, systemd unit verification, and the complete repository suite. Reload only components whose configuration passes.

- [x] **Step 2: Verify package, service, and process state**

Require all scoped packages and commands, active project user units, full network connectivity, PipeWire audio, and one process for each managed component. Confirm no requested transaction installed Steam or `linux-lts`.

- [x] **Step 3: Exercise non-destructive user flows**

Open and close Rofi, Kitty, and VS Code; invoke screenshot selection and cancel it; inspect clipboard menu startup; query brightness, volume, media, and Hyprland bindings without changing power state. Confirm all physical keypad keycodes are registered.

- [x] **Step 4: Refresh sanitized baseline and status documentation**

Record only package names, normalized service state, the additive deployment date, and the explicit exclusions. Update the roadmap so it no longer claims pending LTS recovery or Steam installation and does not claim unimplemented configuration remains absent.

- [x] **Step 5: Run final acceptance**

Run:

```bash
set -e
./tests/desktop-config.sh
./tests/install-desktop.sh
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/phase1-docs.sh complete
./tests/phase0-verify.sh
./scripts/verify
git diff --check
git status --short
```

Expected: every test and live check passes, only sanitized planned files are versioned, and no automatic power action occurs.

- [x] **Step 6: Commit documentation and report locally**

```bash
git add AGENTS.md README.md ROADMAP.md docs/baseline scripts/README.md tests/phase1-docs.sh \
  docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md \
  docs/superpowers/plans/2026-10-09-additive-desktop-configuration.md
git commit -m "docs: record additive desktop deployment"
```

Keep every commit local. Report the backup directory, installed package set, active services, validation evidence, and any action that still requires a new graphical login.

### Task 6: Simplify Waybar

**Files:**
- Create: `config/icons/hicolor/index.theme`
- Create: `config/icons/hicolor/22x22/apps/nm-signal-100.svg`
- Modify: `config/waybar/config.jsonc`
- Modify: `config/waybar/style.css`
- Modify: `scripts/install-desktop`
- Modify: `tests/desktop-config.sh`
- Modify: `tests/install-desktop.sh`

- [x] Remove the network, Bluetooth, backlight, CPU, memory, session, and power modules from Waybar.
- [x] Keep only audio and the application tray on the right side.
- [x] Replace the `nm-applet` bitmap with a Majula Wi-Fi icon through a local Hicolor override.
- [x] Remove the unused power-menu deployment path and its test fixture.
- [x] Run repository tests, restart Waybar, and verify the live bar.

### Task 7: Extend the Majula Theme Across Desktop Toolkits

**Files:**
- Create: `config/environment.d/90-simple-custom-arch-theme.conf`
- Create: `config/gtk-3.0/settings.ini`
- Create: `config/gtk-3.0/gtk.css`
- Create: `config/gtk-4.0/settings.ini`
- Create: `config/gtk-4.0/gtk.css`
- Create: `config/kde/kdeglobals`
- Create: `config/kde/Majula.colors`
- Create: `scripts/apply-theme`
- Create: `tests/apply-theme.sh`
- Modify: `config/hypr/majula.lua`
- Modify: `config/rofi/config.rasi`
- Modify: `config/rofi/majula.rasi`
- Modify: `scripts/install-desktop`
- Modify: `tests/desktop-config.sh`
- Modify: `tests/install-desktop.sh`

- [x] Apply the dark Majula palette to GTK 3, GTK 4, Qt, and KDE applications using installed engines.
- [x] Add backed-up desktop preference deployment for dark appearance, icons, and cursor settings.
- [x] Give Rofi explicit dark widget backgrounds and application, window, command, and file modes.
- [x] Add application actions, visible mode navigation, fuzzy matching, and `Super + keypad 0` access.
- [x] Deploy the new sources, apply the preferences, reload Hyprland, and verify Rofi and Dolphin live.
- [x] Run the full repository and live-system verification.

### Task 8: Prepare the Completed Desktop for Publication

**Files:**
- Modify: `README.md`
- Modify: `packages/README.md`
- Modify: `packages/official.txt`
- Modify: `packages/aur.txt`
- Modify: `scripts/README.md`
- Modify: `scripts/install-desktop`
- Modify: `scripts/lib/phase1-verify.sh`
- Modify: `scripts/verify`
- Modify: `tests/phase1-docs.sh`
- Modify: `tests/phase1-manifests.sh`
- Modify: `tests/phase1-verify.sh`
- Create: `tests/verify.sh`
- Remove: redundant tracked `.gitkeep` placeholders

- [x] Limit package manifests to direct dependencies used by the deployed desktop and document validation-only tools separately.
- [x] Remove the deployer's runtime dependency on Ripgrep by using GNU grep for the exact Hyprland import check.
- [x] Consolidate installation, keybindings, services, appearance, backup, recovery, and verification guidance in the main README.
- [x] Update the preview and theme reference to match six-pixel gaps, 84% Kitty opacity, the simplified Waybar, and the current Rofi launcher.
- [x] Preserve phase history and recovery documentation while removing redundant directory placeholders.
- [x] Add isolated repository-verifier coverage and run the complete repository and live-session checks before requesting push approval.
