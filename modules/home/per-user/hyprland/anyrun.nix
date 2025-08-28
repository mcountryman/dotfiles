{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.anyrun = {
    enable = true;
    config = {
      x.fraction = 0.5;
      y.fraction = 0.3;
      width.fraction = 0.3;
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = null;

      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libkidex.so"
        "${pkgs.anyrun}/lib/librink.so"
        "${pkgs.anyrun}/lib/libstdin.so"
        "${pkgs.anyrun}/lib/libtranslate.so"
        "${pkgs.anyrun}/lib/libdictionary.so"
        "${pkgs.anyrun}/lib/librandr.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];

    };

    extraConfigFiles."websearch.ron".text = ''
      Config(
        engines: [DuckDuckGo]
      )
    '';

    extraCss = lib.mkAfter ''
      /* GTK Vars */
      @define-color bg-color #${config.lib.stylix.colors.base00};
      @define-color fg-color #${config.lib.stylix.colors.base05};
      @define-color primary-color #${config.lib.stylix.colors.base0D};
      @define-color secondary-color #${config.lib.stylix.colors.base03};
      @define-color border-color @primary-color;
      @define-color selected-bg-color @primary-color;
      @define-color selected-fg-color @bg-color;

      * {
        all: unset;
        font-family: JetBrainsMono Nerd Font;
      }

      #window {
        background: transparent;
      }

      box#main {
        /* border-radius: 16px; */
        background-color: alpha(@bg-color, 0.9);
        border: 0.5px solid alpha(@fg-color, 0.25);
      }

      entry#entry {
        font-size: 1.25rem;
        background: transparent;
        box-shadow: none;
        border: none;
        /* border-radius: 16px; */
        padding: 16px 24px;
        min-height: 40px;
        caret-color: @primary-color;
      }

      list#main {
        background-color: transparent;
      }

      #plugin {
        background-color: transparent;
        padding-bottom: 4px;
      }

      #match {
        font-size: 1.1rem;
        padding: 2px 4px;
      }

      #match:selected,
      #match:hover {
        background-color: @selected-bg-color;
        color: @selected-fg-color;
      }

      #match:selected label#info,
      #match:hover label#info {
        color: @selected-fg-color;
      }

      #match:selected label#match-desc,
      #match:hover label#match-desc {
        color: alpha(@selected-fg-color, 0.9);
      }

      #match label#info {
        color: transparent;
        color: @fg-color;
      }

      label#match-desc {
        font-size: 1rem;
        color: @fg-color;
      }

      label#plugin {
        font-size: 16px;
      }
    '';
  };
}
