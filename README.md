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

Phase 0 — Project Foundation is complete. Phase 1 — Base System and Packages is planned next, but no Phase 1 package installation or removal has started. No system configuration has been deployed from this repository.

### Completed

- Defined the project architecture, safety rules, deployment model, update experience, and phased roadmap.
- Added the mandatory repository contract, standalone roadmap, and purposeful project structure.
- Recorded a sanitized hardware, package, service, and graphical-session baseline for the target notebook.
- Documented backup and recovery prerequisites for later system-facing phases.
- Added a read-only Phase 0 verifier with isolated behavioral tests.
- Created the Majula semantic palette with documented contrast and component usage.
- Approved compact geometry for the target display: 4-pixel gaps, 1-pixel inactive borders, 2-pixel focused borders, 24-pixel application title bars, and a 28-pixel Waybar.
- Created and inspected the theme preview at the notebook's native 1366x768 resolution.

## Roadmap

| Phase | Focus | Status |
|---:|---|---|
| 0 | Project contract, repository structure, sanitized baseline, and recovery prerequisites | Complete |
| 1 | Base system and package manifests | Planned |
| 2 | Hyprland core and keybindings | Not started |
| 3 | Desktop essentials | Not started |
| 4 | Majula visual system implementation | Not started |
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

Plan Phase 1 by reviewing the observed package set and assigning a documented purpose to each desired package. Do not install or remove packages until that plan is reviewed and approved.
