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

Phase 0 — Project Foundation is being planned. The project architecture and initial Majula visual baseline are approved; no system configuration has been deployed from this repository yet.

### Completed

- Defined the project architecture, safety rules, deployment model, update experience, and phased roadmap.
- Created the Majula semantic palette with documented contrast and component usage.
- Approved compact geometry for the target display: 4-pixel gaps, 1-pixel inactive borders, 2-pixel focused borders, 24-pixel application title bars, and a 28-pixel Waybar.
- Created and inspected the theme preview at the notebook's native 1366x768 resolution.

## Roadmap

| Phase | Focus | Status |
|---:|---|---|
| 0 | Project contract, repository structure, sanitized baseline, and recovery prerequisites | Planning |
| 1 | Base system and package manifests | Planned |
| 2 | Hyprland core and keybindings | Planned |
| 3 | Desktop essentials | Planned |
| 4 | Majula visual system implementation | Planned |
| 5 | Safe update experience | Planned |
| 6 | Development environment | Planned |
| 7 | Bootstrap and recovery automation | Planned |

Each phase is planned and verified before the next one begins. The future portability milestone starts only after the notebook configuration is stable.

## Documentation

- [Project design and full roadmap](docs/superpowers/specs/2026-10-08-simple-custom-arch-design.md)
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

Complete the Phase 0 implementation plan, then create the project contract, roadmap, directory structure, sanitized system baseline, and recovery documentation without changing the running system configuration.
