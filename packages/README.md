# Dependencies

These manifests contain only direct dependencies used by the deployed desktop configuration. They do not mirror the whole operating system and do not include the kernel, bootloader, firmware, package helpers, diagnostics, or unrelated applications.

## Rules

- `official.txt` contains direct runtime dependencies from the configured Arch Linux repositories.
- `aur.txt` contains reviewed foreign applications referenced by project settings or keybindings.
- Blank lines and lines beginning with `#` are ignored.
- Entries remain sorted, unique, and limited to packages with a documented responsibility.
- Pacman resolves transitive dependencies; those packages are not duplicated here.
- Always install official dependencies with a complete upgrade. Never run `pacman -Sy` by itself.

## Desktop Runtime

| Packages | Responsibility |
|---|---|
| `hyprland`, `uwsm` | Wayland compositor and managed session used by the additive Lua module and logout action. |
| `waybar` | Compact workspace, window, clock, audio, and tray bar. |
| `rofi` | Application, window, command, file, clipboard, and session menus. |
| `kitty` | Terminal with the Majula palette and translucent background. |
| `dunst` | Desktop notifications. |
| `hyprlock`, `hypridle`, `hyprpaper` | Lock screen, idle behavior, and wallpaper. |
| `wl-clipboard`, `cliphist` | Clipboard capture, storage, and restore. |
| `grim`, `slurp`, `xdg-user-dirs` | Full-screen and area screenshots saved in the user's pictures directory. |
| `brightnessctl`, `playerctl`, `wireplumber`, `pipewire-pulse` | Brightness, media, volume, and mute keybindings plus Waybar audio state. |
| `network-manager-applet` | Network menu shown through the Waybar tray. |
| `dolphin`, `qt6-wayland` | Qt file manager and native Wayland support for the KDE color scheme. |

## Theme Assets and Toolkits

| Packages | Responsibility |
|---|---|
| `glib2` | Provides the `gsettings` preference interface used by `apply-theme`. GTK applications consume the project CSS through their own GTK runtime dependencies. |
| `breeze-icons` | Dark icon theme used by GTK, Qt, Rofi, and Dolphin. |
| `adwaita-cursors` | Cursor theme selected across the session. |
| `noto-fonts` | Font family referenced by Waybar, Rofi, Dunst, and Hyprlock. |
| `librsvg` | Provides `rsvg-convert` to render the versioned wallpaper SVG during deployment. |

## Reviewed Foreign Applications

| Package | Source and responsibility |
|---|---|
| `visual-studio-code-bin` | AUR recipe for Microsoft's binary VS Code release; consumes the project-owned editor settings and the `Super + Shift + C` binding. |
| `zen-browser-bin` | AUR recipe for the upstream Zen Browser binary; target of the `Super + B` binding. |

The repository does not require a specific AUR helper. Review each PKGBUILD before installing a foreign package.

## Verification Tools

Repository verification additionally uses `file`, `git`, `libxml2` for `xmllint`, `python`, and `ripgrep`. Bash, GNU core utilities, GNU grep, and systemd are assumed to come from the normal Arch base installation.

## Installation

Review the manifests, then run one complete official transaction:

```bash
sudo pacman -Syu --needed $(< packages/official.txt)
```

Install the reviewed foreign applications separately with a trusted, locally installed build workflow. The project never pipes remote content into a shell and never installs packages from its deployment script.
