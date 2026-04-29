prev: {
  zellij = prev.zellij.overrideAttrs (_old: rec {
    version = "0.44.1";
    src = prev.fetchFromGitHub {
      owner = "zellij-org";
      repo = "zellij";
      tag = "v${version}";
      hash = "sha256-KHpVUjuOmMtkt8qBaCozD3M44eEtDwFmdDfszKAz0bM=";
    };
    cargoHash = "sha256-D3nZBXoGNf5z85iT7Xhj9Xwwwam/5m3X5hLPVoCzSPM=";
  });
}
