-- Additive Majula configuration loaded by the generated Hyprland config.

local mainMod = "SUPER"

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 4,
        border_size = 2,
        col = {
            active_border = "rgba(E0783Eff)",
            inactive_border = "rgba(465056cc)",
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 6,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 2,
            color = "rgba(0E1114cc)",
        },
        blur = {
            enabled = true,
            size = 4,
            passes = 1,
            vibrancy = 0.1,
        },
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

-- Keep the existing application binds and add only missing entry points.
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("simple-custom-arch-clipboard-menu"))
hl.bind("PRINT", hl.dsp.exec_cmd("simple-custom-arch-screenshot full"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("simple-custom-arch-screenshot area"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("simple-custom-arch-session-menu"))

-- Physical XKB keypad codes keep these bindings independent of Num Lock.
local workspaceKeycodes = {
    [1] = 87,
    [2] = 88,
    [3] = 89,
    [4] = 83,
    [5] = 84,
    [6] = 85,
    [7] = 79,
    [8] = 80,
    [9] = 81,
}

for workspace = 1, 9 do
    local code = workspaceKeycodes[workspace]
    hl.bind(mainMod .. " + code:" .. code, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mainMod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = workspace }))
end

hl.bind("ALT + code:80", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("ALT + code:88", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("ALT + code:85", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("ALT + code:83", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("ALT + code:84", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("ALT + code:90", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("ALT + code:81", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("ALT + code:79", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
