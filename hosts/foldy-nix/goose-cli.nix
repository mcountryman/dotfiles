{
  lib,
  pkgs,
  config,
  ...
}:
let
  goose-cli = pkgs.goose-cli.overrideAttrs (prev: rec {
    version = "1.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "block";
      repo = "goose";
      tag = "v${version}";
      hash = "sha256-WFQdtwU2ssCrUNrjL0+rpyaA9iBQnf5nquUuvzjoBRQ=";
    };

    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-kozhCd1uV9ozUNxhr2ht5hhgBWSQhOwk8WXbyHoW+Io=";
    };

    checkFlags = (prev.checkFlags or [ ]) ++ [
      "--skip=test_concurrent_access"
      "--skip=test_model_not_in_openrouter"
      "--skip=test_pricing_cache_performance"
      "--skip=test_pricing_refresh"
      "--skip=context_mgmt::auto_compact::tests::test_auto_compact_respects_config"
      "--skip=providers::factory::tests::test_create_lead_worker_provider"
      "--skip=providers::factory::tests::test_create_regular_provider_without_lead_config"
      "--skip=providers::factory::tests::test_lead_model_env_vars_with_defaults"
    ];
  });
in
{
  sops.secrets."openrouter".sopsFile = ./secrets.yaml;

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "goose" ''
      OPENROUTER_API_KEY='$(cat ${config.sops.secrets."openrouter".path})' \
        ${lib.getExe goose-cli} $@
    '')
  ];
}
