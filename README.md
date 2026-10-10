# Simple Custom Arch

Simple Custom Arch is a personal Arch Linux configuration for a minimal, functional, fast, and reliable Hyprland desktop. The first stable version targets the current notebook and favors clear, reproducible choices over a large dotfiles collection.

## Priorities

Project decisions follow this order:

1. Stability
2. Functionality
3. Performance
4. Visual consistency
5. Portability

Every package, service, script, and visual effect must have a documented purpose. Portability matters, but it must not complicate the first dependable setup for the current machine.

## Current Target

- Samsung 300E5M/300E5L notebook
- 1366x768 display at 60 Hz
- Intel Core i5-7200U with Intel HD Graphics 620
- 16 GiB memory and a 223.6 GiB SSD
- Hyprland on Wayland through SDDM and UWSM
- Kitty, Rofi, Dolphin, Dunst, VS Code, and Zen Browser

## Current Phase

Phases 0 through 4 are complete for the current notebook under the approved additive desktop scope. The package set, Hyprland module, desktop services, and Majula application configuration are deployed and verified. Phase 5 — Safe Update Experience is the next planned phase and has not started.

### Completed

- Defined the project architecture, safety rules, deployment model, update experience, and phased roadmap.
- Added the mandatory repository contract, standalone roadmap, and purposeful project structure.
- Recorded a sanitized hardware, package, service, and graphical-session baseline for the target notebook.
- Documented backup and recovery prerequisites for later system-facing phases.
- Added a read-only Phase 0 verifier with isolated behavioral tests.
- Created the Majula semantic palette with documented contrast and component usage.
- Approved compact geometry for the target display: 4-pixel gaps, 1-pixel inactive borders, 2-pixel focused borders, 24-pixel application title bars, and a 28-pixel Waybar.
- Created and inspected the theme preview at the notebook's native 1366x768 resolution.
- Defined the Phase 1 desired package manifests and documented every package role.
- Added isolated repository checks and read-only live-system verification for Phase 1.
- Documented the weekly complete-upgrade and recovery procedure.
- Installed the minimal desktop package set without Steam, Java, a second kernel, or boot changes.
- Extended the existing Hyprland Lua configuration through one recoverable module import.
- Added and activated Waybar, Hyprpaper, Hypridle, clipboard history, and Dunst for the graphical session.
- Kept Waybar compact with audio, tray, and a confirmed shutdown or restart menu.
- Applied the Majula palette to Hyprland, Waybar, Rofi, Kitty, Dunst, Hyprlock, and VS Code.
- Added physical numeric-keypad controls that do not depend on Num Lock or the broken top-row keys.

## Added Keybindings

The generated Hyprland bindings remain in place. The project adds:

| Binding | Action |
|---|---|
| `Super + keypad 1` through `Super + keypad 9` | Open workspace 1 through 9 |
| `Super + Shift + keypad 1` through `Super + Shift + keypad 9` | Move the active window to workspace 1 through 9 |
| `Alt + keypad 8` / `Alt + keypad 2` | Increase / decrease brightness |
| `Alt + keypad 6` / `Alt + keypad 4` | Increase / decrease volume |
| `Alt + keypad 5` | Toggle output mute |
| `Alt + keypad 0` | Play or pause media |
| `Alt + keypad 9` / `Alt + keypad 7` | Next / previous media item |
| `Super + B` | Open Zen Browser |
| `Super + Shift + C` | Open VS Code |
| `Super + L` | Lock the session |
| `Super + Shift + V` | Open clipboard history |
| `Print` / `Super + Alt + S` | Capture the full screen / select an area |
| `Super + Shift + E` | Open the lock and logout menu |

## Roadmap

| Phase | Focus | Status |
|---:|---|---|
| 0 | Project contract, repository structure, sanitized baseline, and recovery prerequisites | Complete |
| 1 | Base system and package manifests | Complete |
| 2 | Hyprland core and keybindings | Complete |
| 3 | Desktop essentials | Complete |
| 4 | Majula visual system implementation | Complete |
| 5 | Safe update experience | Not started |
| 6 | Development environment | Not started |
| 7 | Bootstrap and recovery automation | Not started |

Each phase is planned and verified before the next one begins. The future portability milestone starts only after the notebook configuration is stable.

## Documentation

- [Repository contract](AGENTS.md)
- [Project roadmap](ROADMAP.md)
- [Sanitized system baseline](docs/baseline/README.md)
- [Maintenance and recovery guide](docs/maintenance.md)
- [Project design and full roadmap](docs/superpowers/specs/2026-10-08-simple-custom-arch-design.md)
- [Phase 0 implementation plan](docs/superpowers/plans/2026-10-08-phase-0-project-foundation.md)
- [Phase 1 design specification](docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md)
- [Phase 1 implementation plan](docs/superpowers/plans/2026-10-08-phase-1-base-system.md)
- [Additive desktop design specification](docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md)
- [Additive desktop implementation plan](docs/superpowers/plans/2026-10-09-additive-desktop-configuration.md)
- [Majula theme reference](docs/theme.md)
- [Majula theme preview](docs/assets/theme-preview.svg)
- [Theme preview implementation plan](docs/superpowers/plans/2026-10-08-majula-theme-preview.md)

## Working Rules

- Keep all versioned content in English.
- Never commit credentials, tokens, private keys, cookies, personal browser data, or machine identifiers.
- Never perform partial Arch Linux upgrades.
- Prefer official Arch packages and document every AUR exception.
- Inspect, plan, back up, apply, verify, and document each system change.
- Keep changes local until an upload is explicitly authorized.

## Next Step

Design and approve Phase 5 before adding any automatic update check or package-management interface.
