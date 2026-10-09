# Phase 1 Base System and Packages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a documented and verified explicit package set, add a recoverable LTS boot path, install the approved maintenance, media, gaming, and diagnostic tools, and remove only the reviewed redundant packages.

**Architecture:** Repository manifests define desired explicit packages while the existing read-only verifier gains separate repository and live-system checks. System work is staged behind local backups and complete package transactions; boot configuration, cleanup, and the manual LTS boot test remain independent gates so a failure never cascades into the next operation.

**Tech Stack:** Bash 5, Pacman, Yay, systemd, mkinitcpio, Limine, PipeWire, NetworkManager, Intel Mesa/Vulkan/VA-API, Markdown, Git

**Spec:** `docs/superpowers/specs/2026-10-08-phase-1-base-system-design.md`

## Global Constraints

- All versioned content, commit messages, script output, and project-owned interface text are English.
- Priorities remain stability, functionality, performance, visual consistency, and portability, in that order.
- Follow `Inspect -> Plan -> Backup -> Apply -> Verify -> Document` for every system-facing change.
- Never run `pacman -Sy` alone or leave a refreshed database with an incomplete upgrade.
- Never pipe a remote script into a shell.
- Keep the regular `linux` kernel as the default and add `linux-lts` as an always-visible recovery entry.
- Enable only the official `multilib` repository and select Intel 32-bit graphics providers explicitly.
- Add no battery-profile daemon and do not change the current Intel P-state policy.
- Remove only `go`, `vim`, its dependency-only `vim-runtime`, `wofi`, and `yay-debug` after an exact transaction preview.
- Keep `nano`, `libva-intel-driver`, `pipewire-jack`, Bluetooth, CJK fonts, Rofi, Neovim, and the three reviewed foreign packages.
- Treat only `systemd-tpm2-setup-early.service`, `systemd-pcrproduct.service`, and `systemd-pcrlogin@*.service` as documented failed-unit exceptions.
- Never commit credentials, user names, home paths, hostnames, disk identifiers, UUIDs, serial numbers, MAC addresses, IP addresses, boot arguments, or raw logs.
- Runtime logs and backups belong under `~/.local/state/simple-custom-arch/` and remain unversioned.
- Do not restart or shut down automatically. The LTS boot checkpoint requires an explicit manual action after every prior check passes.
- Do not implement Hyprland configuration, keybindings, visual styling, update UI, bootstrap automation, or portability work in Phase 1.
- Keep every commit local until the user explicitly authorizes a push.

## Review Focus

- **Manifest syntax with comments and blank lines:** repository validation must ignore allowed non-package lines while still rejecting duplicate, unsorted, missing, or undocumented package entries; Task 1 tests each case.
- **Fixture isolation:** `scripts/verify --root PATH` must never query the running computer even when system tools are available; Task 2 puts failing command shims first in `PATH` and expects the fixture to pass.
- **Variable login-unit instances:** exactly two `systemd-pcrlogin@*.service` failures with arbitrary instance identifiers must normalize to the documented wildcard without entering versioned output; a changed count or unrelated failed unit must fail, and Task 2 tests each case.
- **Wrong multilib graphics provider:** Steam installation must leave Intel OpenGL and Vulkan providers installed and no AMD or NVIDIA 32-bit Vulkan provider selected; Tasks 2 and 6 exercise controlled and live checks.
- **Removal expansion:** Pacman may add dependency-only packages to a removal transaction; Task 6 compares the complete preview against the five approved names and stops on any other result.

---

### Task 1: Define Desired Package Manifests and Roles

**Files:**
- Modify: `packages/official.txt`
- Modify: `packages/aur.txt`
- Modify: `packages/README.md`
- Create: `tests/phase1-manifests.sh`

**Interfaces:**
- Consumes: the approved additions, retained packages, foreign-package exceptions, and removal set from the Phase 1 spec
- Produces: sorted desired manifests and role documentation consumed by Task 2 repository validation and Tasks 4 and 6 system transactions

- [ ] **Step 1: Write the failing manifest contract test**

Create executable `tests/phase1-manifests.sh`. It must use temporary copies and assert:

1. The real official manifest equals the exact sorted list in Step 3.
2. The real foreign manifest equals `visual-studio-code-bin`, `yay`, and `zen-browser-bin` in that order.
3. Blank lines and comments are ignored by its parser.
4. A duplicated package fails.
5. An unsorted package list fails.
6. Every package in both manifests appears in backticks in `packages/README.md`.
7. The approved removal names do not appear in either desired manifest.

Print `PASS: Phase 1 package manifest contract` only when every assertion passes.

- [ ] **Step 2: Run the test and confirm the placeholder manifests fail**

```bash
chmod +x tests/phase1-manifests.sh
./tests/phase1-manifests.sh
```

Expected: FAIL because both manifests still contain only their Phase 1 placeholder comment.

- [ ] **Step 3: Populate the exact official manifest**

Replace `packages/official.txt` with this sorted desired set:

```text
base
base-devel
bluez
bluez-utils
brightnessctl
dolphin
dunst
efibootmgr
git
github-cli
grim
gst-plugin-pipewire
htop
hyprland
intel-media-driver
intel-ucode
jre21-openjdk
kitty
lib32-mesa
lib32-vulkan-intel
libpulse
libva-intel-driver
libva-utils
libvpl
limine
linux
linux-firmware
linux-lts
mesa-utils
mkinitcpio
nano
neovim
network-manager-applet
networkmanager
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
pacman-contrib
pipewire
pipewire-alsa
pipewire-jack
pipewire-pulse
playerctl
polkit-kde-agent
prismlauncher
qt5-wayland
qt6-wayland
rofi
sddm
slurp
smartmontools
steam
sudo
ttf-dejavu
ttf-liberation
ufw
uwsm
vpl-gpu-rt
vulkan-intel
vulkan-tools
wget
wireplumber
wpa_supplicant
xdg-desktop-portal-hyprland
xdg-user-dirs
xdg-utils
zram-generator
```

Populate `packages/aur.txt` with the three exact foreign packages from Step 1.

- [ ] **Step 4: Document package responsibilities and sources**

Expand `packages/README.md` with grouped tables for core and boot; hardware and Intel graphics; network, Bluetooth, audio, and security; Hyprland prerequisites; applications and fonts; maintenance and diagnostics; gaming and Java; and reviewed foreign packages.

Mention every manifest entry in backticks. Document `multilib` for Steam and the two `lib32-*` providers. State that parsing ignores blank lines and comments, dependencies are resolved by Pacman, and foreign does not automatically mean AUR.

- [ ] **Step 5: Make the contract test pass**

```bash
./tests/phase1-manifests.sh
./tests/phase0-verify.sh
git diff --check
```

Expected: both suites pass and the diff has no whitespace errors.

- [ ] **Step 6: Commit the desired package model**

```bash
git add packages tests/phase1-manifests.sh
git commit -m "docs: define phase 1 package manifests"
```

---

### Task 2: Add Phase 1 Repository and Live-System Verification

**Files:**
- Create: `scripts/lib/phase1-verify.sh`
- Create: `tests/phase1-verify.sh`
- Modify: `scripts/verify`
- Modify: `scripts/README.md`

**Interfaces:**
- Consumes: desired manifests, package roles, documented TPM exceptions, and Phase 0 verifier functions
- Produces: `phase1_verify_repository ROOT`, `phase1_capture_system SNAPSHOT_DIR`, and `phase1_verify_system ROOT SNAPSHOT_DIR`; repository checks run in every mode and live checks run only with no arguments

- [ ] **Step 1: Write failing Phase 1 verifier tests**

Create executable `tests/phase1-verify.sh` with fixtures under `mktemp -d`. Test:

1. A complete repository fixture passes `scripts/verify --root FIXTURE` while command shims for all system-query tools exit 99 and write markers; assert no marker exists.
2. Removing `linux-lts` from `official.txt` fails and names it.
3. A duplicate or unsorted desired entry fails and names the manifest.
4. An undocumented manifest entry fails the role check.
5. A complete controlled system snapshot passes `phase1_verify_system`.
6. An unexpected orphan fails and names it.
7. Two arbitrary `systemd-pcrlogin@<instance>.service` rows normalize to the wildcard; one or three instances and an added `example.service` each fail.
8. A missing required command or desired installed package fails and names it.
9. An AMD or NVIDIA 32-bit Vulkan provider fails the Intel-provider check.
10. Missing graphical-session data fails with `session data unavailable` rather than passing silently.

Print `PASS: 10/10 Phase 1 verifier behaviors` on success.

- [ ] **Step 2: Run the tests and confirm the module is missing**

```bash
chmod +x tests/phase1-verify.sh
./tests/phase1-verify.sh
```

Expected: FAIL because `scripts/lib/phase1-verify.sh` does not exist.

- [ ] **Step 3: Implement the Phase 1 verification module**

Create non-executable `scripts/lib/phase1-verify.sh` with:

```text
phase1_verify_repository ROOT
phase1_capture_system SNAPSHOT_DIR
phase1_verify_system ROOT SNAPSHOT_DIR
```

Use the caller's `pass NAME` and `fail NAME REASON` functions. Repository checks parse allowed comments and blanks, require sorted unique entries, check the exact foreign set, require every desired name in the role document, and reject removal targets.

System capture writes only to `SNAPSHOT_DIR` and records read-only results for packages, orphans, commands, failed units, services, audio, network, Bluetooth, VA-API, Vulkan, OpenGL, Java, and launcher executable presence. It must not start Steam or Prism Launcher because the verifier is read-only. System validation checks desired presence, approved absence, no orphan, exactly two normalized login NvPCR failures plus the two named TPM failures, active essential services, full connectivity, and Intel graphics providers.

- [ ] **Step 4: Extend `scripts/verify` without breaking its interface**

Preserve:

```text
scripts/verify
scripts/verify --root PATH
```

No arguments runs Phase 0, Phase 1 repository, and Phase 1 live checks. `--root PATH` runs repository checks only and never invokes a system query. Extend cleanup to remove the preview image and temporary system snapshot. Require the Phase 1 spec, plan, library, and test paths. Update `scripts/README.md` with both modes.

- [ ] **Step 5: Make fixture verification pass**

```bash
bash -n scripts/verify scripts/lib/phase1-verify.sh tests/phase1-verify.sh
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/phase0-verify.sh
./scripts/verify --root "$PWD"
git diff --check
```

Expected: repository and fixture checks pass. Live verification is not expected to pass before Task 4.

- [ ] **Step 6: Confirm live verification exposes only pre-change gaps**

Run `./scripts/verify` and capture output outside the repository. Require failures for not-yet-installed desired packages, removal targets still present, and the `go` orphan, with no unrelated repository failure. A passing result is a test defect.

- [ ] **Step 7: Commit the Phase 1 verifier**

```bash
git add scripts tests/phase1-verify.sh
git commit -m "feat: add phase 1 system verification"
```

---

### Task 3: Document the Weekly Procedure and Activate Phase 1

**Files:**
- Create: `tests/phase1-docs.sh`
- Modify: `docs/maintenance.md`
- Modify: `README.md`
- Modify: `ROADMAP.md`
- Modify: `AGENTS.md`

**Interfaces:**
- Consumes: the staged update, backup, cleanup, and recovery contract from the spec
- Produces: the manual procedure used by Tasks 4 through 7 and consistent Phase 1 in-progress status

- [ ] **Step 1: Write the failing documentation contract test**

Create executable `tests/phase1-docs.sh` with interface `tests/phase1-docs.sh in-progress|complete`. Require ordered maintenance sections for preflight, complete official upgrade, foreign packages, `.pacnew`, validation, cache retention, and recovery; the commands `pacman -Syu`, `yay -Sua`, `pacdiff`, and `paccache -rk2`; the backup path and no-automatic-reboot rule; the requested Phase 1 status consistently in README, ROADMAP, and AGENTS; Phase 2 not started or planned as appropriate; and links to the Phase 1 spec and plan.

- [ ] **Step 2: Run the test and confirm current status fails**

```bash
chmod +x tests/phase1-docs.sh
./tests/phase1-docs.sh in-progress
```

Expected: FAIL because Phase 1 is planned and the weekly procedure is absent.

- [ ] **Step 3: Expand maintenance and recovery documentation**

Add the exact weekly sequence, preflight, log and backup locations, official-before-foreign ordering, `.pacnew` review, verification, `paccache -rk2` timing, lock inspection, failure stops, and file-level ext4 recovery limits. Ensure `pacman -Sy` appears only in explicit prohibition text, never as a runnable command.

- [ ] **Step 4: Mark Phase 1 in progress**

Update README, ROADMAP, and AGENTS consistently. Keep Phase 0 complete and Phase 2 not started. Link the spec and plan and state that no Phase 2 configuration is active.

- [ ] **Step 5: Verify and commit the documentation**

```bash
./tests/phase1-docs.sh in-progress
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/phase0-verify.sh
./scripts/verify --root "$PWD"
git diff --check
git add AGENTS.md README.md ROADMAP.md docs/maintenance.md tests/phase1-docs.sh
git commit -m "docs: add phase 1 maintenance procedure"
```

Expected: every repository test passes; only live checks remain incomplete.

---

### Task 4: Capture Recovery State and Apply the Package Transactions

**Files:**
- Runtime only: `~/.local/state/simple-custom-arch/backups/<timestamp>/`
- Runtime only: `/etc/pacman.conf`

**Interfaces:**
- Consumes: desired manifests and the maintenance procedure from Tasks 1 and 3
- Produces: a complete official upgrade, approved packages, updated reviewed foreign packages, and a local recovery directory consumed by Tasks 5 through 7

- [ ] **Step 1: Run the repository preflight**

```bash
set -e
test -z "$(git status --porcelain)"
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/phase1-docs.sh in-progress
./tests/phase0-verify.sh
./scripts/verify --root "$PWD"
```

Expected: every repository check passes on a clean branch.

- [ ] **Step 2: Review Arch news and create the recovery directory**

Read the current official Arch Linux news and stop if a notice requires intervention outside this plan. In one persistent Bash session, create:

```bash
phase1_stamp="$(date -u +%Y%m%dT%H%M%SZ)"
phase1_state_dir="$HOME/.local/state/simple-custom-arch/backups/$phase1_stamp"
install -d -m 0700 "$phase1_state_dir"
ln -sfn "$phase1_state_dir" "$HOME/.local/state/simple-custom-arch/phase1-current"
```

Expected: the directory and pointer exist outside the repository.

- [ ] **Step 3: Capture package and service state locally**

Write sorted results for `pacman -Qqen`, `pacman -Qqem`, `pacman -Qdtq`, `systemctl --failed`, and `systemctl --user --failed` into the recovery directory. Record free space, current kernel release, and package-cache size. These local files may contain runtime identifiers and must never be staged.

- [ ] **Step 4: Back up privileged configuration**

Copy `/etc/pacman.conf`, `/etc/mkinitcpio.conf`, `/etc/mkinitcpio.d/`, and the active Limine configuration into matching recovery paths. Record original ownership and modes locally.

Discover Limine candidates below `/boot` and `/etc` with privileged read-only `find`. Require exactly one active configuration before continuing and record its path only in the recovery directory.

- [ ] **Step 5: Stage and validate the multilib edit**

Copy `/etc/pacman.conf` to `/tmp/simple-custom-arch-pacman.conf`. Use `apply_patch` on that temporary file to change exactly:

```text
#[multilib]
#Include = /etc/pacman.d/mirrorlist
```

to:

```text
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Validate with `pacman-conf --config /tmp/simple-custom-arch-pacman.conf --repo-list`, require exactly one `multilib`, inspect the diff, and install the file to `/etc/pacman.conf` with mode `0644`.

- [ ] **Step 6: Perform one complete official transaction**

Run in a TTY and preserve output in the recovery directory:

```bash
sudo pacman -Syu --needed \
  brightnessctl jre21-openjdk lib32-mesa lib32-vulkan-intel \
  libva-utils linux-lts mesa-utils pacman-contrib playerctl prismlauncher \
  steam vulkan-tools
```

Expected: refresh, complete upgrade, and installs finish in one transaction. If it fails after synchronization, resolve the error and complete `pacman -Su` before any unrelated package action; do not restore the old Pacman configuration mid-upgrade.

- [ ] **Step 7: Update reviewed foreign packages**

After the official transaction succeeds, run `yay -Sua` and preserve its log. Reject replacements, unreviewed new packages, or removal of a desired package.

- [ ] **Step 8: Verify the transaction boundary**

```bash
pacman -Q linux linux-lts pacman-contrib brightnessctl playerctl \
  steam lib32-mesa lib32-vulkan-intel prismlauncher jre21-openjdk \
  libva-utils mesa-utils vulkan-tools
pacman-conf --repo-list | rg -x 'multilib'
```

Also assert none of `lib32-amdvlk`, `lib32-vulkan-radeon`, `lib32-nvidia-utils`, or `lib32-vulkan-nouveau` is installed.

Expected: every approved package and `multilib` are present with no wrong-vendor Vulkan provider.

---

### Task 5: Add and Validate the LTS Limine Entry

**Files:**
- Runtime only: the active Limine configuration recorded in Task 4
- Runtime only: `/boot/vmlinuz-linux-lts`
- Runtime only: `/boot/initramfs-linux-lts.img`

**Interfaces:**
- Consumes: recovery directory and installed `linux-lts` package from Task 4
- Produces: a backed-up visible LTS entry that preserves the regular kernel as default and is consumed by Task 7

- [ ] **Step 1: Verify generated kernel artifacts**

With privileged read-only checks, require nonempty regular and LTS kernel images, both initramfs images, and Intel microcode. Inspect the LTS mkinitcpio preset. Run `sudo mkinitcpio -P` only if a package hook did not generate a required image, preserve output, and recheck all artifacts.

- [ ] **Step 2: Stage the Limine configuration**

Copy the active configuration to a user-owned temporary file without printing boot arguments. If a package hook already created exactly one correct LTS entry, leave it unchanged and continue to Step 3. Otherwise, duplicate the complete regular Arch Linux entry and change only:

- Entry label to `Arch Linux LTS`.
- Regular kernel filename to `vmlinuz-linux-lts`.
- Regular initramfs filename to `initramfs-linux-lts.img`.

Keep root arguments, Intel microcode, and every other option byte-for-byte equal. Keep the regular entry first so it remains default.

- [ ] **Step 3: Test the staged transformation**

Normalize only the label and two kernel filenames in copies of the regular and LTS stanzas and compare them with `diff -u`. Require no other difference, exactly one regular entry, one LTS entry, and the same Intel microcode reference in each.

Expected: the comparison passes. Changed root identifiers, missing microcode, or an LTS-first order stops installation.

- [ ] **Step 4: Install and re-read the Limine configuration**

Install the staged file using the original mode and owner. Copy the installed file back to a second temporary path through a privileged read, repeat the normalized comparison, then delete both temporary copies.

Expected: the installed configuration equals the reviewed file without exposing identifiers in Git or output.

- [ ] **Step 5: Preserve the reboot gate**

Do not reboot. Record successful boot-file validation in the local Phase 1 log and keep the recovery directory through Task 7.

---

### Task 6: Validate Hardware, Apply Reviewed Cleanup, and Refresh the Baseline

**Files:**
- Modify: `docs/baseline/README.md`
- Modify: `docs/baseline/hardware.md`
- Modify: `docs/baseline/services.md`
- Modify: `docs/baseline/official-explicit.txt`
- Modify: `docs/baseline/foreign-explicit.txt`

**Interfaces:**
- Consumes: updated packages, boot artifacts, desired manifests, and the exact five-name cleanup set
- Produces: a clean live verifier result and sanitized post-transaction baseline used by Task 7

- [ ] **Step 1: Validate the updated system before cleanup**

Run and preserve local results for:

```text
nmcli general status
pactl info
wpctl status
bluetoothctl show
vainfo
vulkaninfo --summary
eglinfo -B
java -version
pacman -Q steam prismlauncher
systemctl --failed --no-legend --plain
systemctl --user --failed --no-legend --plain
```

Expected: full network connectivity; PipeWire audio input and output; Bluetooth controller; Intel `iHD` VA-API; Intel Vulkan and OpenGL; Java 21; both launchers; no failed user unit; and only documented TPM system failures.

After these read-only checks pass, open Steam and Prism Launcher one at a time, confirm each reaches its initial window, and close it. Account sign-in and game downloads are not required. Record only pass or fail in the local log; launcher-created personal state remains unversioned.

- [ ] **Step 2: Test the complete removal preview**

Capture and sort:

```bash
pacman -Rs --print-format '%n' go vim wofi yay-debug
```

Compare byte-for-byte with:

```text
go
vim
vim-runtime
wofi
yay-debug
```

Expected: exact match. Any additional or missing name stops cleanup and requires a revised plan.

- [ ] **Step 3: Apply the approved cleanup**

Run `sudo pacman -Rs go vim wofi yay-debug` and preserve its log. Do not add `--nodeps`, `--cascade`, `--overwrite`, or `--nosave`.

- [ ] **Step 4: Verify absence and orphan state**

Assert all five removal names are absent and `pacman -Qdtq` returns no package. Confirm Neovim and Nano remain. If Go later returns as a Yay build dependency, report it for a future reviewed cleanup rather than silently removing it.

- [ ] **Step 5: Run live verification and clean the cache**

```bash
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/phase1-docs.sh in-progress
./tests/phase0-verify.sh
./scripts/verify
```

Expected: all tests and live checks pass. Only then run `sudo paccache -rk2`, record its result locally, and run `./scripts/verify` again.

- [ ] **Step 6: Refresh only sanitized baseline facts**

Generate sorted official and foreign explicit snapshots into `/tmp`, compare them with desired manifests, then install them into `docs/baseline/`. Update baseline README, hardware, and services with:

- Capture date and Phase 1 reason.
- Regular and LTS kernels installed; LTS boot test pending.
- `multilib`, maintenance, media controls, Steam, Prism Launcher, and Java available.
- No unexpected orphan.
- Normalized TPM NvPCR exception without instance IDs or raw logs.

Run the sensitive-data scan before staging.

- [ ] **Step 7: Verify and commit the post-transaction baseline**

```bash
./scripts/verify
git diff --check
git status --short
git add docs/baseline
git commit -m "docs: record phase 1 system baseline"
```

Expected: live verification passes and only sanitized baseline files enter the commit.

---

### Task 7: Complete the Manual LTS Boot Checkpoint and Phase Status

**Files:**
- Modify: `docs/baseline/hardware.md`
- Modify: `README.md`
- Modify: `ROADMAP.md`
- Modify: `AGENTS.md`

**Interfaces:**
- Consumes: validated LTS entry, clean live verifier, and post-transaction baseline
- Produces: recorded LTS recovery evidence and Phase 1 complete with Phase 2 planned but not started

- [ ] **Step 1: Present the concrete reboot checkpoint**

Show that every pre-reboot check passed, identify the visible `Arch Linux LTS` menu entry, and request a manual reboot. Never invoke reboot automatically.

- [ ] **Step 2: Verify the LTS session after the user returns**

Require `uname -r` to identify the LTS kernel. Re-run live verification plus direct NetworkManager, PipeWire, Bluetooth, display-resolution, keyboard, and storage checks. Confirm the regular kernel remains first/default in Limine.

Expected: graphical session and essential hardware work under LTS, and regular kernel remains default for the next normal boot.

- [ ] **Step 3: Record the successful checkpoint**

Update `docs/baseline/hardware.md` with the actual test date and the successful LTS graphical boot. Record no boot arguments, identifiers, user names, or raw output.

- [ ] **Step 4: Mark Phase 1 complete**

Update README, ROADMAP, and AGENTS consistently: Phase 1 complete; Phase 2 planned; no Hyprland configuration started; next step is Phase 2 design review.

- [ ] **Step 5: Run final acceptance**

```bash
set -e
./tests/phase1-manifests.sh
./tests/phase1-verify.sh
./tests/phase1-docs.sh complete
./tests/phase0-verify.sh
./scripts/verify
git diff --check
git status --short
```

Expected: every repository, fixture, and live check passes; only the four Task 7 documentation files are modified.

- [ ] **Step 6: Commit the completed phase**

```bash
git add AGENTS.md README.md ROADMAP.md docs/baseline/hardware.md
git commit -m "docs: complete phase 1 base system"
```

- [ ] **Step 7: Review the local result without uploading**

Run the complete verifier once more, review all Phase 1 commits from the implementation branch base, and report package changes, backup location, TPM exception, LTS evidence, and deferred issues. Keep everything local until explicit upload authorization.
