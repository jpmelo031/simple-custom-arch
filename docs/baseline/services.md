# Service Baseline

Captured on 2026-10-08 through read-only systemd queries.

## Failed System Units

Failed system units:

- `systemd-pcrlogin@*.service` — failed, 2 instances
- `systemd-pcrproduct.service` — failed
- `systemd-tpm2-setup-early.service` — failed

The instance identifiers from the login-measurement units are intentionally omitted. These TPM-related failures are observations for Phase 1 investigation; Phase 0 does not change or restart them.

## Failed User Units

No failed user units.

## Essential Session State

| Component | Observed state |
|---|---|
| SDDM service | Enabled |
| NetworkManager service | Active |
| Graphical session target | Active |
| Hyprland session | Running on Wayland |

Only unit names and short states are recorded. Journal output and session-specific identifiers are intentionally omitted.
