# Simple Custom Arch

Simple Custom Arch is an additive Majula theme and desktop configuration for an existing Hyprland session. It keeps the generated Hyprland configuration in place, adds one Lua module, and manages individual XDG files through recoverable symbolic links.

The current desktop scope is complete. Phases 0 through 4 cover the repository foundation, dependencies, Hyprland additions, desktop services, and visual theme. The planned update interface is not included.

![Majula desktop preview](docs/assets/theme-preview.svg)

## Included

- Majula colors for Hyprland, Waybar, Rofi, Kitty, Dunst, Hyprlock, GTK 3, GTK 4, Qt/KDE, and VS Code.
- A compact 28 px Waybar with workspaces, active window, clock, volume, and tray.
- A Rofi launcher with application, window, command, and file modes.
- Wallpaper, lock, idle display control, notifications, clipboard history, and screenshots.
- Numeric-keypad keybindings that use physical keycodes and work independently of Num Lock.
- User services that start each persistent desktop component once.
- Dry-run deployment, timestamped backups, conflict detection, and repository/live verification.

The project does not install packages, replace whole configuration directories, modify boot files, add a kernel, install Steam, or perform power actions.

## Compatibility

The current target is Arch Linux, Wayland, UWSM, and a 1366x768 display. The Hyprland integration expects an existing generated `~/.config/hypr/hyprland.lua` that supports the `hl` Lua API. The repository appends exactly one `require("majula")` line to that file.

Keep the repository at a stable path after deployment because managed destinations are symbolic links into the checkout.

## Dependencies

The exact direct runtime package lists are:

- [Official Arch packages](packages/official.txt)
- [Reviewed foreign applications](packages/aur.txt)
- [Package roles and verification tools](packages/README.md)

Review the manifests before installation. Install official dependencies only as part of a complete upgrade:

```bash
sudo pacman -Syu --needed $(< packages/official.txt)
```

The two foreign applications are `visual-studio-code-bin` and `zen-browser-bin`. Review their PKGBUILDs and install them with a trusted local build workflow. No particular AUR helper is required.

Repository verification also uses `file`, `git`, `libxml2`, `python`, and `ripgrep`.

## Installation

Run each command from the repository root.

1. Verify repository content without querying the running desktop:

   ```bash
   ./scripts/verify --root "$PWD"
   ```

2. Review the additive deployment:

   ```bash
   ./scripts/install-desktop --dry-run
   ./scripts/apply-theme --dry-run
   ```

3. Apply the managed links and desktop preferences:

   ```bash
   ./scripts/install-desktop --apply
   ./scripts/apply-theme --apply
   ```

4. Load and enable the graphical-session services:

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now simple-custom-arch-session.target
   hyprctl reload
   ```

5. Verify the active desktop:

   ```bash
   ./scripts/verify
   ```

Deployment stops before making changes when a managed destination contains an unrelated file, directory, or broken link. It never overwrites an existing application configuration.

## Keybindings

Existing generated Hyprland bindings remain available. This module adds:

| Binding | Action | Command or component |
|---|---|---|
| `Super + keypad 0` | Open the Rofi application launcher | `rofi -show drun` |
| `Super + keypad 1…9` | Open workspace 1…9 | Hyprland workspace focus |
| `Super + Shift + keypad 1…9` | Move the active window to workspace 1…9 | Hyprland window move |
| `Alt + keypad 8` / `Alt + keypad 2` | Increase / decrease brightness by 5% | `brightnessctl` |
| `Alt + keypad 6` / `Alt + keypad 4` | Increase / decrease volume by 5% | `wpctl` |
| `Alt + keypad 5` | Toggle output mute | `wpctl` |
| `Alt + keypad 0` | Play or pause media | `playerctl` |
| `Alt + keypad 9` / `Alt + keypad 7` | Next / previous media item | `playerctl` |
| `Alt + keypad 1` | Capture the full screen | Grim |
| `Alt + keypad 3` | Select and capture an area | Slurp and Grim |
| `Super + B` | Open Zen Browser | `zen-browser` |
| `Super + Shift + C` | Open VS Code | `code` |
| `Super + L` | Lock the session | `loginctl lock-session` |
| `Super + Shift + V` | Open clipboard history | Cliphist and Rofi |
| `Print` | Capture the full screen | Grim |
| `Super + Alt + S` | Select and capture an area | Slurp and Grim |
| `Super + Shift + E` | Open the lock, logout, and cancel menu | Rofi and UWSM |

Physical keypad codes are documented in [the current desktop design](docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md).

## Appearance

- Inner and outer Hyprland gaps: 6 px.
- Focused border: 2 px in Majula ember.
- Rounding: 6 px.
- Blur: one 4 px pass.
- Waybar height: 28 px.
- Kitty background opacity: 84%.
- Cursor: Adwaita at 24 px.
- Icons: Breeze Dark.
- Fonts: Noto Sans at application-specific compact sizes.

The palette and component mappings live in [docs/theme.md](docs/theme.md).

## Managed Services

`simple-custom-arch-session.target` starts:

| Unit | Responsibility |
|---|---|
| `simple-custom-arch-waybar.service` | Status bar |
| `simple-custom-arch-hyprpaper.service` | Wallpaper |
| `simple-custom-arch-hypridle.service` | Lock and display-off timers |
| `simple-custom-arch-cliphist.service` | Clipboard history capture |
| `dunst.service` | Notifications |

Each project service uses `Restart=on-failure` and belongs to the graphical-session target.

## Backups and Recovery

Runtime backups are stored outside Git under `${XDG_STATE_HOME:-~/.local/state}/simple-custom-arch/backups/`.

- `install-desktop --apply` backs up the existing generated Hyprland file before appending the Majula import.
- `apply-theme --apply` records every changed desktop preference and restores earlier values automatically if an operation fails.
- Existing unrelated destinations are left untouched.
- Logs, backups, credentials, and personal application data are never committed.

See [docs/maintenance.md](docs/maintenance.md) for validation and recovery steps.

## Verification

Run the focused tests individually:

```bash
./tests/desktop-config.sh
./tests/install-desktop.sh
./tests/apply-theme.sh
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/verify.sh
```

Run `./scripts/verify --root "$PWD"` for repository-only checks or `./scripts/verify` for repository and live-session checks.

## Project Documentation

- [Repository contract](AGENTS.md)
- [Roadmap](ROADMAP.md)
- [Theme reference](docs/theme.md)
- [Maintenance and recovery](docs/maintenance.md)
- [Current design](docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md)
- [Completed implementation plan](docs/superpowers/plans/2026-10-09-additive-desktop-configuration.md)
