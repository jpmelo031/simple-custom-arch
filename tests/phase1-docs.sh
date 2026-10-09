#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mode=${1:-}
maintenance="$project_root/docs/maintenance.md"
readme="$project_root/README.md"
roadmap="$project_root/ROADMAP.md"
agents="$project_root/AGENTS.md"
phase1_spec="$project_root/docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md"
phase1_plan="$project_root/docs/superpowers/plans/2026-10-08-phase-1-base-system.md"

if [[ "$mode" != in-progress && "$mode" != complete ]]; then
  printf 'Usage: %s in-progress|complete\n' "${0##*/}" >&2
  exit 2
fi

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_text() {
  local file=$1
  local text=$2
  rg -Fq -- "$text" "$file" || fail "${file#"$project_root/"} must contain: $text"
}

previous_line=0
for heading in \
  '### 1. Preflight' \
  '### 2. Complete Official Upgrade' \
  '### 3. Reviewed Foreign Packages' \
  '### 4. Review `.pacnew` Files' \
  '### 5. Validate the Updated System' \
  '### 6. Retain the Package Cache' \
  '### 7. Recovery and Failure Stops'; do
  line="$(rg -n -F -m 1 -- "$heading" "$maintenance" | cut -d: -f1 || true)"
  [[ -n "$line" ]] || fail "docs/maintenance.md is missing ordered section: $heading"
  ((line > previous_line)) || fail "docs/maintenance.md sections are out of order at: $heading"
  previous_line=$line
done

for command in 'pacman -Syu' 'yay -Sua' 'pacdiff' 'paccache -rk2'; do
  require_text "$maintenance" "$command"
done

require_text "$maintenance" '~/.local/state/simple-custom-arch/backups/'
require_text "$maintenance" 'Never reboot or shut down automatically.'
require_text "$maintenance" 'ext4 does not provide a filesystem snapshot for this procedure'
require_text "$maintenance" 'Inspect `/var/lib/pacman/db.lck`'
require_text "$maintenance" 'Phase 1 design specification'
require_text "$maintenance" 'Phase 1 implementation plan'

if rg -n '^[[:space:]]*(sudo[[:space:]]+)?pacman[[:space:]]+-Sy([[:space:]]|$)' "$maintenance" >/dev/null; then
  fail 'docs/maintenance.md must not present pacman -Sy as a runnable command'
fi

require_text "$readme" '[Phase 1 design specification](docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md)'
require_text "$readme" '[Phase 1 implementation plan](docs/superpowers/plans/2026-10-08-phase-1-base-system.md)'
require_text "$roadmap" '[Phase 1 design specification](docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md)'
require_text "$roadmap" '[Phase 1 implementation plan](docs/superpowers/plans/2026-10-08-phase-1-base-system.md)'
require_text "$agents" '[Phase 1 design specification](docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md)'
require_text "$agents" '[Phase 1 implementation plan](docs/superpowers/plans/2026-10-08-phase-1-base-system.md)'

for document in "$phase1_spec" "$phase1_plan"; do
  require_text "$document" 'arch-linux.efi'
  require_text "$document" 'arch-linux-lts.efi'
done

case "$mode" in
  in-progress)
    require_text "$readme" 'Phase 1 — Base System and Packages is in progress.'
    require_text "$readme" '| 1 | Base system and package manifests | In progress |'
    require_text "$readme" '| 2 | Hyprland core and keybindings | Not started |'
    require_text "$readme" 'No Phase 2 configuration is active.'
    require_text "$roadmap" '### Phase 1 — Base System and Packages — In progress'
    require_text "$roadmap" '**Status:** In progress'
    require_text "$roadmap" '### Phase 2 — Hyprland Core — Not started'
    require_text "$agents" 'Completed phase: **Phase 0 — Project Foundation**.'
    require_text "$agents" 'Active phase: **Phase 1 — Base System and Packages**.'
    require_text "$agents" 'Phase 2 remains not started'
    ;;
  complete)
    require_text "$readme" 'Phase 1 — Base System and Packages is complete.'
    require_text "$readme" '| 1 | Base system and package manifests | Complete |'
    require_text "$readme" '| 2 | Hyprland core and keybindings | Planned |'
    require_text "$roadmap" '### Phase 1 — Base System and Packages — Complete'
    require_text "$roadmap" '### Phase 2 — Hyprland Core — Planned'
    require_text "$agents" 'Completed phase: **Phase 1 — Base System and Packages**.'
    require_text "$agents" 'Next planned phase: **Phase 2 — Hyprland Core and Keybindings**.'
    ;;
esac

printf 'PASS: Phase 1 documentation contract (%s)\n' "$mode"
