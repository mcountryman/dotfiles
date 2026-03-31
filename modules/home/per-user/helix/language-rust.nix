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

    language-server.rust-analyzer = {
      command = "rust-analyzer";

      config = {
        check.command = "${pkgs.clippy}/bin/clippy";

        inlayHints.bindingModeHints.enable = false;
        inlayHints.closingBraceHints.minLines = 10;
        inlayHints.closureReturnTypeHints.enable = "with_block";
        inlayHints.discriminantHints.enable = "fieldless";
        inlayHints.lifetimeElisionHints.enable = "skip_trivial";
        inlayHints.typeHints.hideClosureInitialization = false;
      };
    };

    debugger = {
      name = "lldb-vscode";
      transport = "stdio";
      command = "${pkgs.lldb}/bin/rust-lldb";
    };
  };
}
