#!/usr/bin/env bash

# Desktop dependency and live-session verification helpers. This file is sourced
# by scripts/verify and leaves output formatting and the failure count to it.

phase1_manifest_entries() {
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$1"
}

phase1_verify_repository() {
  local root=$1
  local official="$root/packages/official.txt"
  local foreign="$root/packages/aur.txt"
  local roles="$root/packages/README.md"
  local temp_dir manifest relative parsed sorted package
  local -a required_runtime=(
    brightnessctl cliphist dunst grim hypridle hyprland hyprlock hyprpaper
    kitty librsvg playerctl rofi slurp uwsm waybar wireplumber wl-clipboard
  )
  local -a excluded=(
    base-devel bluez efibootmgr intel-ucode jre21-openjdk lib32-mesa
    lib32-vulkan-intel limine linux linux-lts mkinitcpio prismlauncher steam
    ufw vulkan-intel yay zram-generator
  )

  for relative in packages/official.txt packages/aur.txt packages/README.md; do
    if [[ -f "$root/$relative" ]]; then
      pass "dependency file: $relative"
    else
      fail "dependency file: $relative" 'file is missing'
    fi
  done

  if [[ ! -f "$official" || ! -f "$foreign" || ! -f "$roles" ]]; then
    return
  fi

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/simple-custom-arch-dependencies.XXXXXX")"

  for manifest in "$official" "$foreign"; do
    relative="${manifest#"$root/"}"
    parsed="$temp_dir/${relative##*/}.parsed"
    sorted="$temp_dir/${relative##*/}.sorted"
    phase1_manifest_entries "$manifest" > "$parsed"
    LC_ALL=C sort -u -- "$parsed" > "$sorted"

    if [[ ! -s "$parsed" ]]; then
      fail "dependency manifest: $relative" 'manifest has no package entries'
    elif cmp -s -- "$parsed" "$sorted"; then
      pass "dependency manifest: $relative is sorted and unique"
    else
      fail "dependency manifest: $relative" 'entries are not sorted and unique'
    fi
  done

  cat > "$temp_dir/foreign.expected" <<'EOF'
visual-studio-code-bin
zen-browser-bin
EOF
  if cmp -s -- "$temp_dir/aur.txt.parsed" "$temp_dir/foreign.expected"; then
    pass 'reviewed foreign dependency set'
  else
    fail 'reviewed foreign dependency set' 'packages/aur.txt must contain only visual-studio-code-bin and zen-browser-bin'
  fi

  while IFS= read -r package; do
    if ! rg -Fq -- "\`$package\`" "$roles"; then
      fail 'dependency documentation' "$package is not documented in packages/README.md"
    fi
  done < <(cat "$temp_dir/official.txt.parsed" "$temp_dir/aur.txt.parsed")

  for package in "${required_runtime[@]}"; do
    if ! rg -Fqx -- "$package" "$temp_dir/official.txt.parsed"; then
      fail 'desktop runtime dependencies' "$package is missing from packages/official.txt"
    fi
  done

  for package in "${excluded[@]}"; do
    if cat "$temp_dir/official.txt.parsed" "$temp_dir/aur.txt.parsed" |
      rg -Fqx -- "$package"; then
      fail 'theme-only dependency scope' "$package is unrelated to the deployed theme"
    fi
  done

  rm -rf -- "$temp_dir"
}

phase1_capture_command() {
  local destination=$1
  shift
  if command -v -- "$1" >/dev/null 2>&1; then
    "$@" > "$destination" 2>&1 || true
  else
    : > "$destination"
  fi
}

phase1_capture_system() {
  local snapshot_dir=$1
  local command_name service status
  local -a required_commands=(
    brightnessctl cliphist code dolphin dunst gsettings grim hyprctl hypridle
    hyprlock hyprpaper kitty loginctl nm-applet playerctl rofi rsvg-convert
    slurp systemctl uwsm waybar wl-copy wl-paste wpctl xdg-user-dir zen-browser
  )
  local -a user_services=(
    simple-custom-arch-session.target
    simple-custom-arch-waybar.service
    simple-custom-arch-hyprpaper.service
    simple-custom-arch-hypridle.service
    simple-custom-arch-cliphist.service
    dunst.service
  )

  install -d -m 0700 -- "$snapshot_dir"
  phase1_capture_command "$snapshot_dir/installed-all.txt" pacman -Qq

  : > "$snapshot_dir/commands.txt"
  for command_name in "${required_commands[@]}"; do
    if command -v -- "$command_name" >/dev/null 2>&1; then
      printf '%s\n' "$command_name" >> "$snapshot_dir/commands.txt"
    fi
  done

  phase1_capture_command "$snapshot_dir/failed-user.txt" systemctl --user --failed --no-legend --plain

  : > "$snapshot_dir/services.txt"
  for service in "${user_services[@]}"; do
    status="$(systemctl --user is-active "$service" 2>/dev/null || true)"
    printf '%s %s\n' "$service" "${status:-unavailable}" >> "$snapshot_dir/services.txt"
  done

  phase1_capture_command "$snapshot_dir/session.txt" hyprctl -j monitors
  phase1_capture_command "$snapshot_dir/configerrors.txt" hyprctl configerrors
}

phase1_snapshot_has_line() {
  local file=$1
  local value=$2
  [[ -f "$file" ]] && rg -Fqx -- "$value" "$file"
}

phase1_verify_system() {
  local root=$1
  local snapshot_dir=$2
  local item service missing_snapshot=0
  local -a required_snapshot_files=(
    installed-all.txt commands.txt failed-user.txt services.txt session.txt
    configerrors.txt
  )
  local -a required_commands=(
    brightnessctl cliphist code dolphin dunst gsettings grim hyprctl hypridle
    hyprlock hyprpaper kitty loginctl nm-applet playerctl rofi rsvg-convert
    slurp systemctl uwsm waybar wl-copy wl-paste wpctl xdg-user-dir zen-browser
  )
  local -a required_services=(
    simple-custom-arch-session.target
    simple-custom-arch-waybar.service
    simple-custom-arch-hyprpaper.service
    simple-custom-arch-hypridle.service
    simple-custom-arch-cliphist.service
    dunst.service
  )

  for item in "${required_snapshot_files[@]}"; do
    if [[ ! -f "$snapshot_dir/$item" ]]; then
      fail 'desktop system snapshot' "missing $item"
      missing_snapshot=1
    fi
  done
  if ((missing_snapshot)); then
    return
  fi

  while IFS= read -r item; do
    if ! phase1_snapshot_has_line "$snapshot_dir/installed-all.txt" "$item"; then
      fail 'installed theme dependencies' "$item is not installed"
    fi
  done < <(
    phase1_manifest_entries "$root/packages/official.txt"
    phase1_manifest_entries "$root/packages/aur.txt"
  )

  for item in "${required_commands[@]}"; do
    if ! phase1_snapshot_has_line "$snapshot_dir/commands.txt" "$item"; then
      fail 'desktop commands' "$item is unavailable"
    fi
  done

  if [[ -s "$snapshot_dir/failed-user.txt" ]]; then
    fail 'desktop user units' 'one or more user units are failed'
  else
    pass 'desktop user units: none failed'
  fi

  for service in "${required_services[@]}"; do
    if phase1_snapshot_has_line "$snapshot_dir/services.txt" "$service active"; then
      pass "desktop service: $service"
    else
      fail 'desktop services' "$service is not active"
    fi
  done

  if rg -q '[^[:space:]]' "$snapshot_dir/configerrors.txt"; then
    fail 'Hyprland configuration errors' 'hyprctl reported one or more errors'
  else
    pass 'Hyprland configuration errors: none'
  fi

  if [[ -s "$snapshot_dir/session.txt" ]] &&
    rg -q '"width"[[:space:]]*:' "$snapshot_dir/session.txt"; then
    pass 'graphical session data'
  else
    fail 'graphical session' 'session data unavailable'
  fi
}
