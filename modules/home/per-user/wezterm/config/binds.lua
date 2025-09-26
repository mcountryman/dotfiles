local wezterm = require "wezterm"
local action = wezterm.action

return function(config)
  config.leader = { key = "b", mods = "CTRL" }
  config.keys = {
      -- Tabs
      { key = "c", mods = "LEADER", action = action.SpawnTab "CurrentPaneDomain" },
      { key = "p", mods = "LEADER", action = action.ActivateTabRelative(-1) },
      { key = "n", mods = "LEADER", action = action.ActivateTabRelative(1) },

      -- Panes
      { key = "h", mods = "LEADER", action = action.ActivatePaneDirection "Left" },
      { key = "j", mods = "LEADER", action = action.ActivatePaneDirection "Down" },
      { key = "k", mods = "LEADER", action = action.ActivatePaneDirection "Up" },
      { key = "l", mods = "LEADER", action = action.ActivatePaneDirection "Right" },
      { key = "x", mods = "LEADER", action = action.CloseCurrentPane { confirm = false } },
      { key = "-", mods = "LEADER", action = action.SplitVertical },
      { key = "\\", mods = "LEADER", action = action.SplitHorizontal },

      -- Modes
      { key = "r", mods = "LEADER", action = action.ActivateKeyTable { name = "resize", one_shot = false } },
      { key = ";", mods = "LEADER", action = action.ActivateCommandPalette },
  }

  config.key_tables = {
    resize = {   
      { key = "Escape", action = "PopKeyTable" },

      { key = "h", action = action.AdjustPaneSize { "Left", 5 } },
      { key = "j", action = action.AdjustPaneSize { "Down", 5 } },
      { key = "k", action = action.AdjustPaneSize { "Up", 5 } },
      { key = "l", action = action.AdjustPaneSize { "Right", 5 } },
    };
  }

  return config
end
