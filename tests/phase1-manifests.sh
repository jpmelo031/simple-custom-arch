#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

parse_manifest() {
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$1"
}

validate_manifest() {
  local manifest=$1
  local parsed="$tmp_dir/parsed"
  local sorted="$tmp_dir/sorted"

  parse_manifest "$manifest" > "$parsed"
  LC_ALL=C sort -u "$parsed" > "$sorted"
  cmp -s "$parsed" "$sorted"
}

cat > "$tmp_dir/official.expected" <<'EOF'
adwaita-cursors
breeze-icons
brightnessctl
cliphist
dolphin
dunst
glib2
grim
hypridle
hyprland
hyprlock
hyprpaper
kitty
librsvg
network-manager-applet
noto-fonts
pipewire-pulse
playerctl
qt6-wayland
rofi
slurp
uwsm
waybar
wireplumber
wl-clipboard
xdg-user-dirs
EOF

cat > "$tmp_dir/aur.expected" <<'EOF'
visual-studio-code-bin
zen-browser-bin
EOF

cp "$repo_root/packages/official.txt" "$tmp_dir/official.txt"
cp "$repo_root/packages/aur.txt" "$tmp_dir/aur.txt"

parse_manifest "$tmp_dir/official.txt" > "$tmp_dir/official.actual"
cmp -s "$tmp_dir/official.expected" "$tmp_dir/official.actual" ||
  fail 'official manifest does not match the direct theme dependency set'

parse_manifest "$tmp_dir/aur.txt" > "$tmp_dir/aur.actual"
cmp -s "$tmp_dir/aur.expected" "$tmp_dir/aur.actual" ||
  fail 'foreign manifest does not match the reviewed application set'

{
  printf '# Test comment\n\n'
  cat "$tmp_dir/official.expected"
  printf '\n# Another test comment\n'
} > "$tmp_dir/comments.txt"
parse_manifest "$tmp_dir/comments.txt" > "$tmp_dir/comments.actual"
cmp -s "$tmp_dir/official.expected" "$tmp_dir/comments.actual" ||
  fail 'manifest parser did not ignore comments and blank lines'

cp "$tmp_dir/official.expected" "$tmp_dir/duplicate.txt"
printf 'base\n' >> "$tmp_dir/duplicate.txt"
if validate_manifest "$tmp_dir/duplicate.txt"; then
  fail 'duplicate package entry was accepted'
fi

{
  sed -n '2p' "$tmp_dir/official.expected"
  sed -n '1p;3,$p' "$tmp_dir/official.expected"
} > "$tmp_dir/unsorted.txt"
if validate_manifest "$tmp_dir/unsorted.txt"; then
  fail 'unsorted package manifest was accepted'
fi

while IFS= read -r package; do
  rg -Fq -- "\`$package\`" "$repo_root/packages/README.md" ||
    fail "$package is missing from packages/README.md"
done < <(cat "$tmp_dir/official.expected" "$tmp_dir/aur.expected")

for package in \
  base-devel bluez efibootmgr intel-ucode jre21-openjdk lib32-mesa \
  lib32-vulkan-intel limine linux linux-lts mkinitcpio prismlauncher steam \
  ufw vulkan-intel yay zram-generator; do
  if cat "$tmp_dir/official.actual" "$tmp_dir/aur.actual" | rg -qx -- "$package"; then
    fail "$package is outside the approved additive desktop scope"
  fi
done

printf 'PASS: theme dependency manifest contract\n'
