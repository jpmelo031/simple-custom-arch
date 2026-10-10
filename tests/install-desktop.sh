#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$project_root/scripts/install-desktop"
fixture_root="$(mktemp -d)"
trap 'rm -rf -- "$fixture_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -x "$installer" ]] || fail 'scripts/install-desktop must exist and be executable'

new_home() {
  local name=$1
  local home="$fixture_root/$name/home"
  install -d -m 0755 -- "$home/.config/hypr"
  printf '%s\n' '-- personal Hyprland sentinel' > "$home/.config/hypr/hyprland.lua"
  printf '%s\n' "$home"
}

run_installer() {
  local home=$1
  shift
  SCA_HOME="$home" SCA_STATE_HOME="${home%/home}/state" "$installer" "$@"
}

home="$(new_home dry-run)"
before="$(sha256sum "$home/.config/hypr/hyprland.lua")"
run_installer "$home" --dry-run >/dev/null
[[ "$before" == "$(sha256sum "$home/.config/hypr/hyprland.lua")" ]] ||
  fail 'dry-run changed hyprland.lua'
[[ ! -e "$home/.config/hypr/majula.lua" ]] || fail 'dry-run created a managed link'
[[ ! -e "${home%/home}/state" ]] || fail 'dry-run created state data'

home="$(new_home apply)"
run_installer "$home" --apply >/dev/null
rg -Fq -- '-- personal Hyprland sentinel' "$home/.config/hypr/hyprland.lua" ||
  fail 'apply did not preserve existing Hyprland content'
[[ "$(rg -Fc 'require("majula")' "$home/.config/hypr/hyprland.lua")" == 1 ]] ||
  fail 'apply must add exactly one Majula import'

managed_paths=(
  .config/hypr/majula.lua
  .config/hypr/hypridle.conf
  .config/hypr/hyprlock.conf
  .config/hypr/hyprpaper.conf
  .local/share/icons/hicolor/index.theme
  .local/share/icons/hicolor/22x22/apps/nm-signal-100.svg
  .config/waybar/config.jsonc
  .config/waybar/style.css
  .config/rofi/config.rasi
  .config/rofi/majula.rasi
  .config/kitty/kitty.conf
  .config/dunst/dunstrc
  .config/Code/User/settings.json
  .local/bin/simple-custom-arch-clipboard-menu
  .local/bin/simple-custom-arch-session-menu
  .local/bin/simple-custom-arch-screenshot
  .config/systemd/user/simple-custom-arch-session.target
  .config/systemd/user/simple-custom-arch-waybar.service
  .config/systemd/user/simple-custom-arch-hyprpaper.service
  .config/systemd/user/simple-custom-arch-hypridle.service
  .config/systemd/user/simple-custom-arch-cliphist.service
)
for relative in "${managed_paths[@]}"; do
  [[ -L "$home/$relative" ]] || fail "apply did not create link: $relative"
done
[[ -s "$home/.local/share/simple-custom-arch/majula-wallpaper.png" ]] ||
  fail 'apply did not render the wallpaper'

backup_root="${home%/home}/state/simple-custom-arch/backups"
[[ "$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d | wc -l)" == 1 ]] ||
  fail 'apply must create one timestamped backup for hyprland.lua'

run_installer "$home" --apply >/dev/null
[[ "$(rg -Fc 'require("majula")' "$home/.config/hypr/hyprland.lua")" == 1 ]] ||
  fail 'repeated apply duplicated the Majula import'
[[ "$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d | wc -l)" == 1 ]] ||
  fail 'repeated apply created an unnecessary backup'

home="$(new_home conflict)"
install -d -m 0755 -- "$home/.config/waybar"
printf '%s\n' 'personal waybar configuration' > "$home/.config/waybar/config.jsonc"
if run_installer "$home" --apply >"$fixture_root/conflict.output" 2>&1; then
  fail 'apply accepted a conflicting destination'
fi
rg -Fq 'config.jsonc' "$fixture_root/conflict.output" ||
  fail 'conflict output did not name the destination'
[[ "$(cat "$home/.config/waybar/config.jsonc")" == 'personal waybar configuration' ]] ||
  fail 'conflicting file was modified'
if rg -Fq 'require("majula")' "$home/.config/hypr/hyprland.lua"; then
  fail 'preflight conflict allowed a partial deployment'
fi

home="$(new_home broken-link)"
install -d -m 0755 -- "$home/.config/rofi"
ln -s -- "$home/missing-target" "$home/.config/rofi/config.rasi"
if run_installer "$home" --apply >"$fixture_root/broken.output" 2>&1; then
  fail 'apply accepted a broken destination link'
fi
rg -Fq 'config.rasi' "$fixture_root/broken.output" ||
  fail 'broken-link output did not name the destination'
[[ -L "$home/.config/rofi/config.rasi" ]] || fail 'broken destination link was replaced'

printf 'PASS: additive desktop deployer\n'
