local wezterm = require "wezterm"

local act = wezterm.action
local config = {}

config = require "style" (config)
config = require "binds" (config)

return config
