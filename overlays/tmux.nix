final: prev: {
  tmux = prev.tmux.overrideAttrs (_: {
    src = prev.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = "1081876810f5b5ac2a34fdf93e53030e23bd7358";
      hash = "sha256-s34zwkifwTdJXfnvisXHlyXbvRF1hLF0lXO/Hqf1Npo=";
    };
  });
}
