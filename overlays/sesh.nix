_final: prev: {
  sesh = prev.sesh.overrideAttrs rec {
    version = "2.23.0";
    src = prev.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "sesh";
      rev = "v${version}";
      hash = "sha256-egh50ajgs2ngB9eALk4xq7W1n8OrTYeMBRsveisH2LQ=";
    };

    vendorHash = "sha256-9IiDp/HaxXQAyNzuVBLiO+oIijBbdKBjssCmj8WV9V4=";
    nativeInstallCheckInputs = [ ];
  };
}
