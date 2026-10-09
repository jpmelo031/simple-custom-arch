#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
verifier="$project_root/scripts/verify"
fixture_root="$(mktemp -d)"

cleanup() {
  rm -rf -- "$fixture_root"
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

if [[ ! -x "$verifier" ]]; then
  fail "scripts/verify must exist and be executable"
fi

if ! rg -q '^Completed phase: \*\*Phase 0 — Project Foundation\*\*\.$' "$project_root/AGENTS.md"; then
  fail "AGENTS.md must identify Phase 0 as complete"
fi

if ! rg -q '^Next planned phase: \*\*Phase 1 — Base System and Packages\*\*\.$' "$project_root/AGENTS.md"; then
  fail "AGENTS.md must identify Phase 1 as planned"
fi

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

  printf '%s\n' "$fixture"
}

expect_pass() {
  local name="$1"
  shift
  local output

  if ! output="$("$@" 2>&1)"; then
    fail "$name should pass; verifier output: $output"
  fi
}

expect_fail_containing() {
  local name="$1"
  local expected="$2"
  shift 2
  local output

  if output="$("$@" 2>&1)"; then
    fail "$name should fail"
  fi

  if [[ "$output" != *"$expected"* ]]; then
    fail "$name should mention '$expected'; verifier output: $output"
  fi
}

fixture="$(new_fixture)"
expect_pass "complete fixture" "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
rm -- "$fixture/AGENTS.md"
expect_fail_containing \
  "missing required file" \
  "AGENTS.md" \
  "$fixture/scripts/verify" --root "$fixture"

current_hostname="$(hostnamectl --static 2>/dev/null || true)"
if [[ -z "$current_hostname" && -r /etc/hostname ]]; then
  IFS= read -r current_hostname < /etc/hostname || true
fi
[[ -n "$current_hostname" ]] || fail "could not determine the current hostname for the sensitive-data test"

fixture="$(new_fixture)"
printf '\n/home/alice/private\n%s\n' "$current_hostname" >> "$fixture/docs/baseline/hardware.md"
expect_fail_containing \
  "sensitive baseline data" \
  "sensitive data" \
  "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
printf 'zeta\nalpha\nalpha\n' > "$fixture/docs/baseline/official-explicit.txt"
expect_fail_containing \
  "unsorted and duplicate package snapshot" \
  "official-explicit.txt" \
  "$fixture/scripts/verify" --root "$fixture"

fixture="$(new_fixture)"
printf '<svg>\n' > "$fixture/docs/assets/theme-preview.svg"
expect_fail_containing \
  "malformed theme preview" \
  "theme preview" \
  "$fixture/scripts/verify" --root "$fixture"

run_real_verifier_from_tmp() {
  cd /tmp
  "$verifier" --root "$project_root"
}

expect_pass "explicit repository root from /tmp" run_real_verifier_from_tmp

printf 'PASS: 6/6 Phase 0 verifier behaviors\n'
