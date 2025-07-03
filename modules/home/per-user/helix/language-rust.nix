{ pkgs, ... }:
{
  home.packages = [ pkgs.lldb ];

  programs.helix.languages = {
    language = [
      {
        name = "rust";
        auto-format = true;
        language-servers = [
          "rust-analyzer"
          "spellcheck"
        ];
        indent = {
          tab-width = 2;
          unit = " ";
        };
      }
    ];

    debugger = {
      name = "lldb-vscode";
      transport = "stdio";
      command = "rust-lldb";
    };
  };
}
