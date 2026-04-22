{ pkgs, ... }:
{
  programs.helix.languages = {
    language = [
      {
        name = "rust";
        indent = {
          tab-width = 2;
          unit = " ";
        };

        auto-format = true;
        language-servers = [
          "spellcheck"
          "rust-analyzer"
        ];
      }
    ];

    home.packages = with pkgs; [
      clippy
    ];

    language-server.rust-analyzer = {
      command = "rust-analyzer";

      config = {
        check.command = "clippy";

        inlayHints = {
          bindingModeHints.enable = false;
          closingBraceHints.minLines = 10;
          closureReturnTypeHints.enable = "with_block";
          discriminantHints.enable = "fieldless";
          lifetimeElisionHints.enable = "skip_trivial";
          typeHints.hideClosureInitialization = false;
        };
      };
    };

    debugger = {
      name = "lldb-vscode";
      transport = "stdio";
      command = "${pkgs.lldb}/bin/rust-lldb";
    };
  };
}
