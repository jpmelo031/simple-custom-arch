#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
theme_script="$project_root/scripts/apply-theme"
fixture_root="$(mktemp -d)"
trap 'rm -rf -- "$fixture_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -x "$theme_script" ]] || fail 'scripts/apply-theme must exist and be executable'
install -d -m 0755 -- "$fixture_root/bin"
cat > "$fixture_root/bin/gsettings" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

command_name=$1
schema=$2
key=$3
setting="$schema|$key"

case "$command_name" in
  get)
    awk -F '\t' -v setting="$setting" '$1 == setting { print $2; found = 1 } END { if (!found) exit 1 }' "$FAKE_GSETTINGS_STATE"
    ;;
  set)
    value=$4
    if [[ "${FAKE_GSETTINGS_FAIL_KEY:-}" == "$key" ]]; then
      exit 1
    fi
    awk -F '\t' -v setting="$setting" -v value="$value" 'BEGIN { OFS = "\t" } $1 == setting { print setting, value; found = 1; next } { print } END { if (!found) print setting, value }' \
      "$FAKE_GSETTINGS_STATE" > "$FAKE_GSETTINGS_STATE.new"
    mv -- "$FAKE_GSETTINGS_STATE.new" "$FAKE_GSETTINGS_STATE"
    ;;
  *)
    exit 2
    ;;
esac
EOF
chmod 0755 "$fixture_root/bin/gsettings"

state_file="$fixture_root/gsettings.tsv"
cat > "$state_file" <<'EOF'
org.gnome.desktop.interface|color-scheme	'default'
org.gnome.desktop.interface|gtk-theme	'Adwaita'
org.gnome.desktop.interface|icon-theme	'Adwaita'
org.gnome.desktop.interface|cursor-theme	'default'
org.gnome.desktop.interface|cursor-size	24
EOF

run_theme_script() {
  PATH="$fixture_root/bin:$PATH" \
    FAKE_GSETTINGS_STATE="$state_file" \
    SCA_STATE_HOME="$fixture_root/state" \
    "$theme_script" "$@"
}

before="$(sha256sum "$state_file")"
run_theme_script --dry-run >/dev/null
[[ "$before" == "$(sha256sum "$state_file")" ]] || fail 'dry-run changed desktop settings'
[[ ! -e "$fixture_root/state" ]] || fail 'dry-run created state data'

run_theme_script --apply >/dev/null
rg -Fq $'org.gnome.desktop.interface|color-scheme\t\x27prefer-dark\x27' "$state_file" ||
  fail 'apply did not enable the dark color preference'
rg -Fq $'org.gnome.desktop.interface|icon-theme\t\x27breeze-dark\x27' "$state_file" ||
  fail 'apply did not select Breeze Dark icons'
rg -Fq $'org.gnome.desktop.interface|cursor-theme\t\x27Adwaita\x27' "$state_file" ||
  fail 'apply did not select the Adwaita cursor'

backup_root="$fixture_root/state/simple-custom-arch/backups"
[[ "$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d | wc -l)" == 1 ]] ||
  fail 'apply must create one settings backup'
find "$backup_root" -type f -name gsettings.tsv -exec rg -Fq $'icon-theme\t\x27Adwaita\x27' {} \; ||
  fail 'settings backup did not preserve the previous icon theme'

run_theme_script --apply >/dev/null
[[ "$(find "$backup_root" -mindepth 1 -maxdepth 1 -type d | wc -l)" == 1 ]] ||
  fail 'repeated apply created an unnecessary backup'

failure_state_file="$fixture_root/failure-gsettings.tsv"
cat > "$failure_state_file" <<'EOF'
org.gnome.desktop.interface|color-scheme	'default'
org.gnome.desktop.interface|gtk-theme	'Adwaita'
org.gnome.desktop.interface|icon-theme	'Adwaita'
org.gnome.desktop.interface|cursor-theme	'default'
org.gnome.desktop.interface|cursor-size	24
EOF
if PATH="$fixture_root/bin:$PATH" \
  FAKE_GSETTINGS_STATE="$failure_state_file" \
  FAKE_GSETTINGS_FAIL_KEY=icon-theme \
  SCA_STATE_HOME="$fixture_root/failure-state" \
  "$theme_script" --apply >/dev/null 2>&1; then
  fail 'apply accepted a failed settings write'
fi
rg -Fq $'org.gnome.desktop.interface|color-scheme\t\x27default\x27' "$failure_state_file" ||
  fail 'failed apply did not restore the earlier color preference'
rg -Fq $'org.gnome.desktop.interface|icon-theme\t\x27Adwaita\x27' "$failure_state_file" ||
  fail 'failed apply changed the rejected icon preference'

printf 'PASS: desktop theme settings\n'
