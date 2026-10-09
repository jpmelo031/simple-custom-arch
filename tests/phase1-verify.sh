#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
module="$project_root/scripts/lib/phase1-verify.sh"
fixture_root="$(mktemp -d)"
trap 'rm -rf -- "$fixture_root"' EXIT

fail_test() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -f "$module" ]] || fail_test 'scripts/lib/phase1-verify.sh does not exist'

# shellcheck source=../scripts/lib/phase1-verify.sh
source "$module"

new_repository_fixture() {
  local fixture
  fixture="$(mktemp -d "$fixture_root/repository.XXXXXX")"
  cp -a -- \
    "$project_root/AGENTS.md" \
    "$project_root/README.md" \
    "$project_root/ROADMAP.md" \
    "$project_root/config" \
    "$project_root/docs" \
    "$project_root/packages" \
    "$project_root/scripts" \
    "$project_root/systemd" \
    "$project_root/tests" \
    "$fixture/"
  printf '%s\n' "$fixture"
}

expect_pass() {
  local name=$1
  shift
  local output
  if ! output="$("$@" 2>&1)"; then
    fail_test "$name should pass; output: $output"
  fi
}

expect_fail_containing() {
  local name=$1
  local expected=$2
  shift 2
  local output
  if output="$("$@" 2>&1)"; then
    fail_test "$name should fail"
  fi
  [[ "$output" == *"$expected"* ]] ||
    fail_test "$name should mention '$expected'; output: $output"
}

run_repository_fixture() {
  local fixture=$1
  local shim_dir="$fixture_root/shims"
  local marker="$fixture_root/system-query.marker"
  local command_name

  mkdir -p -- "$shim_dir"
  rm -f -- "$marker"
  for command_name in \
    pacman systemctl nmcli pactl wpctl bluetoothctl vainfo vulkaninfo \
    eglinfo java hyprctl steam prismlauncher checkupdates paccache pacdiff \
    brightnessctl playerctl hostnamectl id; do
    cat > "$shim_dir/$command_name" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${0##*/}" >> "$SYSTEM_QUERY_MARKER"
exit 99
EOF
    chmod +x "$shim_dir/$command_name"
  done

  SYSTEM_QUERY_MARKER="$marker" PATH="$shim_dir:$PATH" \
    "$fixture/scripts/verify" --root "$fixture"
  [[ ! -e "$marker" ]] || fail_test 'fixture verification queried the running system'
}

run_repository_check() {
  local fixture=$1
  (
    failures=0
    pass() { :; }
    fail() {
      printf '[FAIL] %s: %s\n' "$1" "$2" >&2
      failures=$((failures + 1))
    }
    phase1_verify_repository "$fixture"
    ((failures == 0))
  )
}

new_system_snapshot() {
  local snapshot
  snapshot="$(mktemp -d "$fixture_root/system.XXXXXX")"

  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' \
    "$project_root/packages/official.txt" > "$snapshot/official-explicit.txt"
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' \
    "$project_root/packages/aur.txt" > "$snapshot/foreign-explicit.txt"
  cat "$snapshot/official-explicit.txt" "$snapshot/foreign-explicit.txt" |
    LC_ALL=C sort -u > "$snapshot/installed-all.txt"
  : > "$snapshot/orphans.txt"

  cat > "$snapshot/commands.txt" <<'EOF'
bluetoothctl
brightnessctl
checkupdates
eglinfo
java
nmcli
paccache
pacdiff
pactl
playerctl
prismlauncher
steam
vainfo
vulkaninfo
wpctl
EOF
  cat > "$snapshot/failed-system.txt" <<'EOF'
systemd-pcrlogin@alpha.service loaded failed failed
systemd-pcrlogin@omega.service loaded failed failed
systemd-pcrproduct.service loaded failed failed
systemd-tpm2-setup-early.service loaded failed failed
EOF
  : > "$snapshot/failed-user.txt"
  cat > "$snapshot/services.txt" <<'EOF'
NetworkManager.service active
bluetooth.service active
pipewire-pulse.service active
pipewire.service active
sddm.service active
ufw.service active
wireplumber.service active
EOF
  printf 'full\n' > "$snapshot/network.txt"
  printf 'Server Name: PulseAudio (on PipeWire)\nAudio Sinks Sources\n' > "$snapshot/audio.txt"
  printf 'Powered: yes\n' > "$snapshot/bluetooth.txt"
  printf 'Driver version: Intel iHD driver\n' > "$snapshot/vaapi.txt"
  printf 'deviceName = Intel Graphics\n' > "$snapshot/vulkan.txt"
  printf 'OpenGL vendor string: Intel\n' > "$snapshot/opengl.txt"
  printf 'openjdk version "21.0.8"\n' > "$snapshot/java.txt"
  printf 'steam\nprismlauncher\n' > "$snapshot/launchers.txt"
  printf '[{"width":1366,"height":768}]\n' > "$snapshot/session.txt"

  printf '%s\n' "$snapshot"
}

run_system_check() {
  local snapshot=$1
  (
    failures=0
    pass() { :; }
    fail() {
      printf '[FAIL] %s: %s\n' "$1" "$2" >&2
      failures=$((failures + 1))
    }
    phase1_verify_system "$project_root" "$snapshot"
    ((failures == 0))
  )
}

fixture="$(new_repository_fixture)"
expect_pass 'isolated repository fixture' run_repository_fixture "$fixture"

fixture="$(new_repository_fixture)"
sed -i '/^linux-lts$/d' "$fixture/packages/official.txt"
expect_fail_containing 'missing fallback kernel' 'linux-lts' run_repository_check "$fixture"

fixture="$(new_repository_fixture)"
printf 'base\n' >> "$fixture/packages/official.txt"
expect_fail_containing 'duplicate desired entry' 'official.txt' run_repository_check "$fixture"

fixture="$(new_repository_fixture)"
{
  sed -n '2p' "$fixture/packages/official.txt"
  sed -n '1p;3,$p' "$fixture/packages/official.txt"
} > "$fixture/packages/official.unsorted"
mv -- "$fixture/packages/official.unsorted" "$fixture/packages/official.txt"
expect_fail_containing 'unsorted desired entries' 'official.txt' run_repository_check "$fixture"

fixture="$(new_repository_fixture)"
printf 'zz-test-package\n' >> "$fixture/packages/official.txt"
expect_fail_containing 'undocumented desired entry' 'zz-test-package' run_repository_check "$fixture"

snapshot="$(new_system_snapshot)"
expect_pass 'complete controlled system snapshot' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
printf 'unexpected-orphan\n' > "$snapshot/orphans.txt"
expect_fail_containing 'unexpected orphan' 'unexpected-orphan' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
sed -i '/pcrlogin@omega/d' "$snapshot/failed-system.txt"
expect_fail_containing 'one login TPM failure' 'system failed units' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
printf 'systemd-pcrlogin@third.service loaded failed failed\n' >> "$snapshot/failed-system.txt"
expect_fail_containing 'three login TPM failures' 'system failed units' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
printf 'example.service loaded failed failed\n' >> "$snapshot/failed-system.txt"
expect_fail_containing 'unrelated system failure' 'example.service' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
sed -i '/^playerctl$/d' "$snapshot/commands.txt"
expect_fail_containing 'missing required command' 'playerctl' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
sed -i '/^brightnessctl$/d' "$snapshot/official-explicit.txt" "$snapshot/installed-all.txt"
expect_fail_containing 'missing desired package' 'brightnessctl' run_system_check "$snapshot"

for wrong_provider in lib32-vulkan-radeon lib32-nvidia-utils; do
  snapshot="$(new_system_snapshot)"
  printf '%s\n' "$wrong_provider" >> "$snapshot/installed-all.txt"
  expect_fail_containing \
    "wrong graphics provider $wrong_provider" \
    "$wrong_provider" \
    run_system_check "$snapshot"
done

snapshot="$(new_system_snapshot)"
: > "$snapshot/session.txt"
expect_fail_containing \
  'missing graphical session data' \
  'session data unavailable' \
  run_system_check "$snapshot"

printf 'PASS: 10/10 Phase 1 verifier behaviors\n'
