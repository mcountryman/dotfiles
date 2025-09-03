{ ... }:
{
  programs.helix.languages = {
    language = [
      {
        name = "git-commit";
        auto-format = true;
        language-servers = [ "spellcheck" ];
      }
    ];
  };
}
