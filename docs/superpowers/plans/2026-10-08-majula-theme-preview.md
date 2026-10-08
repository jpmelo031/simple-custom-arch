# Majula Theme Preview Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create an English theme reference and a self-contained 1366x768 SVG that shows the approved Majula palette in terminal, VS Code, Waybar, Rofi, and Dunst examples.

**Architecture:** `docs/theme.md` is the human-readable source for semantic meaning, contrast, and component usage. It embeds `docs/assets/theme-preview.svg`, a dependency-free vector mockup whose inline styles use the exact approved color values. The SVG is rendered locally with librsvg and inspected at the notebook's native resolution.

**Tech Stack:** Markdown, SVG 1.1-compatible XML, CSS inside SVG, `xmllint`, `rsvg-convert`, Ripgrep

**Spec:** `docs/superpowers/specs/2026-10-08-simple-custom-arch-design.md`

## Global Constraints

- All versioned content is written in English.
- The preview artboard is exactly 1366x768.
- The approved palette values are used without modification.
- The preview uses no external fonts, images, scripts, stylesheets, or network resources.
- No copyrighted Dark Souls II assets or logos are included; Majula is an atmospheric reference only.
- Gold and ember are accents, not large background colors.
- The layout remains legible at the notebook's native resolution.
- Warnings and errors are distinguishable through labels and symbols in addition to color.
- This plan creates documentation assets only and makes no system configuration changes.

## Review Focus

- **Palette drift:** every documented token and hexadecimal value must match the approved spec; Task 1 checks all eleven values in both files.
- **Low-resolution clipping:** the complete mockup must fit a 1366x768 render without clipped labels or panels; Task 1 renders and visually inspects the PNG.
- **External dependency leakage:** the SVG must work offline and must not reference remote resources; Task 1 scans all SVG references.
- **Unreadable state colors:** primary, muted, accent, and danger text must preserve the documented contrast and use text labels; Task 1 checks the contrast table and inspects each state.
- **Unclear component mapping:** terminal, VS Code, Waybar, Rofi, and Dunst must each visibly demonstrate the semantic tokens assigned to them; Task 1 checks the required labels and visual panels.

---

### Task 1: Create and Validate the Majula Theme Reference

**Files:**
- Create: `docs/theme.md`
- Create: `docs/assets/theme-preview.svg`

**Interfaces:**
- Consumes: the semantic palette, visual constraints, and preview requirements from `docs/superpowers/specs/2026-10-08-simple-custom-arch-design.md`
- Produces: `docs/theme.md` as the theme contract and `docs/assets/theme-preview.svg` as the reviewable visual baseline for later application-specific themes

- [ ] **Step 1: Run the initial artifact check and confirm it fails**

Run:

```bash
test -f docs/theme.md && test -f docs/assets/theme-preview.svg
```

Expected: FAIL because neither approved artifact exists yet.

- [ ] **Step 2: Create `docs/theme.md`**

Write these sections:

1. `# Majula Theme`
2. `## Direction` — dark stone, deep sea tones, aged ivory, restrained sunset light, and no copied game assets.
3. `## Palette` — a table containing the exact eleven tokens, values, primary uses, and contrast ratios where the token is used for text.
4. `## Component Mapping` — explicit usage for Hyprland, Waybar, Rofi, Kitty, Dunst, VS Code, and the future updater.
5. `## Preview` — embed `assets/theme-preview.svg` with descriptive alt text.
6. `## Rules` — semantic tokens are authoritative; large gold or ember surfaces, arbitrary application colors, and external assets are prohibited.

Use these verified contrast ratios:

| Foreground | On `background` | On `surface` |
|---|---:|---:|
| `text` | 13.08:1 | 11.86:1 |
| `muted` | 6.88:1 | 6.23:1 |
| `accent` | 8.21:1 | 7.44:1 |
| `ember` | 6.25:1 | 5.66:1 |
| `danger` | 4.68:1 | Not used as body text |

- [ ] **Step 3: Create `docs/assets/theme-preview.svg`**

Create a valid, accessible SVG with:

- Root dimensions `width="1366"`, `height="768"`, and `viewBox="0 0 1366 768"`.
- `role="img"`, a `<title>` of `Majula theme preview`, and a descriptive `<desc>` connected through `aria-labelledby`.
- Inline CSS classes for all eleven palette tokens using their exact hexadecimal values.
- Generic `sans-serif` and `monospace` font stacks only.
- A full-canvas `background` base.
- A 28-pixel Waybar example with workspaces, time, network, audio, and battery labels.
- A VS Code example with activity rail, sidebar, editor, tabs, syntax colors, line numbers, and an integrated terminal.
- A Kitty update example showing package progress, an informational line, a successful check, and a labeled failure example.
- A centered Rofi update dialog with exactly `Close`, `Update & Restart`, and `Update & Shut Down`.
- A Dunst notification showing an available-update message.
- A palette panel containing all eleven swatches with token names and hexadecimal values.
- Visible section labels for `Desktop`, `VS Code`, `Kitty`, `Rofi`, `Dunst`, and `Palette`.

Keep all panel borders and text inside the artboard. Use labels or icons such as `!`, `i`, and check marks so status meaning does not depend only on color.

- [ ] **Step 4: Validate structure, palette consistency, and offline behavior**

Run:

```bash
xmllint --noout docs/assets/theme-preview.svg
rg -q 'viewBox="0 0 1366 768"' docs/assets/theme-preview.svg
rg -q 'assets/theme-preview.svg' docs/theme.md
for value in 0E1114 171C20 20272C 465056 DDD6C6 A39B8C D1A35C E0783E 7899A2 87996D C06452; do
  rg -qi "#$value" docs/theme.md
  rg -qi "#$value" docs/assets/theme-preview.svg
done
for label in 'VS Code' Kitty Rofi Dunst Palette; do
  rg -q "$label" docs/assets/theme-preview.svg
done
if rg -n '(href="https?:|href="data:|@import|<script)' docs/assets/theme-preview.svg; then
  exit 1
fi
```

Expected: every command exits successfully and the external-resource scan produces no output.

- [ ] **Step 5: Render and visually inspect at native resolution**

Run:

```bash
rsvg-convert -w 1366 -h 768 \
  -o /tmp/simple-custom-arch-majula-preview.png \
  docs/assets/theme-preview.svg
file /tmp/simple-custom-arch-majula-preview.png
```

Expected: `file` reports a 1366 x 768 PNG.

Inspect `/tmp/simple-custom-arch-majula-preview.png` and confirm:

- No panel, label, or swatch is clipped.
- Primary and muted text remain readable.
- Gold and ember occupy only small accent areas.
- Terminal, editor, desktop, updater, and notification examples are visually distinct.
- `danger` includes a failure label or symbol.
- The composition remains usable rather than decorative at the target resolution.

- [ ] **Step 6: Verify the documentation diff**

Run:

```bash
git add --intent-to-add docs/theme.md docs/assets/theme-preview.svg
git diff --check
git status --short
```

Expected: no whitespace errors; only `docs/theme.md` and `docs/assets/theme-preview.svg` are new or modified. The implementation plan is committed before execution so it is available inside the isolated worktree.

- [ ] **Step 7: Commit the theme reference**

```bash
git add docs/theme.md docs/assets/theme-preview.svg
git commit -m "docs: add Majula theme preview"
```
