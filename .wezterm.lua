-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'Pencil Dark (Gogh)'
config.font = wezterm.font 'FiraCode Nerd Font Mono'
config.font_size = 9

config.hide_tab_bar_if_only_one_tab = true

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }

-- and finally, return the configuration to wezterm
return config
