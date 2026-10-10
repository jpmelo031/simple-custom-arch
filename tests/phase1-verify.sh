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

new_repository_fixture() {
  local fixture
  fixture="$(mktemp -d "$fixture_root/repository.XXXXXX")"
  install -d -m 0755 -- "$fixture/packages"
  cp -a -- "$project_root/packages/." "$fixture/packages/"
  printf '%s\n' "$fixture"
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

  cat "$project_root/packages/official.txt" "$project_root/packages/aur.txt" |
    LC_ALL=C sort -u > "$snapshot/installed-all.txt"

  cat > "$snapshot/commands.txt" <<'EOF'
brightnessctl
cliphist
code
dolphin
dunst
gsettings
grim
hyprctl
hypridle
hyprlock
hyprpaper
kitty
loginctl
nm-applet
playerctl
rofi
rsvg-convert
slurp
systemctl
uwsm
waybar
wl-copy
wl-paste
wpctl
xdg-user-dir
zen-browser
EOF
  : > "$snapshot/failed-user.txt"
  cat > "$snapshot/services.txt" <<'EOF'
simple-custom-arch-session.target active
simple-custom-arch-waybar.service active
simple-custom-arch-hyprpaper.service active
simple-custom-arch-hypridle.service active
simple-custom-arch-cliphist.service active
dunst.service active
EOF
  printf '[{"width":1366,"height":768}]\n' > "$snapshot/session.txt"
  : > "$snapshot/configerrors.txt"

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
expect_pass 'complete dependency repository' run_repository_check "$fixture"

fixture="$(new_repository_fixture)"
sed -i '/^waybar$/d' "$fixture/packages/official.txt"
expect_fail_containing 'missing status bar dependency' 'waybar' run_repository_check "$fixture"

fixture="$(new_repository_fixture)"
printf 'adwaita-cursors\n' >> "$fixture/packages/official.txt"
expect_fail_containing 'duplicate dependency' 'official.txt' run_repository_check "$fixture"

fixture="$(new_repository_fixture)"
printf 'zz-test-package\n' >> "$fixture/packages/official.txt"
expect_fail_containing 'undocumented dependency' 'zz-test-package' run_repository_check "$fixture"

snapshot="$(new_system_snapshot)"
expect_pass 'complete controlled desktop snapshot' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
printf '\n\n' > "$snapshot/configerrors.txt"
expect_pass 'whitespace-only Hyprland response' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
sed -i '/^brightnessctl$/d' "$snapshot/installed-all.txt"
expect_fail_containing 'missing installed dependency' 'brightnessctl' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
sed -i '/^playerctl$/d' "$snapshot/commands.txt"
expect_fail_containing 'missing command' 'playerctl' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
printf 'example.service loaded failed failed\n' > "$snapshot/failed-user.txt"
expect_fail_containing 'failed user unit' 'user units' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
sed -i 's/simple-custom-arch-waybar.service active/simple-custom-arch-waybar.service inactive/' "$snapshot/services.txt"
expect_fail_containing 'inactive project service' 'simple-custom-arch-waybar.service' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
printf 'line 1: invalid value\n' > "$snapshot/configerrors.txt"
expect_fail_containing 'Hyprland configuration error' 'configuration errors' run_system_check "$snapshot"

snapshot="$(new_system_snapshot)"
: > "$snapshot/session.txt"
expect_fail_containing 'missing graphical session' 'session data unavailable' run_system_check "$snapshot"

printf 'PASS: 12/12 desktop verifier behaviors\n'
