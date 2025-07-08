{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lldb
  ];

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
          "rust-analyzer"
          "spellcheck"
        ];
      }
    ];

    debugger = {
      name = "lldb-vscode";
      transport = "stdio";
      command = "rust-lldb";
    };
  };
}
