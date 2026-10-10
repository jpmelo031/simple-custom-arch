# Configuration Sources

This directory contains versioned sources for the additive desktop configuration. `scripts/install-desktop` links individual files into their XDG destinations and leaves unrelated files and complete configuration directories intact.

| Directory | Responsibility |
|---|---|
| `environment.d/` | Session-wide toolkit and cursor environment |
| `gtk-3.0/` | GTK 3 dark preference and Majula color overrides |
| `gtk-4.0/` | GTK 4 dark preference and Majula color overrides |
| `hypr/` | Additive Hyprland appearance and bindings, lock, idle, wallpaper, and wallpaper source |
| `icons/` | Local icon-theme overrides for project-owned desktop styling |
| `kde/` | Qt/KDE color scheme, widget style, and icon preference |
| `kitty/` | Kitty terminal behavior and appearance |
| `rofi/` | Application, window, command, file, clipboard, and session menus |
| `dunst/` | Desktop notification behavior and appearance |
| `waybar/` | Status bar modules, layout, and styling |
| `vscode/` | Reproducible editor settings |

The generated `~/.config/hypr/hyprland.lua` remains the primary configuration. Deployment backs it up and appends one `require("majula")` statement. An existing unrelated destination causes deployment to stop instead of replacing it.
