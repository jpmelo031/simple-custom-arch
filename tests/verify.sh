#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
verifier="$project_root/scripts/verify"
fixture_root="$(mktemp -d)"
trap 'rm -rf -- "$fixture_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -x "$verifier" ]] || fail 'scripts/verify must exist and be executable'

new_fixture() {
  local fixture
  fixture="$(mktemp -d "$fixture_root/fixture.XXXXXX")"
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
  rmdir -- "$fixture/config/shell" 2>/dev/null || true
  printf '%s\n' "$fixture"
}

expect_pass() {
  local name=$1
  shift
  local output
  if ! output="$("$@" 2>&1)"; then
    fail "$name should pass; verifier output: $output"
  fi
}

expect_fail_containing() {
  local name=$1
  local expected=$2
  shift 2
  local output
  if output="$("$@" 2>&1)"; then
    fail "$name should fail"
  fi
  [[ "$output" == *"$expected"* ]] ||
    fail "$name should mention '$expected'; verifier output: $output"
}

fixture="$(new_fixture)"
expect_pass 'complete repository fixture' "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
rm -- "$fixture/config/kitty/kitty.conf"
expect_fail_containing \
  'missing managed configuration' \
  'config/kitty/kitty.conf' \
  "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
printf 'adwaita-cursors\nadwaita-cursors\n' > "$fixture/packages/official.txt"
expect_fail_containing \
  'duplicate dependency' \
  'packages/official.txt' \
  "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
printf 'zz-test-package\n' >> "$fixture/packages/official.txt"
expect_fail_containing \
  'undocumented dependency' \
  'zz-test-package' \
  "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
printf '<svg>\n' > "$fixture/docs/assets/theme-preview.svg"
expect_fail_containing \
  'malformed theme preview' \
  'theme preview' \
  "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
shim_dir="$fixture_root/shims"
marker="$fixture_root/system-query.marker"
mkdir -p -- "$shim_dir"
for command_name in hyprctl pacman systemctl; do
  cat > "$shim_dir/$command_name" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${0##*/}" >> "$SYSTEM_QUERY_MARKER"
exit 99
EOF
  chmod 0755 "$shim_dir/$command_name"
done
SYSTEM_QUERY_MARKER="$marker" PATH="$shim_dir:$PATH" \
  "$fixture/scripts/verify" --root "$fixture" >/dev/null
[[ ! -e "$marker" ]] || fail '--root queried the running system'

printf 'PASS: 6/6 repository verifier behaviors\n'
