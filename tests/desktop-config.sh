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
  systemd/user/simple-custom-arch-session.target
  systemd/user/simple-custom-arch-waybar.service
  systemd/user/simple-custom-arch-hyprpaper.service
  systemd/user/simple-custom-arch-hypridle.service
  systemd/user/simple-custom-arch-cliphist.service
)

for relative in "${required_files[@]}"; do
  [[ -f "$project_root/$relative" ]] || fail "missing $relative"
done

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
for removed_module in network bluetooth backlight cpu memory custom/session custom/power; do
  if rg -Fq -- "$removed_module" "$project_root/config/waybar/config.jsonc"; then
    fail "Waybar must not configure $removed_module"
  fi
done
rg -Fq -- '"modules-right": ["pulseaudio", "tray"]' \
  "$project_root/config/waybar/config.jsonc" ||
  fail 'Waybar right modules must contain only audio and tray'

workspace_codes=('1] = 87' '2] = 88' '3] = 89' '4] = 83' '5] = 84' '6] = 85' '7] = 79' '8] = 80' '9] = 81')
for mapping in "${workspace_codes[@]}"; do
  rg -Fq -- "[$mapping" "$project_root/config/hypr/majula.lua" ||
    fail "missing workspace keypad mapping: [$mapping"
done
rg -Fq -- 'mainMod .. " + code:" .. code' "$project_root/config/hypr/majula.lua" ||
  fail 'workspace bindings must use physical keypad codes'
rg -Fq -- 'mainMod .. " + SHIFT + code:" .. code' "$project_root/config/hypr/majula.lua" ||
  fail 'workspace move bindings must use physical keypad codes'

for binding in \
  'ALT + code:80' 'ALT + code:88' \
  'ALT + code:85' 'ALT + code:83' 'ALT + code:84' \
  'ALT + code:90' 'ALT + code:81' 'ALT + code:79'; do
  rg -Fq -- "$binding" "$project_root/config/hypr/majula.lua" ||
    fail "missing keypad control binding: $binding"
done

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
xmllint --noout "$project_root/config/hypr/assets/majula-wallpaper.svg" ||
  fail 'wallpaper must be valid SVG'

printf 'PASS: additive desktop configuration contract\n'
