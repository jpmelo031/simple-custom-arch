# Configuration Sources

This directory will contain the versioned source for user configuration. Phase 0 reserves these paths only and does not deploy or replace any configuration on the running system.

| Directory | Responsibility |
|---|---|
| `hypr/` | Hyprland display, input, workspace, window, and binding configuration |
| `kitty/` | Kitty terminal behavior and appearance |
| `rofi/` | Application launcher and update-choice interface |
| `dunst/` | Desktop notification behavior and appearance |
| `waybar/` | Status bar modules, layout, and styling |
| `vscode/` | Reproducible editor settings and extension manifest |
| `shell/` | Interactive shell configuration shared by project-managed sessions |

Later phase plans must document destinations, dependencies, backup behavior, and verification before adding deployable files.
