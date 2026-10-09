# Service Baseline

Captured on 2026-10-09 after additive desktop deployment through read-only systemd and process queries.

## Failed System Units

Failed system units:

- `systemd-pcrlogin@*.service` — failed, 2 instances
- `systemd-pcrproduct.service` — failed
- `systemd-tpm2-setup-early.service` — failed

The instance identifiers from the login-measurement units are intentionally omitted. These TPM-related failures are a documented pre-existing exception. The additive desktop work did not change or restart them.

## Failed User Units

No failed user units.

## Essential Session State

| Component | Observed state |
|---|---|
| SDDM service | Enabled |
| NetworkManager service | Active |
| Graphical session target | Active |
| Hyprland session | Running on Wayland |
| Simple Custom Arch session target | Active and enabled |
| Waybar service | Active; one process |
| Hyprpaper service | Active; one process |
| Hypridle service | Active; one process |
| Clipboard-history service | Active; one `wl-paste` process |
| Dunst service | Active; one process |
| KDE PolicyKit agent | Running; one process |

Hyprland reported no configuration errors, and Hyprpaper reported the project wallpaper active on the built-in display. Only normalized states are recorded; journal output, process identifiers, paths, and session-specific identifiers are intentionally omitted.
