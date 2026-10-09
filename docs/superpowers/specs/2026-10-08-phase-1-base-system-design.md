# Phase 1 Base System and Packages Design

**Date:** 2026-10-08  
**Status:** Approved design, pending implementation plan

## Purpose

Phase 1 turns the observed notebook installation into a documented, minimal, and recoverable package foundation. It defines the desired explicit package set, validates the hardware stack, establishes a safe weekly maintenance procedure, adds a fallback kernel, and removes reviewed redundancy without beginning Hyprland configuration.

The implementation continues to target the Samsung 300E5M/300E5L notebook. Stability remains the first priority, followed by functionality, performance, visual consistency, and portability.

## Scope

Phase 1 will:

- Define desired official and foreign package manifests.
- Document the purpose and source of every desired explicit package.
- Validate firmware, Intel graphics, audio, network, Bluetooth, fonts, firewall, storage health tooling, and the graphical-session prerequisites.
- Add a Linux LTS fallback kernel and a verified Limine entry.
- Add the maintenance and media-control tools needed by later phases.
- Enable the official `multilib` repository and add the supported Steam package.
- Add Prism Launcher and one Java runtime for current Minecraft releases.
- Establish a weekly complete-upgrade procedure with logs, backups, cache retention, and `.pacnew` review.
- Remove only the packages explicitly approved in this design after a dependency preview.
- Record known TPM NvPCR failures without disabling security features that may become useful later.
- Update the sanitized system baseline after all changes pass verification.

Phase 1 will not:

- Configure Hyprland behavior or keybindings.
- Apply the Majula theme.
- Add the graphical update prompt or automatic update service.
- Add battery-management software.
- Tune CPU governors without measurements that demonstrate a problem.
- Add general bootstrap, deployment, or restore automation.
- Push changes to a remote repository without explicit authorization.

## Observed Starting Point

The read-only audit on 2026-10-08 found:

- The root filesystem is `ext4`, with approximately 197 GiB free at capture time.
- The Pacman cache uses approximately 1.6 GiB.
- The current kernel is the regular Arch `linux` package; no fallback kernel is installed.
- The boot loader is Limine, and `mkinitcpio` already includes microcode and KMS hooks.
- `multilib` is present but commented out in `/etc/pacman.conf`.
- Audio uses PipeWire 1.6.9 with WirePlumber and working analog input and output.
- NetworkManager reports full connectivity. Wi-Fi hardware and radio are enabled.
- Bluetooth is used occasionally, and its system service is enabled and active.
- Intel HD Graphics 620 uses the `i915` kernel driver. Mesa, Intel Vulkan, the modern Intel media driver, and the legacy VA-API driver are installed.
- The notebook has no battery and operates from mains power only.
- `go` is the only reported orphan and uses approximately 226 MiB.
- The approved cleanup transaction is expected to recover approximately 294 MiB, including Vim's dependency-only runtime.
- `checkupdates`, `paccache`, `pacdiff`, `brightnessctl`, and `playerctl` are not installed.
- Four TPM-related systemd units fail because the firmware provides only partial TPM2 support and NvPCR initialization is unavailable.
- The notebook does not use Windows, BitLocker, Secure Boot, or disk encryption bound to the TPM.
- The physical `F2`, `F5`, top-row `5`, and top-row `6` keys do not work.

Measurements in this section are an observation, not a permanent promise. The implementation must capture a fresh pre-change baseline before applying system changes.

## Package Policy

### Desired-State Model

`packages/official.txt` lists intentionally selected packages from configured official Arch repositories. `packages/aur.txt` lists reviewed foreign packages. Both files remain sorted, contain one package name per line, and exclude dependency-only packages unless the project intentionally selects a specific provider or hardware implementation.

`packages/README.md` groups the desired packages by responsibility and documents why each group exists. A package is not retained merely because it is currently installed.

After installation and validation, package install reasons may be normalized with `pacman -D --asexplicit` or `pacman -D --asdeps`. Every change to an install reason must be derived from the reviewed manifests and a dependency graph; it must not remove files.

### Packages to Add

| Package | Source | Purpose |
|---|---|---|
| `linux-lts` | Official | Recovery kernel when the current kernel regresses |
| `pacman-contrib` | Official | `checkupdates`, `paccache`, `pacdiff`, and related maintenance tools |
| `brightnessctl` | Official | Backlight commands for Phase 2 keybindings |
| `playerctl` | Official | Browser and media-player MPRIS controls for Phase 2 keybindings |
| `steam` | Official `multilib` | Supported Steam client using its bundled runtime |
| `lib32-mesa` | Official `multilib` | 32-bit OpenGL support for the Intel graphics stack |
| `lib32-vulkan-intel` | Official `multilib` | Correct 32-bit Vulkan provider for Intel graphics and Proton |
| `prismlauncher` | Official | Minecraft instance and launcher management |
| `jre21-openjdk` | Official | System Java runtime for current Minecraft releases |
| `libva-utils` | Official | Direct VA-API validation through `vainfo` |
| `vulkan-tools` | Official | Direct Vulkan validation through `vulkaninfo` |
| `mesa-utils` | Official | Direct OpenGL and EGL validation through `eglinfo` |

Older Java runtimes are added only when a specific Minecraft instance requires them. Steam dependencies are resolved by Pacman; optional troubleshooting libraries are not preinstalled.

### Packages to Keep Intentionally

- Keep `linux` as the default kernel and `linux-lts` as the fallback.
- Keep `intel-ucode`, `linux-firmware`, Mesa, `vulkan-intel`, `intel-media-driver`, `vpl-gpu-rt`, and the existing graphics stack.
- Keep `libva-intel-driver` during Phase 1. Its small cost is acceptable until the modern `iHD` path has been verified across browsers, Steam, and local media.
- Keep PipeWire, its ALSA and PulseAudio compatibility layers, WirePlumber, and `pipewire-jack`. The installed `ffmpeg` and `portaudio` packages require the JACK compatibility provider.
- Keep `bluez`, `bluez-utils`, and the active Bluetooth service because Bluetooth remains a real use case.
- Keep Rofi as the single launcher.
- Keep Neovim as the primary terminal editor and Nano as the small recovery editor.
- Keep the CJK font set so websites can display Chinese, Japanese, and Korean text correctly.
- Keep the current firewall, network, storage-health, desktop-portal, display-manager, and session prerequisites unless the implementation audit proves a specific package redundant.
- Keep `visual-studio-code-bin`, `yay`, and `zen-browser-bin` as reviewed foreign packages.

### Packages Approved for Removal

| Package | Reason |
|---|---|
| `go` | Current orphan; Go development will be introduced later as an intentional development dependency |
| `vim` | Redundant with Neovim and the retained Nano recovery editor |
| `vim-runtime` | Dependency used only by the approved `vim` removal target |
| `wofi` | Redundant with the project-selected Rofi launcher |
| `yay-debug` | Debug symbols are not used and have not been needed during two years of Yay use |

Removal must be a separate operation after the updated system passes its first validation. The implementation must show Pacman's complete removal transaction and stop if it includes any package outside the five approved package names or newly orphaned dependencies that have not been reviewed.

The source-built `yay` package may require Go again as a temporary build dependency during a future Yay upgrade. That operation may install Go when needed; the weekly maintenance procedure then reports it as an orphan for a separate reviewed cleanup instead of assuming it is a permanent development package.

## Gaming and Java Foundation

Steam uses the official Arch package and its default bundled runtime. Phase 1 enables the official `multilib` repository by uncommenting its existing section and mirrorlist include, then performs a complete upgrade. The Intel-specific 32-bit OpenGL and Vulkan providers are named explicitly so Pacman cannot select a driver for another GPU vendor.

Prism Launcher uses the official repository package. Java 21 is the initial system runtime for current Minecraft releases. Prism instance configuration, game accounts, mod loaders, and per-version Java selection remain personal runtime state and are never committed.

Phase 1 verifies that both launchers start and that Vulkan selects the Intel implementation. Game-specific tuning, Proton overrides, GameMode, and additional Java versions are added only in response to an observed need.

## Kernel and Boot Recovery

The regular Arch kernel remains the default boot choice. The LTS kernel is an always-visible recovery entry in Limine.

Before changing the boot configuration, the implementation must:

1. Inspect the root-owned Limine configuration and current boot files without copying identifiers into the repository or logs.
2. Create timestamped backups of the Limine and `mkinitcpio` configuration.
3. Record the current package list and kernel release.
4. Confirm that trusted Arch installation media is available or can be prepared.

The regular kernel preset produces `/boot/EFI/Linux/arch-linux.efi`. Phase 1 configures the LTS preset to produce `/boot/EFI/Linux/arch-linux-lts.efi` with the same mkinitcpio hooks and splash behavior. Limine keeps the regular EFI entry first and adds one `Arch Linux LTS` entry whose duplicated configuration changes only the visible label and UKI path. Root arguments remain byte-for-byte equal and local.

After installing `linux-lts`, verification must confirm both UKIs, the backed-up presets, and the normalized Limine entries. No script may restart or power off the notebook. Phase 1 is complete only after the user manually boots the LTS entry once and confirms a working graphical session, network, audio, and input, then returns to the regular kernel as the default.

## Weekly Maintenance Procedure

The normal maintenance interval is once per week, scheduled when there is time to investigate an unexpected issue.

The procedure is:

1. Read current Arch Linux news for manual-intervention notices.
2. Confirm network access, free space, backup location, and an available fallback kernel.
3. Capture package and failed-unit state in a dated log.
4. Use `checkupdates` for a safe preview without refreshing the live sync database.
5. Perform one complete official upgrade with `pacman -Syu`; never run `pacman -Sy` alone.
6. Update reviewed foreign packages separately with Yay after the official upgrade succeeds.
7. Review Pacman output and merge `.pacnew` files with `pacdiff` where required.
8. Verify packages, services, network, audio, graphics, and the current kernel.
9. Retain two cached versions with `paccache -rk2` only after all checks pass.
10. Preserve logs and keep the machine running when any step fails.

Phase 1 documents this as a manual procedure. The Rofi and Kitty update experience remains owned by Phase 5.

## Backup and Rollback Contract

Runtime logs and backups live under `~/.local/state/simple-custom-arch/` and are never committed. Each Phase 1 run creates a timestamped directory containing:

- Explicit official and foreign package snapshots.
- Orphan and failed-unit snapshots.
- `/etc/pacman.conf`.
- `/etc/mkinitcpio.conf` and applicable preset files.
- The active Limine configuration.
- A record of relevant file ownership and permissions.

Identifiers inside boot configuration remain local and must not appear in versioned documentation.

Configuration rollback restores only the affected files from the recorded backup, verifies ownership and permissions, regenerates initramfs only when required, and checks the boot entries before any reboot. Package rollback uses retained packages only when the Arch guidance for the specific failure supports it; arbitrary partial downgrades are not a general rollback strategy.

Because the root filesystem is `ext4`, Phase 1 does not claim filesystem snapshots. Recovery relies on file backups, retained packages, the LTS kernel, a TTY, and Arch installation media.

## TPM NvPCR Exception

The observed TPM provides partial TPM2 support. Systemd 262 creates its storage root key successfully but cannot initialize the NvPCR indexes used to record product and login measurements. This affects:

- `systemd-tpm2-setup-early.service`
- `systemd-pcrproduct.service`
- Two instances of `systemd-pcrlogin@.service`, recorded in versioned documentation as `systemd-pcrlogin@*.service`

The notebook does not use the NvPCR-dependent security flows. Phase 1 documents these exact failures as a known hardware compatibility exception and does not mask the units. Verification fails for any additional failed unit or any changed failure pattern. If a later project phase adopts TPM-bound encryption, Secure Boot, or UKI measurement policies, this exception must be investigated again before that feature is enabled.

## Performance Policy

The notebook runs only from mains power. Phase 1 adds no battery-profile daemon and does not optimize for battery life.

The current Intel P-state configuration already selects `balance_performance`. It remains unchanged because forcing the maximum performance preference would increase heat and noise without measured evidence of a responsiveness problem. Performance changes require a repeatable workload, temperature observation, and before-and-after measurements.

Package choices favor native official packages and avoid duplicate launchers, unused debug symbols, and unnecessary background services.

## Notebook Input Constraint

The physical `F2`, `F5`, top-row `5`, and top-row `6` keys are unavailable. Phase 1 installs `brightnessctl` and `playerctl`, but Phase 2 owns their bindings.

Phase 2 must not require these keys for core actions or direct workspace access. Volume, mute, brightness, play/pause, previous, and next actions need working primary or alternate bindings, including browser media through MPRIS where supported.

## Repository Changes

Phase 1 will modify or add:

- `packages/official.txt`
- `packages/aur.txt`
- `packages/README.md`
- `scripts/verify`
- A dedicated Phase 1 verifier test under `tests/`
- `docs/maintenance.md`
- Sanitized files under `docs/baseline/`
- Phase status in `README.md`, `ROADMAP.md`, and `AGENTS.md`

No package installer or graphical update script is introduced. System changes are executed from a reviewed implementation plan with exact commands, backups, logs, and stop conditions.

## Verification Interface

`scripts/verify` keeps its existing Phase 0 checks and gains Phase 1 checks.

- `./scripts/verify` validates the repository and the current notebook.
- `./scripts/verify --root PATH` validates an isolated repository fixture and never inspects the running system.
- The verifier remains read-only and reports every detected failure before exiting nonzero.
- Root-owned boot files are verified through explicit read-only commands in the implementation plan, not by running the general verifier as root.

Repository checks cover manifest syntax, ordering, uniqueness, role documentation, approved foreign packages, prohibited removal candidates, and recovery documentation.

Live checks cover desired package presence, approved package absence, unexpected orphans, required commands, active network and audio components, graphics providers, and failed units. Fixture tests replace commands with controlled data only at the system-query boundary; repository validation continues to exercise the real verifier.

## Staged Execution

Implementation proceeds in these gates:

1. **Repository preparation:** manifests, package roles, maintenance procedure, verifier behavior, and tests.
2. **Pre-change capture:** fresh audit and timestamped backups.
3. **Official transaction:** enable `multilib`, perform a complete upgrade, and add the approved official packages.
4. **Foreign transaction:** update only the reviewed foreign packages after official packages succeed.
5. **First validation:** verify packages, services, hardware functions, kernels, and boot files.
6. **Cleanup preview:** show the exact removal transaction for the four approved packages.
7. **Cleanup transaction:** remove only the approved packages and validate again.
8. **Boot checkpoint:** manually boot the LTS kernel once, verify essential functions, and return the regular kernel to the default entry.
9. **Completion:** update the sanitized baseline and phase status, run the complete verifier, and create local commits for user review.

A failed gate stops the sequence. Later gates never run after a failure, and no power action is automatic.

## Acceptance Criteria

Phase 1 is complete when:

- Every desired explicit package has a documented role and source.
- Official and foreign manifests are sorted, unique, and match the reviewed explicit package state.
- The regular and LTS kernels have valid `arch-linux.efi` and `arch-linux-lts.efi` UKIs with working Limine entries.
- The LTS kernel has completed one successful manual boot test.
- NetworkManager, Wi-Fi, PipeWire, WirePlumber, analog audio, Bluetooth, Intel OpenGL, Intel Vulkan, and Intel video acceleration work.
- Steam and Prism Launcher start with the intended Intel graphics providers.
- `checkupdates`, `paccache`, `pacdiff`, `brightnessctl`, `playerctl`, `vainfo`, and `vulkaninfo` are available.
- `go`, `vim`, `vim-runtime`, `wofi`, and `yay-debug` are absent, with no unexpected orphan introduced by their removal.
- Only the documented TPM NvPCR units remain failed; no other system or user service has an unexplained failure.
- The weekly complete-upgrade and recovery procedures are documented and reviewable.
- The sanitized post-change baseline contains no prohibited identifiers.
- The complete verifier and its Phase 0 and Phase 1 tests pass.
- No Phase 2 configuration has been implemented.

## References

- [ArchWiki: System maintenance](https://wiki.archlinux.org/title/System_maintenance)
- [Arch Linux package files: pacman-contrib](https://archlinux.org/packages/extra/x86_64/pacman-contrib/files/)
- [ArchWiki: Steam](https://wiki.archlinux.org/title/Steam)
- [ArchWiki: Official repositories and multilib](https://wiki.archlinux.org/title/Official_repositories#multilib)
- [ArchWiki: Intel graphics](https://wiki.archlinux.org/title/Intel_graphics)
- [ArchWiki: Vulkan](https://wiki.archlinux.org/title/Vulkan)
- [Arch Linux package: Prism Launcher](https://archlinux.org/packages/extra/x86_64/prismlauncher/)
- [ArchWiki: PipeWire](https://wiki.archlinux.org/title/PipeWire)
