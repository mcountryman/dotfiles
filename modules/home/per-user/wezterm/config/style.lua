local wezterm = require "wezterm"

return function(config)
  local color_scheme = "Ayu Dark (Gogh)"
  local colors = wezterm.color.get_builtin_schemes()[color_scheme]

  config.dpi = 384.0

  -- Font
  config.font = wezterm.font("IosevkaTerm Nerd Font")
  config.font_size = 14.0
  config.window_frame = config.window_frame or {}
  config.window_frame.font = config.font
  config.window_frame.font_size = config.font_size

  -- Colors
  config.window_background_opacity = 0.8
  config.color_scheme = color_scheme
  config.colors = {
    tab_bar = {
      background = colors.background,

      active_tab = { bg_color = colors.ansi[5], fg_color = colors.background },
    },
  }

  -- Tabbar
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true
  config.show_new_tab_button_in_tab_bar = false

  -- Misc
  config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = ""

    title = tab.active_pane.foreground_process_name or tab.title
    title = string.gsub(title, "(.*[/\\])(.*)", "%2")
    title = string.gsub(title, "%s*(.*)%s*", "%1")
    title = string.len(title) > 0 and title or "..."

    return " " .. title .. " "
  end)
  
  wezterm.on("update-status", function(window, pane)

    local mode = string.upper(window:active_key_table() or "normal")
    local workspace = window:active_workspace() or "default"

    window:set_left_status(wezterm.format {
      { Foreground = { Color = mode == "NORMAL" and colors.foreground or "black" } },
      { Background = { Color = mode == "NORMAL" and colors.background or colors.ansi[4] } },
      { Text = " " .. mode .. " " },
    })

    window:set_right_status(wezterm.format {
      { Background = { Color = "#000" } },
      { Text = " " .. workspace .. " " },
    })
  end)

  return config
end
