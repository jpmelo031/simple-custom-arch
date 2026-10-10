#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
menu="$project_root/scripts/session/power-menu"
tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/simple-custom-arch-power-menu.XXXXXX")"
trap 'rm -rf -- "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

cat > "$tmp_dir/bin/rofi" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
response="$(head -n 1 "$POWER_MENU_RESPONSES")"
sed -i '1d' "$POWER_MENU_RESPONSES"
printf '%s\n' "$response"
EOF

cat > "$tmp_dir/bin/systemctl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$POWER_MENU_SYSTEMCTL_LOG"
EOF

chmod 0755 "$tmp_dir/bin/rofi" "$tmp_dir/bin/systemctl"

run_case() {
  local name=$1
  local responses=$2
  local expected=$3
  local response_file="$tmp_dir/$name.responses"
  local log_file="$tmp_dir/$name.log"

  printf '%b' "$responses" > "$response_file"
  : > "$log_file"

  PATH="$tmp_dir/bin:$PATH" \
    POWER_MENU_RESPONSES="$response_file" \
    POWER_MENU_SYSTEMCTL_LOG="$log_file" \
    "$menu"

  if [[ -n "$expected" ]]; then
    [[ "$(cat "$log_file")" == "$expected" ]] || {
      printf 'FAIL: %s expected systemctl %s\n' "$name" "$expected" >&2
      exit 1
    }
  elif [[ -s "$log_file" ]]; then
    printf 'FAIL: %s must not call systemctl\n' "$name" >&2
    exit 1
  fi
}

run_case shutdown-confirmed 'Shut Down\nYes\n' poweroff
run_case restart-confirmed 'Restart\nYes\n' reboot
run_case shutdown-declined 'Shut Down\nNo\n' ''
run_case cancelled 'Cancel\n' ''

printf 'PASS: confirmed power menu behavior\n'
