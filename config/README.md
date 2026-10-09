# Configuration Sources

This directory contains versioned sources for the additive desktop configuration. `scripts/install-desktop` links individual files into their XDG destinations and leaves unrelated files and complete configuration directories intact.

| Directory | Responsibility |
|---|---|
| `hypr/` | Additive Hyprland appearance and bindings, lock, idle, wallpaper, and wallpaper source |
| `kitty/` | Kitty terminal behavior and appearance |
| `rofi/` | Application launcher and update-choice interface |
| `dunst/` | Desktop notification behavior and appearance |
| `waybar/` | Status bar modules, layout, and styling |
| `vscode/` | Reproducible editor settings |
| `shell/` | Interactive shell configuration shared by project-managed sessions |

The generated `~/.config/hypr/hyprland.lua` remains the primary configuration. Deployment backs it up and appends one `require("majula")` statement. An existing unrelated destination causes deployment to stop instead of replacing it.
