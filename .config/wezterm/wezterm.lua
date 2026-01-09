local wezterm = require('wezterm')
local config = wezterm.config_builder()

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")


-- config.color_scheme = 'Ayu Mirage'
-- config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = true
bar.apply_to_config(config)

config.color_scheme = 'ayu'

-- config.font = wezterm.font('Monaspace Neon')
config.font_size = 13.0



wezterm.on('format-window-title', function()
    return 'WezTerm'
end)

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.adjust_window_size_when_changing_font_size = false

return config
