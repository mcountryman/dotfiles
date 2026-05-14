_final: prev: {
  btop = prev.btop.overrideAttrs rec {
    version = "1.4.7";
    src = prev.fetchFromGitHub {
      owner = "aristocratos";
      repo = "btop";
      tag = "v${version}";
      hash = "sha256-ZLT+Hc1rvBFyhey+imbgGzSH/QaVxIh/jvDKVSmDrA0=";
    };

    # Remove version check hook
    nativeInstallCheckInputs = [ ];
  };
}
