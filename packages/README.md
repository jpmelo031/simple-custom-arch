# Package Manifests

The package manifests describe the intended explicitly installed system. They are separate from the observed package snapshots under `docs/baseline/`.

## Manifest Rules

- `official.txt` contains packages available from configured official repositories.
- `aur.txt` contains reviewed foreign packages. Foreign means absent from the active official repositories; it does not automatically mean the package came from the AUR.
- Readers ignore blank lines and lines beginning with `#`.
- Package entries use one name per line and remain sorted and unique.
- Pacman resolves transitive dependencies; the manifests record only the desired explicit packages.

## Core and Boot

| Packages | Responsibility |
| --- | --- |
| `base`, `base-devel`, `sudo` | Core Arch userspace, build tools, and privileged command delegation. |
| `linux`, `linux-firmware`, `intel-ucode` | Primary kernel, device firmware, and Intel CPU microcode. |
| `linux-lts` | Recovery kernel kept alongside the primary kernel. |
| `mkinitcpio`, `limine`, `efibootmgr` | Initramfs generation and UEFI boot management. |
| `zram-generator` | Compressed swap setup for the notebook's limited resources. |

## Hardware and Intel Graphics

| Packages | Responsibility |
| --- | --- |
| `intel-media-driver`, `libva-intel-driver`, `libva-utils` | Current Intel VA-API driver, retained compatibility driver, and diagnostics. |
| `libvpl`, `vpl-gpu-rt` | Intel oneVPL video processing runtime. |
| `vulkan-intel`, `vulkan-tools` | Native Intel Vulkan driver and diagnostics. |
| `lib32-mesa`, `lib32-vulkan-intel` | Intel 32-bit OpenGL and Vulkan providers required by Steam. |
| `brightnessctl` | Backlight control for future hardware key bindings. |
| `smartmontools` | Storage health diagnostics. |

Steam requires the official `multilib` repository. The selected 32-bit providers are explicitly limited to Intel hardware.

## Network, Bluetooth, Audio, and Security

| Packages | Responsibility |
| --- | --- |
| `networkmanager`, `network-manager-applet`, `wpa_supplicant` | Network control, graphical status integration, and Wi-Fi authentication. |
| `bluez`, `bluez-utils` | Bluetooth service and command-line tools. |
| `pipewire`, `pipewire-alsa`, `pipewire-pulse`, `pipewire-jack` | Unified audio service and ALSA, PulseAudio, and JACK compatibility. |
| `wireplumber`, `gst-plugin-pipewire`, `libpulse` | PipeWire policy, GStreamer integration, and PulseAudio client compatibility. |
| `ufw` | Host firewall management. |

## Hyprland Prerequisites

| Packages | Responsibility |
| --- | --- |
| `hyprland`, `uwsm` | Wayland compositor and session management. |
| `xdg-desktop-portal-hyprland`, `xdg-user-dirs`, `xdg-utils` | Desktop portals, standard user directories, and desktop integration helpers. |
| `polkit-kde-agent` | Graphical PolicyKit authentication agent. |
| `qt5-wayland`, `qt6-wayland` | Native Wayland support for Qt applications. |
| `sddm` | Graphical login manager. |
| `dunst`, `rofi`, `grim`, `slurp` | Notifications, application launcher, and screenshot selection tools. |

Phase 1 retains these prerequisites without adding Hyprland configuration or key bindings.

## Applications and Fonts

| Packages | Responsibility |
| --- | --- |
| `kitty`, `dolphin` | Terminal emulator and graphical file manager. |
| `nano`, `neovim` | Retained terminal text editors. |
| `noto-fonts`, `noto-fonts-cjk`, `noto-fonts-emoji` | General, CJK, and emoji coverage for applications and websites. |
| `ttf-dejavu`, `ttf-liberation` | Compatible fallback fonts for common documents and web content. |

## Maintenance and Diagnostics

| Packages | Responsibility |
| --- | --- |
| `pacman-contrib` | Safe update checks, `.pacnew` review, and package-cache retention tools. |
| `git`, `github-cli` | Source control and GitHub command-line access. |
| `wget` | Direct file retrieval for reviewed sources. |
| `htop` | Interactive process and resource inspection. |
| `playerctl` | Media-session controls for future key bindings. |

## Gaming and Java

| Packages | Responsibility |
| --- | --- |
| `steam` | Steam client from `multilib`. |
| `prismlauncher` | Reviewed Minecraft launcher from the official repositories. |
| `jre21-openjdk` | Java 21 runtime selected for current Minecraft versions. |

## Reviewed Foreign Packages

| Package | Responsibility |
| --- | --- |
| `visual-studio-code-bin` | Visual Studio Code binary distribution used as the graphical editor. |
| `yay` | Reviewed helper for updating foreign packages after official upgrades. |
| `zen-browser-bin` | Zen Browser binary distribution. |
