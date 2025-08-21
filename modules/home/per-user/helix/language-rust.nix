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

    debugger = {
      name = "lldb-vscode";
      transport = "stdio";
      command = "${pkgs.lldb}/bin/rust-lldb";
    };
  };
}
