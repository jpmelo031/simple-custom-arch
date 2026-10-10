#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

required_files=(
  config/hypr/majula.lua
  config/hypr/hypridle.conf
  config/hypr/hyprlock.conf
  config/hypr/hyprpaper.conf
  config/hypr/assets/majula-wallpaper.svg
  config/environment.d/90-simple-custom-arch-theme.conf
  config/gtk-3.0/settings.ini
  config/gtk-3.0/gtk.css
  config/gtk-4.0/settings.ini
  config/gtk-4.0/gtk.css
  config/icons/hicolor/index.theme
  config/icons/hicolor/22x22/apps/nm-signal-100.svg
  config/kde/kdeglobals
  config/kde/Majula.colors
  config/waybar/config.jsonc
  config/waybar/style.css
  config/rofi/config.rasi
  config/rofi/majula.rasi
  config/kitty/kitty.conf
  config/dunst/dunstrc
  config/vscode/settings.json
  scripts/session/clipboard-menu
  scripts/session/session-menu
  scripts/session/screenshot
  scripts/apply-theme
  systemd/user/simple-custom-arch-session.target
  systemd/user/simple-custom-arch-waybar.service
  systemd/user/simple-custom-arch-hyprpaper.service
  systemd/user/simple-custom-arch-hypridle.service
  systemd/user/simple-custom-arch-cliphist.service
)

for relative in "${required_files[@]}"; do
  [[ -f "$project_root/$relative" ]] || fail "missing $relative"
done

for settings_file in \
  "$project_root/config/gtk-3.0/settings.ini" \
  "$project_root/config/gtk-4.0/settings.ini"; do
  rg -Fq -- 'gtk-application-prefer-dark-theme=true' "$settings_file" ||
    fail "${settings_file#"$project_root/"} must prefer dark applications"
  rg -Fq -- 'gtk-icon-theme-name=breeze-dark' "$settings_file" ||
    fail "${settings_file#"$project_root/"} must use Breeze Dark icons"
done

for gtk_css in \
  "$project_root/config/gtk-3.0/gtk.css" \
  "$project_root/config/gtk-4.0/gtk.css"; do
  for color in 0E1114 171C20 20272C 465056 DDD6C6 D1A35C E0783E C06452; do
    rg -Fqi -- "#$color" "$gtk_css" ||
      fail "${gtk_css#"$project_root/"} is missing Majula color #$color"
  done
done

rg -Fq -- 'ColorScheme=Majula' "$project_root/config/kde/kdeglobals" ||
  fail 'KDE applications must use the Majula color scheme'
rg -Fq -- 'Theme=breeze-dark' "$project_root/config/kde/kdeglobals" ||
  fail 'KDE applications must use Breeze Dark icons'
rg -Fq -- 'Name=Majula' "$project_root/config/kde/Majula.colors" ||
  fail 'Majula KDE color scheme must be named Majula'
rg -Fq -- 'QT_STYLE_OVERRIDE=Fusion' \
  "$project_root/config/environment.d/90-simple-custom-arch-theme.conf" ||
  fail 'Qt applications must use the installed Fusion style'
rg -Fq -- 'QT_QPA_PLATFORMTHEME=gtk3' \
  "$project_root/config/environment.d/90-simple-custom-arch-theme.conf" ||
  fail 'Qt applications must inherit the GTK dark palette'

rg -Fq -- 'modes: "drun,window,run,filebrowser"' \
  "$project_root/config/rofi/config.rasi" ||
  fail 'Rofi must expose application, window, command, and file modes'
rg -Fq -- 'drun-show-actions: true' "$project_root/config/rofi/config.rasi" ||
  fail 'Rofi must expose desktop application actions'
rg -Fq -- 'sidebar-mode: true' "$project_root/config/rofi/config.rasi" ||
  fail 'Rofi must show mode navigation'
rg -Fq -- 'background-color: @background;' "$project_root/config/rofi/majula.rasi" ||
  fail 'Rofi must set an explicit dark root background'

palette=(
  0E1114 171C20 20272C 465056 DDD6C6 A39B8C
  D1A35C E0783E 7899A2 87996D C06452
)
for value in "${palette[@]}"; do
  rg -qi -- "#$value" \
    "$project_root/config/waybar/style.css" \
    "$project_root/config/rofi/majula.rasi" \
    "$project_root/config/kitty/kitty.conf" \
    "$project_root/config/dunst/dunstrc" \
    "$project_root/config/vscode/settings.json" ||
    fail "Majula color #$value is absent from application configuration"
done

rg -q '"height"[[:space:]]*:[[:space:]]*28' \
  "$project_root/config/waybar/config.jsonc" || fail 'Waybar must be 28 pixels high'
if rg -qi 'battery' "$project_root/config/waybar/config.jsonc"; then
  fail 'Waybar must not configure a battery module'
fi
for removed_module in \
  '"network":' '"bluetooth":' '"backlight":' '"cpu":' '"memory":' \
  '"custom/session":' '"custom/power":'; do
  if rg -Fq -- "$removed_module" "$project_root/config/waybar/config.jsonc"; then
    fail "Waybar must not configure $removed_module"
  fi
done
rg -Fq -- '"modules-right": ["pulseaudio", "tray"]' \
  "$project_root/config/waybar/config.jsonc" ||
  fail 'Waybar right modules must contain only audio and tray'
rg -Fqi -- '#DDD6C6' \
  "$project_root/config/icons/hicolor/22x22/apps/nm-signal-100.svg" ||
  fail 'Network tray icon must use the Majula text color'
rg -Fq -- 'Directories=22x22/apps,scalable/apps' \
  "$project_root/config/icons/hicolor/index.theme" ||
  fail 'Local Hicolor overrides must retain scalable application icons'

workspace_codes=('1] = 87' '2] = 88' '3] = 89' '4] = 83' '5] = 84' '6] = 85' '7] = 79' '8] = 80' '9] = 81')
for mapping in "${workspace_codes[@]}"; do
  rg -Fq -- "[$mapping" "$project_root/config/hypr/majula.lua" ||
    fail "missing workspace keypad mapping: [$mapping"
done
rg -Fq -- 'mainMod .. " + code:" .. code' "$project_root/config/hypr/majula.lua" ||
  fail 'workspace bindings must use physical keypad codes'
rg -Fq -- 'mainMod .. " + SHIFT + code:" .. code' "$project_root/config/hypr/majula.lua" ||
  fail 'workspace move bindings must use physical keypad codes'
rg -Fq -- 'mainMod .. " + code:90"' "$project_root/config/hypr/majula.lua" ||
  fail 'Rofi must be available on Super plus keypad 0'

for gap in 'gaps_in = 6' 'gaps_out = 6'; do
  rg -Fq -- "$gap" "$project_root/config/hypr/majula.lua" ||
    fail "Hyprland must use six-pixel gaps: $gap"
done

for binding in \
  'ALT + code:80' 'ALT + code:88' \
  'ALT + code:85' 'ALT + code:83' 'ALT + code:84' \
  'ALT + code:90' 'ALT + code:81' 'ALT + code:79'; do
  rg -Fq -- "$binding" "$project_root/config/hypr/majula.lua" ||
    fail "missing keypad control binding: $binding"
done

for command_name in \
  zen-browser code loginctl simple-custom-arch-clipboard-menu \
  simple-custom-arch-screenshot simple-custom-arch-session-menu; do
  rg -Fq -- "$command_name" "$project_root/config/hypr/majula.lua" ||
    fail "missing application binding command: $command_name"
done

rg -Fq -- 'background_opacity 0.84' "$project_root/config/kitty/kitty.conf" ||
  fail 'Kitty must use 84% background opacity'
rg -Fq -- '"workbench.colorTheme": "Dark Modern"' \
  "$project_root/config/vscode/settings.json" ||
  fail 'VS Code must use its built-in Dark Modern base theme'

if rg -ni '(systemctl[[:space:]]+(suspend|hibernate|reboot|poweroff)|loginctl[[:space:]]+(suspend|hibernate|reboot|poweroff)|shutdown([[:space:]]|$)|reboot([[:space:]]|$))' \
  "$project_root/config" "$project_root/scripts/session" "$project_root/systemd/user"; then
  fail 'desktop configuration must not contain automatic power actions'
fi

for script in "$project_root"/scripts/session/*; do
  [[ -x "$script" ]] || fail "${script#"$project_root/"} must be executable"
  head -n 3 "$script" | rg -q 'set -euo pipefail' ||
    fail "${script#"$project_root/"} must use Bash strict mode"
done

for unit in "$project_root"/systemd/user/*.service; do
  rg -Fq 'PartOf=simple-custom-arch-session.target' "$unit" ||
    fail "${unit#"$project_root/"} must belong to the project session target"
  rg -Fq 'Restart=on-failure' "$unit" ||
    fail "${unit#"$project_root/"} must restart only on failure"
done

rg -Fq 'BindsTo=graphical-session.target' \
  "$project_root/systemd/user/simple-custom-arch-session.target" ||
  fail 'session target must bind to graphical-session.target'
rg -Fq 'Wants=dunst.service' \
  "$project_root/systemd/user/simple-custom-arch-session.target" ||
  fail 'session target must start the package-provided Dunst service'

python -m json.tool "$project_root/config/vscode/settings.json" >/dev/null ||
  fail 'VS Code settings must be valid JSON'
bash -n "$project_root/scripts/apply-theme" || fail 'theme settings script must be valid Bash'
xmllint --noout "$project_root/config/hypr/assets/majula-wallpaper.svg" ||
  fail 'wallpaper must be valid SVG'
xmllint --noout "$project_root/config/icons/hicolor/22x22/apps/nm-signal-100.svg" ||
  fail 'network tray icon must be valid SVG'

printf 'PASS: additive desktop configuration contract\n'
