# Project Scripts

All project scripts use Bash strict mode, discover the repository root dynamically, and keep runtime state outside Git.

## `install-desktop`

```bash
./scripts/install-desktop --dry-run
./scripts/install-desktop --apply
```

The deployer preflights every managed destination before changing anything. It creates individual symbolic links, renders the wallpaper, and appends one idempotent `require("majula")` line to the existing generated Hyprland configuration.

Apply mode creates a timestamped backup before changing an existing Hyprland file. Correct links are reused, while unrelated files, directories, and broken links stop the whole deployment before partial changes occur.

The script requires Bash, standard Arch base utilities, GNU grep, and `rsvg-convert` from `librsvg`.

## `apply-theme`

```bash
./scripts/apply-theme --dry-run
./scripts/apply-theme --apply
```

This script manages the desktop-wide dark preference, GTK theme, icon theme, cursor theme, and cursor size through `gsettings`. Apply mode records earlier values under the XDG state directory, verifies each write, and rolls back values already changed when a later write fails.

## `verify`

```bash
./scripts/verify --root "$PWD"
./scripts/verify
```

The `--root` mode checks repository structure, dependency manifests, documentation privacy, SVG validity and rendering, palette coverage, and Git whitespace. It never queries the running system.

The no-argument mode runs the same repository checks, then captures a temporary local snapshot and verifies:

- all direct theme dependencies are installed;
- every command referenced by configuration or keybindings is available;
- project user units and Dunst are active;
- no user unit is failed;
- the Hyprland session is available and reports no configuration errors.

The temporary snapshot is removed on exit and is never committed.

## Session Helpers

| Script | Installed command | Responsibility |
|---|---|---|
| `session/clipboard-menu` | `simple-custom-arch-clipboard-menu` | Select and restore clipboard history through Rofi. |
| `session/screenshot` | `simple-custom-arch-screenshot` | Capture a full screen or selected area and copy it to the clipboard. |
| `session/session-menu` | `simple-custom-arch-session-menu` | Offer lock, logout, and cancel actions. |

No script performs an automatic restart, shutdown, suspend, package installation, or package removal.
