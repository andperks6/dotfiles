local wezterm = require('wezterm')
local config = wezterm.config_builder()

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")


-- config.color_scheme = 'Ayu Mirage'
-- config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = true
bar.apply_to_config(config, {
    modules = {
        tabs = {
            active_tab_fg = 4,
            inactive_tab_fg = 6,
        },
        hostname = { enabled = false },
        username = { enabled = false },
    },
})

config.color_scheme = 'ayu'

-- config.font = wezterm.font('Monaspace Neon')
config.font_size = 13.0



-- Show active pane title / working directory in window title
wezterm.on('format-window-title', function(tab)
    return tab.active_pane.title
end)


config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.adjust_window_size_when_changing_font_size = false

-- Workaround: restore window size after wake from sleep (macOS + RESIZE decorations)
-- See https://github.com/wezterm/wezterm/issues/6309
local saved_dims = {}
wezterm.on('window-resized', function(window)
    local overrides = window:get_config_overrides() or {}
    local dims = window:get_dimensions()
    local id = tostring(window:window_id())

    if saved_dims[id] and dims.pixel_width > saved_dims[id].pixel_width * 1.4 then
        -- Window grew suspiciously large (wake from sleep) — restore previous size
        window:set_inner_size(saved_dims[id].pixel_width, saved_dims[id].pixel_height)
    else
        saved_dims[id] = { pixel_width = dims.pixel_width, pixel_height = dims.pixel_height }
    end
end)

return config
