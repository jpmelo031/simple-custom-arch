#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode=${1:-}
readme="$project_root/README.md"
roadmap="$project_root/ROADMAP.md"
agents="$project_root/AGENTS.md"
theme="$project_root/docs/theme.md"
maintenance="$project_root/docs/maintenance.md"
desktop_spec="$project_root/docs/superpowers/specs/2026-10-09-additive-desktop-configuration-design.md"
desktop_plan="$project_root/docs/superpowers/plans/2026-10-09-additive-desktop-configuration.md"

if [[ $# -gt 1 || ( -n "$mode" && "$mode" != complete ) ]]; then
  printf 'Usage: %s [complete]\n' "${0##*/}" >&2
  exit 2
fi

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_text() {
  local file=$1
  local value=$2
  rg -Fq -- "$value" "$file" ||
    fail "${file#"$project_root/"} must contain: $value"
}

for document in "$readme" "$roadmap" "$agents" "$theme" "$maintenance" "$desktop_spec" "$desktop_plan"; do
  [[ -f "$document" ]] || fail "missing ${document#"$project_root/"}"
done

for heading in   '## Dependencies'   '## Installation'   '## Keybindings'   '## Managed Services'   '## Backups and Recovery'   '## Verification'; do
  require_text "$readme" "$heading"
done

for binding in   'Super + keypad 0'   'Super + keypad 1…9'   'Super + Shift + keypad 1…9'   'Alt + keypad 8'   'Alt + keypad 6'   'Alt + keypad 5'   'Alt + keypad 0'   'Alt + keypad 9'   'Super + B'   'Super + Shift + C'   'Super + L'   'Super + Shift + V'   'Super + Alt + S'   'Super + Shift + E'; do
  require_text "$readme" "$binding"
done

require_text "$readme" 'Inner and outer Hyprland gaps: 6 px.'
require_text "$readme" 'Kitty background opacity: 84%.'
require_text "$theme" '| Outer screen gap | `6 px`'
require_text "$theme" '| Tiled window gap | `6 px`'
require_text "$theme" 'at 84% opacity'
require_text "$desktop_spec" 'Six-pixel inner and outer gaps.'
require_text "$desktop_spec" '84% background opacity'
require_text "$desktop_plan" '**Implementation status:** Complete'
require_text "$agents" 'Completed phases: **Phase 0 through Phase 4**.'
require_text "$roadmap" '### Phase 4 — Majula Visual System — Complete'
require_text "$maintenance" '~/.local/state/simple-custom-arch/backups/'
require_text "$maintenance" 'Never reboot or shut down automatically.'
require_text "$maintenance" 'pacman -Syu'

if rg -Fq -- 'config/shell' "$project_root/config/README.md"; then
  fail 'config/README.md must not advertise an empty shell configuration'
fi

if rg -n '^[[:space:]]*(sudo[[:space:]]+)?pacman[[:space:]]+-Sy([[:space:]]|$)' "$project_root"   --glob '!docs/superpowers/**' >/dev/null; then
  fail 'current documentation must not present pacman -Sy as a runnable command'
fi

printf 'PASS: desktop documentation contract\n'
