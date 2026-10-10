# Phase 0 Project Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete the repository foundation with a mandatory project contract, a standalone roadmap, a purposeful directory structure, a sanitized snapshot of the current notebook, recovery prerequisites, and a read-only Phase 0 verifier.

**Architecture:** Markdown files remain the source of truth for policy, roadmap, baseline, and recovery guidance. Reserved configuration directories make later phases predictable without adding placeholder application configurations, while a small Bash verifier enforces Phase 0 structure, sanitization, package-list ordering, and preview validity without changing the running system.

**Tech Stack:** Markdown, Bash 5, Git, pacman query commands, systemd read-only queries, coreutils, Ripgrep, `xmllint`, `rsvg-convert`

**Spec:** `docs/superpowers/specs/2026-10-08-simple-custom-arch-design.md`

## Global Constraints

- All versioned content is written in English.
- The first release targets the Samsung 300E5M/300E5L notebook described in the spec.
- Priorities remain stability, functionality, performance, visual consistency, and portability, in that order.
- Follow `Inspect -> Plan -> Backup -> Apply -> Verify -> Document` for every system change.
- Phase 0 performs read-only inspection and repository edits only; it must not install or remove packages, enable or disable services, change configuration under the home directory, or modify `/etc`.
- Never commit credentials, cookies, private keys, tokens, hostnames, disk identifiers, serial numbers, UUIDs, MAC addresses, IP addresses, or personal browser data.
- Never perform a partial upgrade or run `pacman -Sy` by itself.
- Prefer official Arch packages; foreign packages are recorded separately and are not assumed to come from the AUR.
- Do not create placeholder executable installers or update scripts. Later phases add them when their behavior can be tested.
- Keep the approved Majula palette and compact geometry unchanged during this phase.
- `scripts/verify` must be read-only, discover the repository root dynamically, and return nonzero when a required Phase 0 check fails.
- Keep all work local until the user explicitly authorizes an upload.

## Review Focus

- **Sensitive baseline data:** a username, home path, hostname, serial, UUID, MAC address, IP address, or credential-like value must make verification fail; Tasks 3 and 4 exercise the scan with an injected home path.
- **Package snapshot drift:** explicit package snapshots must contain one sorted, unique package name per line; Tasks 3 and 4 check unsorted and duplicate input.
- **Ambiguous empty service results:** an empty `systemctl --failed` result must be documented as no failed units rather than producing an empty section; Task 3 verifies both system and user sections have a result.
- **Working-directory assumptions:** `scripts/verify` must work when invoked outside the repository; Task 4 runs it from `/tmp`.
- **Damaged visual baseline:** malformed XML or a preview that no longer renders at 1366x768 must fail verification; Task 4 replaces the fixture SVG with malformed XML and expects failure.

---

### Task 1: Add the Project Contract and Standalone Roadmap

**Files:**
- Create: `AGENTS.md`
- Create: `ROADMAP.md`

**Interfaces:**
- Consumes: project priorities, repository rules, safety rules, work sequence, roadmap phases, and acceptance criteria from the design spec
- Produces: `AGENTS.md` as the mandatory repository contract and `ROADMAP.md` as the phase sequence used by later plans and README status updates

- [ ] **Step 1: Run the initial contract check**

```bash
test -f AGENTS.md && test -f ROADMAP.md
```

Expected: FAIL because neither Phase 0 artifact exists.

- [ ] **Step 2: Create `AGENTS.md`**

Write a concise root-level contract with these sections and exact responsibilities:

- `# Repository Contract`
- `## Priorities` — the five priorities in their approved order.
- `## Language` — all versioned documentation, comments, commits, script output, and project-owned UI text are English.
- `## Safety` — no partial upgrades, remote scripts piped to a shell, unapproved deletion, destructive package operations, unbacked configuration replacement, or power action after failure.
- `## Privacy` — enumerate every prohibited identifier and credential class from the global constraints.
- `## Packages and Services` — official packages first, documented foreign-package exceptions, and documented cost for every background service.
- `## Work Sequence` — include `Inspect -> Plan -> Backup -> Apply -> Verify -> Document` verbatim.
- `## Phase Discipline` — one active roadmap phase; later-phase work is not implemented early.
- `## Scripts` — strict error handling, idempotency, dry-run where applicable, dynamic repository discovery, preserved logs, and no hard-coded home path.
- `## Git` — one logical Conventional Commit in English; changes remain local until explicit upload authorization.
- `## Documentation Ownership` — link README, ROADMAP, theme, maintenance, and package documentation to their responsibilities.

End with the current phase set to `Phase 0 — Project Foundation` and link the design spec and Phase 0 plan.

- [ ] **Step 3: Create `ROADMAP.md`**

Copy the approved Phase 0 through Phase 7 sequence and the future portability milestone from the design spec. Each phase must contain its goal, scope, mandatory rule, acceptance criteria, and status.

Set Phase 0 to `Planned`, all later phases to `Not started`, and state that a phase changes to complete only after every acceptance criterion is verified.

- [ ] **Step 4: Verify contract and roadmap coverage**

```bash
set -e
rg -q '^# Repository Contract$' AGENTS.md
rg -q 'Inspect -> Plan -> Backup -> Apply -> Verify -> Document' AGENTS.md
rg -q 'Never perform partial upgrades' AGENTS.md
rg -q 'explicit upload authorization' AGENTS.md
for phase in 0 1 2 3 4 5 6 7; do
  rg -q "Phase $phase" ROADMAP.md
done
rg -q 'Future Milestone.*Portability' ROADMAP.md
rg -q 'Phase 0.*Planned' ROADMAP.md
git diff --check
```

Expected: every command exits successfully and `git diff --check` prints nothing.

- [ ] **Step 5: Commit the contract and roadmap**

```bash
git add AGENTS.md ROADMAP.md
git commit -m "docs: add project contract and roadmap"
```

---

### Task 2: Create the Purposeful Repository Skeleton

**Files:**
- Create: `config/README.md`
- Create: `config/hypr/.gitkeep`
- Create: `config/kitty/.gitkeep`
- Create: `config/rofi/.gitkeep`
- Create: `config/dunst/.gitkeep`
- Create: `config/waybar/.gitkeep`
- Create: `config/vscode/.gitkeep`
- Create: `config/shell/.gitkeep`
- Create: `packages/README.md`
- Create: `packages/official.txt`
- Create: `packages/aur.txt`
- Create: `scripts/README.md`
- Create: `scripts/lib/.gitkeep`
- Create: `systemd/user/.gitkeep`
- Create: `docs/baseline/README.md`

**Interfaces:**
- Consumes: repository structure and documentation ownership rules from the design spec and Task 1 contract
- Produces: stable paths for application configuration, desired package manifests, scripts, user units, and baseline artifacts used by Tasks 3 and 4

- [ ] **Step 1: Run the initial structure check**

```bash
for path in \
  config/hypr config/kitty config/rofi config/dunst config/waybar \
  config/vscode config/shell packages scripts/lib systemd/user docs/baseline; do
  test -d "$path"
done
```

Expected: FAIL on the first missing directory.

- [ ] **Step 2: Create the configuration skeleton**

Create the seven `config/` application directories and their `.gitkeep` files. In `config/README.md`, define the responsibility of each directory and state that Phase 0 reserves paths only; it does not deploy configuration.

- [ ] **Step 3: Create package manifest placeholders**

Create `packages/README.md` with these distinctions:

- `official.txt` is the desired explicit official-package manifest, populated during Phase 1.
- `aur.txt` is the reviewed desired foreign/AUR manifest, populated during Phase 1.
- Baseline snapshots under `docs/baseline/` describe the current machine and are not desired-state manifests.
- Manifest parsing ignores blank lines and lines beginning with `#`.

Add one English comment to each manifest: `# Populated during Phase 1.`

- [ ] **Step 4: Reserve script, systemd, and baseline paths**

Create `scripts/README.md` describing the future `install`, `update-check`, `update-system`, and `verify` responsibilities without creating fake executable files. Add `scripts/lib/.gitkeep` and `systemd/user/.gitkeep`.

Create `docs/baseline/README.md` with the baseline purpose, the difference between observation and desired state, and a sanitization rule that excludes all prohibited identifiers.

- [ ] **Step 5: Verify the skeleton**

```bash
set -e
for path in \
  config/hypr/.gitkeep config/kitty/.gitkeep config/rofi/.gitkeep \
  config/dunst/.gitkeep config/waybar/.gitkeep config/vscode/.gitkeep \
  config/shell/.gitkeep scripts/lib/.gitkeep systemd/user/.gitkeep; do
  test -f "$path"
done
for path in \
  config/README.md packages/README.md packages/official.txt packages/aur.txt \
  scripts/README.md docs/baseline/README.md; do
  test -s "$path"
done
rg -q 'Populated during Phase 1' packages/official.txt
rg -q 'Populated during Phase 1' packages/aur.txt
git diff --check
```

Expected: all reserved paths and ownership documents exist with no whitespace errors.

- [ ] **Step 6: Commit the repository skeleton**

```bash
git add config packages scripts systemd docs/baseline/README.md
git commit -m "chore: scaffold project structure"
```

---

### Task 3: Record a Sanitized Notebook Baseline

**Files:**
- Modify: `docs/baseline/README.md`
- Create: `docs/baseline/hardware.md`
- Create: `docs/baseline/services.md`
- Create: `docs/baseline/official-explicit.txt`
- Create: `docs/baseline/foreign-explicit.txt`

**Interfaces:**
- Consumes: the current notebook through read-only system queries and the sanitization contract from Tasks 1 and 2
- Produces: a dated, sanitized observation of hardware, explicit packages, failed units, and session components for Phase 1 comparison and Phase 0 verification

- [ ] **Step 1: Run the initial baseline check**

```bash
test -s docs/baseline/hardware.md \
  && test -s docs/baseline/services.md \
  && test -s docs/baseline/official-explicit.txt \
  && test -f docs/baseline/foreign-explicit.txt
```

Expected: FAIL because the machine snapshot does not exist.

- [ ] **Step 2: Inspect hardware without writing raw output to the repository**

Run and review these read-only commands:

```bash
lscpu
lspci -nnk
free -h
lsblk -dn -o NAME,SIZE,TYPE,ROTA,TRAN
hyprctl monitors
uname -r
```

Do not copy the raw output. Write `docs/baseline/hardware.md` manually with the capture date and only these approved fields:

- Device model
- CPU model
- GPU model and active kernel driver
- Total memory
- Storage capacity, media type, and transport without device serial or partition identifiers
- Display resolution, refresh rate, and scale without connector serial or EDID data
- Kernel release
- Session type, compositor, display manager, and session manager

If a command is unavailable or the graphical session is inactive, record `Unavailable during capture` and the command name rather than guessing.

- [ ] **Step 3: Capture sorted explicit package snapshots**

```bash
LC_ALL=C pacman -Qqen | sort -u > /tmp/simple-custom-arch-official-explicit.txt
LC_ALL=C pacman -Qqem | sort -u > /tmp/simple-custom-arch-foreign-explicit.txt
install -m 0644 /tmp/simple-custom-arch-official-explicit.txt docs/baseline/official-explicit.txt
install -m 0644 /tmp/simple-custom-arch-foreign-explicit.txt docs/baseline/foreign-explicit.txt
```

`foreign-explicit.txt` may be empty. Document that an empty file means no explicit foreign packages were reported; it does not mean the query was skipped.

- [ ] **Step 4: Record failed units and session prerequisites**

Inspect:

```bash
systemctl --failed --no-legend --plain
systemctl --user --failed --no-legend --plain
systemctl is-enabled sddm.service
systemctl is-active NetworkManager.service
```

Create `docs/baseline/services.md` with capture date, separate system and user failed-unit sections, and the observed SDDM and NetworkManager states. When a failed-unit query returns no lines, write `No failed system units.` or `No failed user units.` explicitly.

Record unit names and short states only. Do not paste journal output, environment variables, user names, or paths.

- [ ] **Step 5: Document collection and sanitization**

Update `docs/baseline/README.md` with:

- Capture date and target machine description
- Exact read-only commands used
- Package snapshot semantics
- Excluded identifier classes
- Rule that later phases update the baseline only through a dedicated commit

- [ ] **Step 6: Verify ordering, explicit empty states, and sanitization**

```bash
set -e
sort -c docs/baseline/official-explicit.txt
sort -c docs/baseline/foreign-explicit.txt
test -z "$(uniq -d docs/baseline/official-explicit.txt)"
test -z "$(uniq -d docs/baseline/foreign-explicit.txt)"
rg -q 'No failed system units\.|Failed system units:' docs/baseline/services.md
rg -q 'No failed user units\.|Failed user units:' docs/baseline/services.md
if rg -n \
  '(/home/[^/[:space:]]+|/root/|UUID=|PARTUUID=|[[:xdigit:]]{2}(:[[:xdigit:]]{2}){5}|([0-9]{1,3}\.){3}[0-9]{1,3}|ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})' \
  docs/baseline; then
  exit 1
fi
current_user=$(id -un)
current_host=$(hostnamectl --static 2>/dev/null || true)
if rg -Fn "$current_user" docs/baseline; then exit 1; fi
if [ -n "$current_host" ] && rg -Fn "$current_host" docs/baseline; then exit 1; fi
git diff --check
```

Expected: package lists are sorted and unique, both service sections contain explicit results, the sensitive-data scan prints nothing, and the diff has no whitespace errors.

- [ ] **Step 7: Commit the sanitized baseline**

```bash
git add docs/baseline
git commit -m "docs: record sanitized system baseline"
```

---

### Task 4: Add Recovery Guidance and the Phase 0 Verifier

**Files:**
- Create: `docs/maintenance.md`
- Create: `scripts/verify`
- Create: `tests/phase0-verify.sh`
- Modify: `scripts/README.md`
- Modify: `README.md`
- Modify: `ROADMAP.md`

**Interfaces:**
- Consumes: the contract from Task 1, reserved structure from Task 2, baseline from Task 3, and the approved theme artifacts already present in the repository
- Produces: `scripts/verify [--root PATH]` as a read-only Phase 0 acceptance command, recovery prerequisites for future configuration changes, and status documents that mark Phase 0 complete only after verification passes

- [ ] **Step 1: Write the failing verifier tests**

Create executable `tests/phase0-verify.sh`. It must build isolated fixtures under `mktemp -d`, clean them with a trap, and assert these behaviors:

1. A complete fixture passes.
2. Removing `AGENTS.md` fails and names the missing file.
3. Adding a synthetic home-directory path and the current hostname to a baseline document fails the sensitive-data check.
4. Replacing `official-explicit.txt` with unsorted or duplicate package names fails the ordering check.
5. Replacing the preview with malformed XML fails the preview check.
6. Running the real verifier from `/tmp` succeeds, proving root discovery is independent of the current directory.

The test exits nonzero on the first unmet assertion and prints one descriptive failure line.

- [ ] **Step 2: Run the verifier tests and confirm failure**

```bash
chmod +x tests/phase0-verify.sh
./tests/phase0-verify.sh
```

Expected: FAIL because `scripts/verify` does not exist.

- [ ] **Step 3: Create `docs/maintenance.md`**

Write these sections:

- `# Maintenance and Recovery`
- `## Phase 0 Scope` — documentation only; no recovery action is executed during this phase.
- `## Before Any Configuration Change` — current-state inspection, planned files, timestamped backup path, rollback command, and verification command.
- `## TTY Recovery Prerequisites` — confirm TTY login, network access, repository location, backup location, and a non-graphical session path.
- `## Graphical Session Recovery` — stop at diagnosis, inspect user services and Hyprland errors, restore the affected backup, then retry the session.
- `## Package Recovery` — use complete upgrades only, inspect Pacman locks rather than deleting them blindly, and use Arch installation media plus chroot when the installed system cannot boot.
- `## Restore Contract` — restore only the affected paths, preserve the failed state and logs, verify ownership and permissions, and never restart or power off before successful checks.
- `## Logs and State` — future project logs and backups live under `~/.local/state/simple-custom-arch/`; these runtime files are never committed.
- `## Phase 0 Verification` — run `./scripts/verify` and describe the successful exit code.

Clearly label commands that would alter the current session or require root privileges as recovery procedures, not Phase 0 test steps.

- [ ] **Step 4: Create `scripts/verify`**

Implement an executable Bash script with this interface:

```text
scripts/verify [--root PATH]
```

- With no argument, resolve the repository root from the script location.
- `--root PATH` validates a fixture and exists for automated testing.
- Invalid arguments print usage and exit 2.
- Passing checks print `[PASS] <name>` and exit 0.
- Failing checks print `[FAIL] <name>: <reason>` to stderr and exit 1 after reporting every failure.
- The script writes only a temporary rendered PNG created with `mktemp`; a trap removes it.

Check these Phase 0 conditions:

- Required files and reserved directories exist.
- `official-explicit.txt` and `foreign-explicit.txt` are sorted and contain no duplicate nonblank entries.
- Baseline documents contain none of the sensitive patterns from Task 3, the current user name, or the current hostname.
- `docs/assets/theme-preview.svg` is well-formed XML, has `viewBox="0 0 1366 768"`, and renders to a 1366x768 PNG.
- The eleven approved palette values appear in both `docs/theme.md` and the SVG.
- `git diff --check` passes when the target contains `.git`.

Before running checks, verify that `rg`, `xmllint`, `rsvg-convert`, `file`, and `sort` are available. Name every missing command as a failure instead of exiting through `command not found`.

- [ ] **Step 5: Make verifier tests pass**

```bash
chmod +x scripts/verify
./tests/phase0-verify.sh
```

Expected: PASS for all six behaviors with exit 0.

- [ ] **Step 6: Update navigation and script documentation**

Update `scripts/README.md` so `verify` is marked implemented and the future scripts remain planned.

Update `README.md`:

- Add links to `AGENTS.md`, `ROADMAP.md`, `docs/baseline/README.md`, `docs/maintenance.md`, and the Phase 0 plan.
- Add the foundation, baseline, recovery guide, and verifier to Completed.
- Keep Phase 0 marked in progress until the acceptance checks pass.

- [ ] **Step 7: Run the complete Phase 0 acceptance checks**

```bash
set -e
./tests/phase0-verify.sh
./scripts/verify
git diff --check
git status --short
```

Expected: both scripts exit 0, the diff has no whitespace errors, and only Task 4 files are modified or new.

Render and inspect the approved preview once more:

```bash
rsvg-convert -w 1366 -h 768 \
  -o /tmp/simple-custom-arch-phase-0-preview.png \
  docs/assets/theme-preview.svg
file /tmp/simple-custom-arch-phase-0-preview.png
```

Expected: `file` reports a 1366 x 768 PNG. Visual inspection confirms no clipping or layout drift from the approved 4-pixel-gap preview.

- [ ] **Step 8: Mark Phase 0 complete and verify the status-only diff**

After Step 7 passes, update `README.md` and `ROADMAP.md`:

- Set Phase 0 to `Complete`.
- Set Phase 1 to `Planned` and make planning Phase 1 the next step.
- State that no Phase 1 package installation or removal has started.

Run:

```bash
./scripts/verify
git diff --check
```

Expected: the verifier remains green and the status-only edits introduce no whitespace errors.

- [ ] **Step 9: Commit the completed foundation**

```bash
git add README.md ROADMAP.md docs/maintenance.md scripts/README.md \
  scripts/verify tests/phase0-verify.sh
git commit -m "docs: complete phase 0 foundation"
```
