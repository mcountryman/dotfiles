{
  programs.helix.languages = {
    language = [
      {
        name = "git-commit";
        text-width = 72;
        auto-format = true;
        language-servers = [ "spellcheck" ];
        rulers = [
          50
          72
        ];
      }
    ];
  };
}
