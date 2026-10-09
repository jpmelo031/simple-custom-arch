#!/usr/bin/env bash

# Phase 1 verification helpers. This file is sourced by scripts/verify and
# deliberately leaves output formatting and the shared failure counter to it.

phase1_manifest_entries() {
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$1"
}

phase1_verify_repository() {
  local root=$1
  local official="$root/packages/official.txt"
  local foreign="$root/packages/aur.txt"
  local roles="$root/packages/README.md"
  local temp_dir manifest relative parsed sorted package
  local -a removals=(go vim vim-runtime wofi yay-debug)

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/simple-custom-arch-phase1-repository.XXXXXX")"

  for relative in packages/official.txt packages/aur.txt packages/README.md; do
    if [[ -f "$root/$relative" ]]; then
      pass "Phase 1 required file: $relative"
    else
      fail "Phase 1 required file: $relative" "file is missing"
    fi
  done

  if [[ ! -f "$official" || ! -f "$foreign" || ! -f "$roles" ]]; then
    rm -rf -- "$temp_dir"
    return
  fi

  for manifest in "$official" "$foreign"; do
    relative="${manifest#"$root/"}"
    parsed="$temp_dir/${relative##*/}.parsed"
    sorted="$temp_dir/${relative##*/}.sorted"
    phase1_manifest_entries "$manifest" > "$parsed"
    LC_ALL=C sort -u -- "$parsed" > "$sorted"

    if [[ ! -s "$parsed" ]]; then
      fail "Phase 1 manifest: $relative" "manifest has no package entries"
    elif cmp -s -- "$parsed" "$sorted"; then
      pass "Phase 1 manifest: $relative is sorted and unique"
    else
      fail "Phase 1 manifest: $relative" "entries are not sorted and unique"
    fi
  done

  parsed="$temp_dir/official.txt.parsed"
  if rg -Fqx -- 'linux-lts' "$parsed"; then
    pass 'Phase 1 fallback kernel: linux-lts is desired'
  else
    fail 'Phase 1 fallback kernel' 'linux-lts is missing from packages/official.txt'
  fi

  cat > "$temp_dir/foreign.expected" <<'EOF'
visual-studio-code-bin
yay
zen-browser-bin
EOF
  if cmp -s -- "$temp_dir/aur.txt.parsed" "$temp_dir/foreign.expected"; then
    pass 'Phase 1 reviewed foreign package set'
  else
    fail 'Phase 1 reviewed foreign package set' 'packages/aur.txt must contain only visual-studio-code-bin, yay, and zen-browser-bin'
  fi

  while IFS= read -r package; do
    if rg -Fq -- "\`$package\`" "$roles"; then
      :
    else
      fail 'Phase 1 package roles' "$package is not documented in packages/README.md"
    fi
  done < <(cat "$temp_dir/official.txt.parsed" "$temp_dir/aur.txt.parsed")

  for package in "${removals[@]}"; do
    if cat "$temp_dir/official.txt.parsed" "$temp_dir/aur.txt.parsed" | rg -Fqx -- "$package"; then
      fail 'Phase 1 approved removals' "$package must not appear in a desired manifest"
    fi
  done

  if ! rg -q '^\| `multilib`|official `multilib`|official repositories.*`multilib`' "$roles" \
    || ! rg -Fq -- '`lib32-mesa`' "$roles" \
    || ! rg -Fq -- '`lib32-vulkan-intel`' "$roles"; then
    fail 'Phase 1 multilib documentation' 'multilib and both Intel 32-bit providers must be documented'
  else
    pass 'Phase 1 multilib documentation'
  fi

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
    bluetoothctl brightnessctl checkupdates eglinfo java nmcli paccache pacdiff
    pactl playerctl prismlauncher steam vainfo vulkaninfo wpctl
  )
  local -a system_services=(NetworkManager.service bluetooth.service sddm.service ufw.service)
  local -a user_services=(pipewire.service pipewire-pulse.service wireplumber.service)

  install -d -m 0700 -- "$snapshot_dir"

  phase1_capture_command "$snapshot_dir/official-explicit.txt" pacman -Qqen
  phase1_capture_command "$snapshot_dir/foreign-explicit.txt" pacman -Qqem
  phase1_capture_command "$snapshot_dir/installed-all.txt" pacman -Qq
  phase1_capture_command "$snapshot_dir/orphans.txt" pacman -Qdtq

  : > "$snapshot_dir/commands.txt"
  : > "$snapshot_dir/launchers.txt"
  for command_name in "${required_commands[@]}"; do
    if command -v -- "$command_name" >/dev/null 2>&1; then
      printf '%s\n' "$command_name" >> "$snapshot_dir/commands.txt"
      case "$command_name" in
        steam|prismlauncher)
          printf '%s\n' "$command_name" >> "$snapshot_dir/launchers.txt"
          ;;
      esac
    fi
  done

  phase1_capture_command "$snapshot_dir/failed-system.txt" systemctl --failed --no-legend --plain
  phase1_capture_command "$snapshot_dir/failed-user.txt" systemctl --user --failed --no-legend --plain

  : > "$snapshot_dir/services.txt"
  for service in "${system_services[@]}"; do
    status="$(systemctl is-active "$service" 2>/dev/null || true)"
    printf '%s %s\n' "$service" "${status:-unavailable}" >> "$snapshot_dir/services.txt"
  done
  for service in "${user_services[@]}"; do
    status="$(systemctl --user is-active "$service" 2>/dev/null || true)"
    printf '%s %s\n' "$service" "${status:-unavailable}" >> "$snapshot_dir/services.txt"
  done

  phase1_capture_command "$snapshot_dir/network.txt" nmcli -t -f CONNECTIVITY general
  {
    if command -v pactl >/dev/null 2>&1; then
      pactl info 2>&1 || true
    fi
    if command -v wpctl >/dev/null 2>&1; then
      wpctl status 2>&1 || true
    fi
  } > "$snapshot_dir/audio.txt" 2>&1
  phase1_capture_command "$snapshot_dir/bluetooth.txt" bluetoothctl show
  phase1_capture_command "$snapshot_dir/vaapi.txt" vainfo
  phase1_capture_command "$snapshot_dir/vulkan.txt" vulkaninfo --summary
  phase1_capture_command "$snapshot_dir/opengl.txt" eglinfo -B
  phase1_capture_command "$snapshot_dir/java.txt" java -version
  phase1_capture_command "$snapshot_dir/session.txt" hyprctl -j monitors
}

phase1_snapshot_has_line() {
  local file=$1
  local value=$2
  [[ -f "$file" ]] && rg -Fqx -- "$value" "$file"
}

phase1_verify_system() {
  local root=$1
  local snapshot_dir=$2
  local temp_dir package service unit login_count unknown_unit missing_snapshot=0
  local -a required_snapshot_files=(
    official-explicit.txt foreign-explicit.txt installed-all.txt orphans.txt
    commands.txt failed-system.txt failed-user.txt services.txt network.txt audio.txt
    bluetooth.txt vaapi.txt vulkan.txt opengl.txt java.txt launchers.txt session.txt
  )
  local -a required_commands=(
    bluetoothctl brightnessctl checkupdates eglinfo java nmcli paccache pacdiff
    pactl playerctl prismlauncher steam vainfo vulkaninfo wpctl
  )
  local -a required_services=(
    NetworkManager.service bluetooth.service pipewire-pulse.service
    pipewire.service sddm.service ufw.service wireplumber.service
  )
  local -a removals=(go vim vim-runtime wofi yay-debug)
  local -a wrong_providers=(
    lib32-amdvlk lib32-vulkan-radeon lib32-nvidia-utils lib32-vulkan-nouveau
  )

  for package in "${required_snapshot_files[@]}"; do
    if [[ ! -f "$snapshot_dir/$package" ]]; then
      fail 'Phase 1 system snapshot' "missing $package"
      missing_snapshot=1
    fi
  done
  if ((missing_snapshot)); then
    return
  fi

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/simple-custom-arch-phase1-system.XXXXXX")"
  cat "$snapshot_dir/official-explicit.txt" "$snapshot_dir/foreign-explicit.txt" |
    LC_ALL=C sort -u > "$temp_dir/explicit-all.txt"

  while IFS= read -r package; do
    if phase1_snapshot_has_line "$temp_dir/explicit-all.txt" "$package"; then
      :
    else
      fail 'Phase 1 desired packages' "$package is not explicitly installed"
    fi
  done < <(
    phase1_manifest_entries "$root/packages/official.txt"
    phase1_manifest_entries "$root/packages/aur.txt"
  )

  for package in "${removals[@]}"; do
    if phase1_snapshot_has_line "$snapshot_dir/installed-all.txt" "$package"; then
      fail 'Phase 1 approved removals' "$package is still installed"
    fi
  done

  if [[ -s "$snapshot_dir/orphans.txt" ]]; then
    while IFS= read -r package; do
      [[ -n "$package" ]] && fail 'Phase 1 orphan packages' "unexpected orphan: $package"
    done < "$snapshot_dir/orphans.txt"
  else
    pass 'Phase 1 orphan packages: none'
  fi

  for package in "${required_commands[@]}"; do
    if phase1_snapshot_has_line "$snapshot_dir/commands.txt" "$package"; then
      :
    else
      fail 'Phase 1 required commands' "$package is unavailable"
    fi
  done

  login_count=0
  unknown_unit=''
  while read -r unit _; do
    [[ -n "$unit" ]] || continue
    case "$unit" in
      systemd-tpm2-setup-early.service|systemd-pcrproduct.service)
        ;;
      systemd-pcrlogin@*.service)
        login_count=$((login_count + 1))
        ;;
      *)
        unknown_unit=$unit
        ;;
    esac
  done < "$snapshot_dir/failed-system.txt"

  if [[ "$(rg -c '^systemd-tpm2-setup-early\.service[[:space:]]' "$snapshot_dir/failed-system.txt" || true)" == 1 ]] \
    && [[ "$(rg -c '^systemd-pcrproduct\.service[[:space:]]' "$snapshot_dir/failed-system.txt" || true)" == 1 ]] \
    && ((login_count == 2)) \
    && [[ -z "$unknown_unit" ]]; then
    pass 'Phase 1 system failed units: documented TPM NvPCR exception'
  else
    if [[ -n "$unknown_unit" ]]; then
      fail 'Phase 1 system failed units' "unexpected failed unit: $unknown_unit"
    else
      fail 'Phase 1 system failed units' "expected two systemd-pcrlogin instances and the two named TPM units; found $login_count login instance(s)"
    fi
  fi

  if [[ -s "$snapshot_dir/failed-user.txt" ]]; then
    fail 'Phase 1 user failed units' 'one or more user units are failed'
  else
    pass 'Phase 1 user failed units: none'
  fi

  for service in "${required_services[@]}"; do
    if phase1_snapshot_has_line "$snapshot_dir/services.txt" "$service active"; then
      :
    else
      fail 'Phase 1 essential services' "$service is not active"
    fi
  done

  if rg -Fqx -- 'full' "$snapshot_dir/network.txt"; then
    pass 'Phase 1 network connectivity: full'
  else
    fail 'Phase 1 network connectivity' 'NetworkManager does not report full connectivity'
  fi

  if rg -qi 'pipewire' "$snapshot_dir/audio.txt" \
    && rg -qi 'sink' "$snapshot_dir/audio.txt" \
    && rg -qi 'source' "$snapshot_dir/audio.txt"; then
    pass 'Phase 1 PipeWire audio data'
  else
    fail 'Phase 1 PipeWire audio' 'PipeWire sink or source data is unavailable'
  fi

  if rg -q 'Powered:[[:space:]]+yes' "$snapshot_dir/bluetooth.txt"; then
    pass 'Phase 1 Bluetooth controller'
  else
    fail 'Phase 1 Bluetooth controller' 'powered controller data is unavailable'
  fi

  if rg -qi 'intel.*iHD|iHD.*intel' "$snapshot_dir/vaapi.txt"; then
    pass 'Phase 1 Intel VA-API provider'
  else
    fail 'Phase 1 Intel VA-API provider' 'Intel iHD data is unavailable'
  fi
  if rg -qi 'intel' "$snapshot_dir/vulkan.txt"; then
    pass 'Phase 1 Intel Vulkan provider'
  else
    fail 'Phase 1 Intel Vulkan provider' 'Intel Vulkan data is unavailable'
  fi
  if rg -qi 'intel' "$snapshot_dir/opengl.txt"; then
    pass 'Phase 1 Intel OpenGL provider'
  else
    fail 'Phase 1 Intel OpenGL provider' 'Intel OpenGL data is unavailable'
  fi

  for package in "${wrong_providers[@]}"; do
    if phase1_snapshot_has_line "$snapshot_dir/installed-all.txt" "$package"; then
      fail 'Phase 1 Intel 32-bit provider' "$package is installed"
    fi
  done

  if rg -q 'version "21([.]|\")' "$snapshot_dir/java.txt"; then
    pass 'Phase 1 Java 21 runtime'
  else
    fail 'Phase 1 Java runtime' 'Java 21 data is unavailable'
  fi

  for package in steam prismlauncher; do
    if phase1_snapshot_has_line "$snapshot_dir/launchers.txt" "$package"; then
      :
    else
      fail 'Phase 1 launcher executables' "$package is unavailable"
    fi
  done

  if [[ -s "$snapshot_dir/session.txt" ]] && rg -q '"width"[[:space:]]*:' "$snapshot_dir/session.txt"; then
    pass 'Phase 1 graphical session data'
  else
    fail 'Phase 1 graphical session' 'session data unavailable'
  fi

  rm -rf -- "$temp_dir"
}
