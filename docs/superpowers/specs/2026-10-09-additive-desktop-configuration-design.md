# Additive Desktop Configuration Design

**Date:** 2026-10-09  
**Status:** Approved for implementation

## Purpose

This change completes the functional Hyprland desktop by adding only the missing packages and configuration required for the approved applications and desktop responsibilities. It preserves the existing user configuration, adds the Majula palette, and provides usable keyboard controls that do not depend on the broken `F2`, `F5`, top-row `5`, or top-row `6` keys.

The user explicitly excludes Steam, a second kernel, boot recovery work, package cleanup, and wholesale configuration replacement. This design supersedes those parts of the earlier Phase 1 plan for the current execution.

## Current State

The notebook currently runs Hyprland 0.56 through UWSM on Wayland. The existing `~/.config/hypr/hyprland.lua` is the generated Lua configuration and remains the primary configuration file.

Kitty, Dolphin, Dunst, Rofi, Zen Browser, Grim, Slurp, PipeWire, NetworkManager, and the KDE PolicyKit agent are already installed. The audited destinations for Waybar, Rofi, Dunst, Hypridle, Hyprlock, Hyprpaper, and VS Code settings do not currently exist. The Kitty directory exists but contains no configuration file.

## Package Scope

Perform one complete official upgrade and install only these missing official packages:

- `brightnessctl`
- `cliphist`
- `hypridle`
- `hyprlock`
- `hyprpaper`
- `playerctl`
- `waybar`
- `wl-clipboard`
- `xdg-user-dirs`

Install the reviewed foreign package `visual-studio-code-bin` with Yay after the official transaction succeeds.

The complete official transaction may update already installed packages, including the existing regular kernel, as required by Arch Linux's full-upgrade model. It must not install another kernel or change boot configuration.

Do not install Steam, Prism Launcher, Java, 32-bit graphics providers, diagnostic packages, or package-maintenance tools merely because they appeared in the earlier Phase 1 manifest. Do not remove any installed package.

## Additive Deployment Contract

The repository remains the source for every new project-owned file. Deployment adds individual files and links rather than replacing complete configuration directories.

Before changing an existing destination, create a timestamped backup below `~/.local/state/simple-custom-arch/backups/`. The deployment must preserve the existing `hyprland.lua` and append one idempotent `require("majula")` statement. It must never replace that file.

For each other managed destination:

- Create the parent directory when it is absent.
- Add the project-owned link when the destination is absent.
- Leave a correct existing link unchanged.
- Stop instead of replacing an unrelated file, directory, or broken link.
- Support `--dry-run` without changing the filesystem.
- Produce the same state when run again.

No personal browser profile, account data, credentials, or extension state is managed.

## Hyprland Additions

`config/hypr/majula.lua` adds palette, geometry, autostart integration, window behavior, and keybindings while leaving the generated configuration intact.

The additions use:

- Four-pixel inner and outer gaps.
- A two-pixel focused border in `ember` and a one-pixel inactive border in `border`.
- Conservative rounding, one-pass blur no larger than four pixels, and animations shorter than 300 milliseconds.
- Brazilian keyboard layout and the existing monitor auto-detection.
- A solid or generated Majula background managed by Hyprpaper.
- External commands through `hl.dsp.exec_cmd`, never blocking Lua callbacks.

The existing application and window-management bindings remain in place. New bindings use the physical numeric keypad through keycodes so Num Lock state does not change their location.

| Binding | Action |
|---|---|
| `Super + keypad 1` through `Super + keypad 9` | Open workspaces 1 through 9 |
| `Super + Shift + keypad 1` through `Super + Shift + keypad 9` | Move the active window to workspaces 1 through 9 |
| `Alt + keypad 8` / `Alt + keypad 2` | Increase / decrease brightness |
| `Alt + keypad 6` / `Alt + keypad 4` | Increase / decrease volume |
| `Alt + keypad 5` | Toggle output mute |
| `Alt + keypad 0` | Play or pause media |
| `Alt + keypad 9` / `Alt + keypad 7` | Next / previous media item |

The media bindings remain available when the session is locked where the action is safe. Existing XF86 media bindings also remain unchanged.

## Desktop Components

### Waybar

Use a 28-pixel top bar with workspaces and the active window on the left, the clock in the center, and audio plus the application tray on the right. Do not show battery, network, Bluetooth, backlight, CPU, memory, session, or power modules. Override the legacy `nm-applet` bitmap through the local Hicolor theme with a clean Wi-Fi glyph in the Majula text color while preserving the applet menu.

### Rofi

Configure a compact application launcher using the Majula palette. Add project scripts for clipboard selection and session controls without changing Rofi's installed binaries.

### Kitty, Dunst, and VS Code

Add standalone configuration files using the exact Majula semantic colors. Kitty keeps a compact tab bar and native Wayland behavior. Dunst uses labeled urgency states and restrained geometry. VS Code receives project-owned user settings only because no existing settings file was found.

### Lock, Idle, Wallpaper, and Clipboard

Hyprlock uses the Majula background and a clear password field. Hypridle locks the session after ten idle minutes and turns displays off one minute later. It never suspends, restarts, or shuts down the notebook. Hyprpaper displays the project wallpaper. Cliphist records clipboard changes through `wl-paste` and exposes them through Rofi.

Project-owned systemd user units start Waybar, Hyprpaper, Hypridle, and clipboard history with the graphical session. Unit names use the `simple-custom-arch-` prefix to avoid colliding with package-provided services.

## Installation and Authentication

Show the complete privileged command before authentication. Use one `sudo` validation and a temporary keepalive for the official transaction and the later Yay installation, then terminate the keepalive. Yay and its package build run as the normal user.

Stop immediately when the official upgrade, foreign-package installation, backup, deployment, reload, or verification fails. Preserve logs and the backup directory. Do not reboot, shut down, or restart the graphical session automatically.

## Verification

Repository checks must prove:

- The minimal package model excludes Steam, `linux-lts`, Prism Launcher, Java, and 32-bit graphics packages.
- Every Majula token appears in the relevant configuration sources.
- The numeric keypad bindings use physical keypad keycodes and do not depend on the four broken keys.
- The deployment is dry-run safe, additive, idempotent, and refuses conflicting destinations.
- Systemd user units and application configuration files pass their available syntax checks.

Live verification must prove:

- Every scoped package and command is available.
- The existing `hyprland.lua` remains present and loads `majula.lua` exactly once.
- Hyprland reports no configuration error after reload.
- The new user units are enabled and active in the graphical session.
- Waybar, Dunst, Hyprpaper, Hypridle, and clipboard history are running once.
- Rofi, Kitty, VS Code, lock, screenshots, brightness, volume, media, and keypad workspace bindings have valid commands.
- No boot file or boot configuration changed as part of this work.

## Acceptance Criteria

- The desktop starts with the new functional components and Majula appearance.
- Existing configuration remains recoverable and is extended rather than replaced.
- The numeric keypad provides workspace, brightness, volume, and media controls.
- No action depends on `F2`, `F5`, top-row `5`, or top-row `6`.
- Only the minimal approved packages are newly requested.
- Steam and additional kernels remain absent from the requested transaction.
- No installed package is removed.
- Repository tests and live verification pass without an automatic power action.
